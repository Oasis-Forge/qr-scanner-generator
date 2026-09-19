import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../core/services/share_service.dart';
import '../db/record_dao.dart';
import '../generator/file_naming.dart';
import '../generator/generator_field_error.dart';
import '../generator/generator_form.dart';
import '../generator/generator_types.dart';
import '../generator/qr_capacity.dart';
import '../generator/qr_renderer.dart';
import '../models/parsed_payload.dart' show WifiSecurity;
import '../models/record_enums.dart';
import '../services/camera_scanner.dart' show CodeDetection;
import '../services/image_decoder.dart';
import 'settings_state.dart';
import 'success_counts.dart';

/// The PNG MIME type every created code is saved and shared as (SAVE-2,
/// SAVE-5): the only format this PR renders (STY-1).
const String qrPngMimeType = 'image/png';

/// What went wrong the last time [GeneratorState.create] ran its STY-5
/// check, or why it never got to run one at all. Null (on
/// [GeneratorState.checkError]) is the only state [GeneratorState.save] and
/// [GeneratorState.share] accept.
enum QrCreateError {
  /// The `barcode` package could not render the payload at all. GEN-12's
  /// capacity check stops content this large before [GeneratorState.create]
  /// is ever called; this only guards a bug in that check.
  renderFailed,

  /// STY-5: the [ImageDecoder] found no code in the rendered PNG at all, or
  /// threw trying to read it.
  decodeFailed,

  /// STY-5: the rendered PNG decoded to something other than the content it
  /// was encoded from.
  mismatch,
}

/// The generator's state (GEN-1 to GEN-13, STY-1, STY-5, SAVE-1, SAVE-2,
/// SAVE-4, SAVE-5).
///
/// One instance per Create screen. It holds the type being created and its
/// form (`lib/generator/generator_form.dart`), validates that form (GEN-1),
/// and turns valid content into a checked PNG (STY-1, STY-5) that [save] and
/// [share] hand to the system (SAVE-1, SAVE-2, SAVE-5).
///
/// Screens stay presentational (`CLAUDE.md`): they read [type], [form],
/// [fieldErrors], [capacityRatio], [renderedPng], [checkError] and
/// [historyWriteFailed], call the `update*` setters and [create], [save]
/// and [share], and never touch [RecordDao], [ImageDecoder] or
/// [ShareService] directly.
///
/// **A failed history write (GEN-13, `CLAUDE.md`).** The render and its
/// STY-5 check already happened by the time [create] would write History,
/// so a database failure there doesn't undo either: it only leaves
/// [historyWriteFailed] true, the same way `ScannerState` still opens a
/// result after a failed scan write. [save] and [share] are still gated on
/// [checkError] alone, never on [historyWriteFailed] — a code that scans
/// correctly stays saveable even when its History row didn't make it.
class GeneratorState extends ChangeNotifier {
  GeneratorState({
    required RecordDao recordDao,
    required SettingsState settings,
    required SuccessCounts successCounts,
    required ImageDecoder imageDecoder,
    required ShareService shareService,
    DateTime Function() now = DateTime.now,
    Future<Directory> Function() tempDirectory =
        path_provider.getTemporaryDirectory,
    QrPngRenderer render = renderQrPngBytes,
    ScratchFiles? scratchFiles,
  }) : _recordDao = recordDao,
       _settings = settings,
       _successCounts = successCounts,
       _imageDecoder = imageDecoder,
       _shareService = shareService,
       _now = now,
       _render = render,
       _scratch = scratchFiles ?? TemporaryScratchFiles(tempDirectory);

  final RecordDao _recordDao;
  final SettingsState _settings;
  final SuccessCounts _successCounts;
  final ImageDecoder _imageDecoder;
  final ShareService _shareService;
  final DateTime Function() _now;
  final QrPngRenderer _render;
  final ScratchFiles _scratch;

  ParsedType _type = ParsedType.url;
  GeneratorForm _form = const UrlForm();
  bool _isCreating = false;
  Uint8List? _renderedPng;
  String? _renderedPngPath;
  QrCreateError? _checkError;
  bool _historyWriteFailed = false;
  bool _disposed = false;

  /// The type being created (GEN-1).
  ParsedType get type => _type;

  /// The current form for [type] (GEN-3 to GEN-8).
  GeneratorForm get form => _form;

  /// Field-level validation errors for [form], keyed by that form's own
  /// field id (GEN-1).
  Map<String, GeneratorFieldError> get fieldErrors => _form.validate();

  /// The payload [form] would encode to, or null while [form] fails
  /// validation (GEN-3 to GEN-8).
  String? get encodedPayload => _form.isValid ? _form.encode() : null;

  /// [encodedPayload]'s length in bytes — QR byte mode, which is what
  /// GEN-12's capacity is measured in. 0 while [form] is invalid.
  int get payloadByteLength {
    final String? payload = encodedPayload;
    return payload == null ? 0 : utf8.encode(payload).length;
  }

  /// GEN-12: how full the QR byte-mode capacity at error correction M is —
  /// 0 to 1, or above 1 over the limit. The capacity meter shows once this
  /// passes 0.8.
  double get capacityRatio => payloadByteLength / qrMaxCapacityBytes;

  /// GEN-12: above 80% of capacity, the capacity meter appears.
  bool get showsCapacityMeter => capacityRatio > 0.8;

  /// GEN-12: over the limit, Create is blocked with the fix (shorter
  /// content — a lower error correction isn't offered while STY-1 fixes M).
  bool get isOverCapacity => payloadByteLength > qrMaxCapacityBytes;

  /// Whether Create is enabled: [form] validates and fits (GEN-1, GEN-12).
  bool get canCreate => _form.isValid && !isOverCapacity;

  /// Whether [create] is between its render and its history write, so a
  /// screen can disable Create meanwhile.
  bool get isCreating => _isCreating;

  /// The PNG [create] last rendered (STY-1), or null before the first
  /// [create] or after the encoder itself failed ([checkError] is
  /// [QrCreateError.renderFailed] then).
  Uint8List? get renderedPng => _renderedPng;

  /// What [create]'s STY-5 check found about [renderedPng], or null once it
  /// has passed. Null before the first [create] too, but so is
  /// [renderedPng] then, and a screen should read the two together.
  QrCreateError? get checkError => _checkError;

  /// STY-5: whether [renderedPng] passed its own scan check, which is what
  /// [save] and [share] gate on.
  bool get canSaveOrShare => _renderedPng != null && _checkError == null;

  /// Whether the last [create] rendered and checked its code fine but could
  /// not write it to History (GEN-13). Reset to false at the start of every
  /// [create] call. Never blocks [save] or [share].
  bool get historyWriteFailed => _historyWriteFailed;

  /// GEN-1: switches to a blank form for [type]. Clears any code [create]
  /// had rendered, since it was for the old type. Picking the type already
  /// selected keeps its form and returns to it from a created code
  /// ([backToForm]).
  void setType(ParsedType type) {
    if (type == _type) {
      backToForm();
      return;
    }
    _type = type;
    _form = emptyGeneratorForm(type);
    _renderedPng = null;
    _checkError = null;
    notifyListeners();
    unawaited(_forgetRenderedFile());
  }

  /// Leaves a created code, or a failed create, for the form it came from,
  /// every field kept, so the user can change it and create again.
  /// Does nothing while [create] is running.
  void backToForm() {
    if (_isCreating || (_renderedPng == null && _checkError == null)) {
      return;
    }
    _renderedPng = null;
    _checkError = null;
    _historyWriteFailed = false;
    notifyListeners();
    unawaited(_forgetRenderedFile());
  }

  /// GEN-3: the URL field, exactly as typed.
  void updateUrl(String rawInput) =>
      _updateForm((_form as UrlForm).copyWith(rawInput: rawInput));

  /// GEN-8: the Text field.
  void updateText(String text) =>
      _updateForm((_form as TextForm).copyWith(text: text));

  /// GEN-5: the Wi-Fi network name.
  void updateWifiSsid(String ssid) =>
      _updateForm((_form as WifiForm).copyWith(ssid: ssid));

  /// GEN-5: the Wi-Fi security type.
  void updateWifiSecurity(WifiSecurity security) =>
      _updateForm((_form as WifiForm).copyWith(security: security));

  /// GEN-5: the Wi-Fi password.
  void updateWifiPassword(String password) =>
      _updateForm((_form as WifiForm).copyWith(password: password));

  /// GEN-5: the hidden-network switch.
  void updateWifiHidden({required bool hidden}) =>
      _updateForm((_form as WifiForm).copyWith(hidden: hidden));

  /// GEN-6: the contact's name.
  void updateContactName(String name) =>
      _updateForm((_form as ContactForm).copyWith(name: name));

  /// GEN-6: the contact's phone number.
  void updateContactPhone(String phone) =>
      _updateForm((_form as ContactForm).copyWith(phone: phone));

  /// GEN-6: the contact's email address.
  void updateContactEmail(String email) =>
      _updateForm((_form as ContactForm).copyWith(email: email));

  /// GEN-6: the contact's organisation.
  void updateContactOrganisation(String organisation) =>
      _updateForm((_form as ContactForm).copyWith(organisation: organisation));

  /// GEN-7, GEN-8: the Phone field.
  void updatePhoneNumber(String number) =>
      _updateForm((_form as PhoneForm).copyWith(number: number));

  /// GEN-8: the Email field's recipient.
  void updateEmailTo(String to) =>
      _updateForm((_form as EmailForm).copyWith(to: to));

  /// GEN-8: the Email field's subject.
  void updateEmailSubject(String subject) =>
      _updateForm((_form as EmailForm).copyWith(subject: subject));

  /// GEN-8: the Email field's body.
  void updateEmailBody(String body) =>
      _updateForm((_form as EmailForm).copyWith(body: body));

  /// GEN-7, GEN-8: the SMS field's number.
  void updateSmsNumber(String number) =>
      _updateForm((_form as SmsForm).copyWith(number: number));

  /// GEN-8: the SMS field's message.
  void updateSmsMessage(String message) =>
      _updateForm((_form as SmsForm).copyWith(message: message));

  /// GEN-13, STY-1, STY-5: renders [form] as a PNG, checks that PNG decodes
  /// back to the exact content it was encoded from, then — only while
  /// [SettingsState.saveHistory] is on (HIS-8, DATA-6) — records it kind
  /// `created`, source `created`, with [form]'s fields as `content_json`.
  /// Counts a successful create either way (DATA-8): GEN-13 ties that count
  /// to the render, not to the STY-5 check, which only gates [save] and
  /// [share]. A history write that throws is caught and only leaves
  /// [historyWriteFailed] true (see the class doc); it never discards the
  /// render this call already produced.
  ///
  /// Does nothing while [canCreate] is false or a call is already running,
  /// so a screen only ever triggers this from an enabled, single button.
  Future<void> create() async {
    if (!canCreate || _isCreating) {
      return;
    }
    final GeneratorForm form = _form;
    final ParsedType type = _type;
    final String payload = form.encode();

    _isCreating = true;
    notifyListeners();

    final Uint8List png;
    try {
      png = await _render(payload);
    } on Object {
      if (_disposed) {
        return;
      }
      _isCreating = false;
      _renderedPng = null;
      _checkError = QrCreateError.renderFailed;
      _historyWriteFailed = false;
      notifyListeners();
      await _forgetRenderedFile();
      return;
    }
    if (_disposed) {
      return;
    }

    final String path;
    try {
      path = await _writeTempPng(png);
    } on Object {
      // Temporary storage full or unavailable: nothing can be checked or
      // shared, so the create fails like an encoder failure instead of
      // leaving the screen on its spinner.
      if (_disposed) {
        return;
      }
      _isCreating = false;
      _renderedPng = null;
      _checkError = QrCreateError.renderFailed;
      _historyWriteFailed = false;
      notifyListeners();
      await _forgetRenderedFile();
      return;
    }
    final QrCreateError? checkError = await _checkRendered(
      path: path,
      payload: payload,
    );
    if (_disposed) {
      await _deleteTempFile(path);
      return;
    }

    bool historyWriteFailed = false;
    if (_settings.saveHistory) {
      try {
        await _recordDao.recordScan(
          kind: RecordKind.created,
          source: RecordSource.created,
          symbology: Symbology.qr,
          parsedType: type,
          payloadText: payload,
          sensitiveFields: sensitiveFieldsOf(form),
          contentJson: jsonEncode(form.toJson()),
          at: _now(),
        );
      } on Object {
        historyWriteFailed = true;
      }
    }
    await _successCounts.recordSuccessfulCreate();
    if (_disposed) {
      await _deleteTempFile(path);
      return;
    }

    final String? previousPath = _renderedPngPath;
    _renderedPng = png;
    _renderedPngPath = path;
    _checkError = checkError;
    _historyWriteFailed = historyWriteFailed;
    _isCreating = false;
    notifyListeners();
    await _deleteTempFile(previousPath);
  }

  /// SAVE-1, SAVE-2, SAVE-4: writes [renderedPng] through the system file
  /// picker, named by [form]'s non-secret field. Reports
  /// [SaveOutcome.failed] and writes nothing until STY-5 has passed.
  Future<SaveResult> save() async {
    if (!canSaveOrShare) {
      return const SaveResult(outcome: SaveOutcome.failed);
    }
    return _shareService.saveFile(
      suggestedName: generatorFileName(type: _type, form: _form, at: _now()),
      mimeType: qrPngMimeType,
      bytes: _renderedPng!,
    );
  }

  /// SAVE-1, SAVE-5: shares the exact PNG file [create] rendered and
  /// checked, without re-encoding it. Does nothing until STY-5 has passed.
  Future<void> share() async {
    final String? path = _renderedPngPath;
    if (!canSaveOrShare || path == null) {
      return;
    }
    await _shareService.shareFile(path: path, mimeType: qrPngMimeType);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_forgetRenderedFile());
    super.dispose();
  }

  void _updateForm(GeneratorForm form) {
    _form = form;
    notifyListeners();
  }

  Future<QrCreateError?> _checkRendered({
    required String path,
    required String payload,
  }) async {
    final ImageDecodeResult result;
    try {
      result = await _imageDecoder.decodeFile(path);
    } on Object {
      return QrCreateError.decodeFailed;
    }
    if (!result.foundCode) {
      return QrCreateError.decodeFailed;
    }
    final Uint8List expected = Uint8List.fromList(utf8.encode(payload));
    for (final CodeDetection detection in result.detections) {
      final Uint8List? actual = detection.isValidUtf8
          ? Uint8List.fromList(utf8.encode(detection.payload))
          : detection.rawBytes;
      if (actual != null && _bytesEqual(actual, expected)) {
        return null;
      }
    }
    return QrCreateError.mismatch;
  }

  /// Writes [bytes] to a fresh scratch file, for STY-5's own round trip and,
  /// once it passes, for [share] to hand to [ShareService.shareFile] — the
  /// exact file [create] just checked, never a second copy re-encoded from
  /// the same bytes (SAVE-5).
  Future<String> _writeTempPng(Uint8List bytes) =>
      _scratch.write(bytes, name: 'qr-create-${_now().microsecondsSinceEpoch}');

  /// Drops the currently held render and deletes its temporary file, for a
  /// type switch ([setType]) or disposal — never for a successful [create],
  /// which keeps its own file alive for [share] until the *next* [create]
  /// replaces it.
  Future<void> _forgetRenderedFile() async {
    final String? path = _renderedPngPath;
    _renderedPngPath = null;
    await _deleteTempFile(path);
  }

  Future<void> _deleteTempFile(String? path) async {
    if (path == null) {
      return;
    }
    try {
      await _scratch.delete(path);
    } on Object {
      // Best-effort: STY-5's own scratch file, never user data.
    }
  }
}

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// Renders a payload as the created code's PNG bytes (STY-1).
typedef QrPngRenderer = Future<Uint8List> Function(String payload);

/// [renderQrPng]'s PNG alone, [GeneratorState]'s default renderer.
Future<Uint8List> renderQrPngBytes(String payload) async =>
    (await renderQrPng(payload)).png;

/// Where [GeneratorState.create] keeps the one PNG it checks (STY-5) and
/// [GeneratorState.share] hands on (SAVE-5).
///
/// Widget tests pass one that never touches the disk: real file I/O never
/// completes under a widget test's fake clock.
abstract class ScratchFiles {
  /// Writes [bytes] as `<name>.png` and returns its path.
  Future<String> write(Uint8List bytes, {required String name});

  /// Deletes the file at [path].
  Future<void> delete(String path);
}

/// [ScratchFiles] in the app's own temporary storage.
class TemporaryScratchFiles implements ScratchFiles {
  TemporaryScratchFiles(this._directory);

  final Future<Directory> Function() _directory;

  @override
  Future<String> write(Uint8List bytes, {required String name}) async {
    final Directory directory = await _directory();
    final String path = '${directory.path}${Platform.pathSeparator}$name.png';
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  @override
  Future<void> delete(String path) => File(path).delete();
}
