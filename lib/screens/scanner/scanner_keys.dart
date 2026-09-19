import 'package:flutter/widgets.dart';

/// The keys a widget test finds the scanner's controls by.
///
/// They live apart from the widgets so the scanner screen, its parts and the
/// tests share one list, and a renamed control can't leave a test looking for
/// a key nothing carries.
abstract final class ScannerKeys {
  /// RUN-1's "Allow camera", the largest control on the placeholder.
  static const Key allowCamera = Key('scanner.allow_camera');

  /// RUN-6's "Open settings", in place of "Allow camera".
  static const Key openSettings = Key('scanner.open_settings');

  /// "Scan a photo" (RUN-4, SCAN-11), on the placeholder and the live scanner.
  static const Key scanPhoto = Key('scanner.scan_photo');

  /// "Type a code" (RUN-4, SCAN-12), on the placeholder and the live scanner.
  static const Key typeCode = Key('scanner.type_code');

  /// The whole live viewfinder: the preview, the target, and the area that
  /// takes a pinch or a double-tap (SCAN-4, SCAN-7).
  static const Key viewfinder = Key('scanner.viewfinder');

  /// The torch button, shown only when the camera reports a flash (SCAN-6).
  static const Key torch = Key('scanner.torch');

  /// The zoom slider (SCAN-7).
  static const Key zoomSlider = Key('scanner.zoom_slider');

  /// The list of codes one pass found (SCAN-13).
  static const Key choicesSheet = Key('scanner.choices');

  /// Closes the list of codes without a pick (SCAN-13).
  static const Key closeChoices = Key('scanner.choices.close');

  /// "No code found" (SCAN-11).
  static const Key noCodeFound = Key('scanner.no_code_found');

  /// "Try another photo", the largest control on "No code found" (SCAN-11).
  static const Key tryAnotherPhoto = Key('scanner.no_code_found.try_again');

  /// "Type a code" on "No code found" (SCAN-11, SCAN-12).
  static const Key noCodeTypeCode = Key('scanner.no_code_found.type_code');

  /// Closes "No code found" (SCAN-11).
  static const Key closeNoCodeFound = Key('scanner.no_code_found.close');

  /// One row of the list of codes, by its place in the list (SCAN-13).
  static Key choice(int index) => ValueKey<String>('scanner.choice.$index');
}
