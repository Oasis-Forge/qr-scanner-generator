import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// LANG-2. The app name, shown in the task switcher and as the fallback screen title.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner + Generator'**
  String get appTitle;

  /// SCAN-1. Bottom navigation destination for the live scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// SCAN-1. Bottom navigation destination for the code generator.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// SCAN-1. Bottom navigation destination for the list of scanned and created codes.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// SCAN-1. Bottom navigation destination for Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// RUN-1. The one reason shown on the scanner placeholder before the camera is allowed. Translations must stay at or under 70 characters.
  ///
  /// In en, this message translates to:
  /// **'The camera is used only to read codes on this device.'**
  String get cameraPermissionReason;

  /// RUN-1. Largest control on the scanner placeholder; opens the system camera prompt.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get cameraAllowButton;

  /// RUN-6. Replaces the allow button once Android will not show its prompt again; opens the app permission page.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get cameraOpenSettingsButton;

  /// RUN-4, SCAN-11. Opens the system photo picker to decode a code from an image.
  ///
  /// In en, this message translates to:
  /// **'Scan a photo'**
  String get scanFromPhotoButton;

  /// RUN-4, SCAN-12. Opens typed entry, which runs the same parsers as a camera scan.
  ///
  /// In en, this message translates to:
  /// **'Type a code'**
  String get typeCodeButton;

  /// SCAN-1. Body of the Create tab until the generator ships: says plainly that it is not in this build yet.
  ///
  /// In en, this message translates to:
  /// **'Creating codes arrives in the next test build.'**
  String get placeholderCreateMessage;

  /// SCAN-1, DATA-4. Body of the History tab until the list ships. Scans are written from this build on, so it says they are kept, and only on the phone.
  ///
  /// In en, this message translates to:
  /// **'The History list arrives in the next test build. Your scans are already kept on this phone.'**
  String get placeholderHistoryMessage;

  /// SCAN-4. One line on the live scanner, under the square target. Detection is automatic: there is no shutter to press.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a code'**
  String get scanTargetHint;

  /// The camera is allowed but did not start (no usable back camera, or another app holds it). Shown with Scan a photo and Type a code.
  ///
  /// In en, this message translates to:
  /// **'The camera could not start. Another app may be using it.'**
  String get scanCameraUnavailable;

  /// SCAN-6, A11Y-1. Screen-reader name and tooltip of the torch button while the torch is off.
  ///
  /// In en, this message translates to:
  /// **'Turn on the torch'**
  String get scanTorchOn;

  /// SCAN-6, A11Y-1. Screen-reader name and tooltip of the torch button while the torch is on.
  ///
  /// In en, this message translates to:
  /// **'Turn off the torch'**
  String get scanTorchOff;

  /// SCAN-7, A11Y-1. Screen-reader name of the zoom slider on the live scanner.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get scanZoomLabel;

  /// SCAN-7, LANG-3. The current zoom beside the slider and as its screen-reader value, such as 2× or 1.5×. The number follows the app language and stays left to right (LANG-5).
  ///
  /// In en, this message translates to:
  /// **'{zoom}×'**
  String scanZoomValue(double zoom);

  /// SCAN-11, A11Y-1. Screen-reader name of the progress indicator shown while a picked photo is decoded.
  ///
  /// In en, this message translates to:
  /// **'Reading the photo'**
  String get scanReadingPhoto;

  /// SCAN-11. Snackbar when the system photo picker could not be opened.
  ///
  /// In en, this message translates to:
  /// **'The photo picker did not open. Try again.'**
  String get scanPhotoPickerFailed;

  /// RUN-6. Snackbar when Open settings could not open the app permission page.
  ///
  /// In en, this message translates to:
  /// **'Settings did not open. Allow the camera from your phone settings.'**
  String get scanSettingsDidNotOpen;

  /// A11Y-3. Spoken by screen readers when the camera or a photo reads a code. Both placeholders take already translated labels.
  ///
  /// In en, this message translates to:
  /// **'{format} detected: {type}'**
  String scanDetectedAnnouncement(String format, String type);

  /// A11Y-3. As scanDetectedAnnouncement, for a code whose format has no name. The placeholder takes an already translated type label.
  ///
  /// In en, this message translates to:
  /// **'{type} detected'**
  String scanTypeDetectedAnnouncement(String type);

  /// A11Y-3, SCAN-13. Spoken by screen readers when one pass finds two or more codes and the list opens.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 code detected} other{{count} codes detected}}'**
  String scanChoicesAnnouncement(int count);

  /// SCAN-13. Heading of the list shown when one pass finds two or more codes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 code found} other{{count} codes found}}'**
  String scanChoicesTitle(int count);

  /// SCAN-13. One line under the heading of the list of codes.
  ///
  /// In en, this message translates to:
  /// **'Choose the code to open.'**
  String get scanChoicesHint;

  /// RES-13, SCAN-13. Shown instead of a payload that is not valid text, on the result and in the list of codes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Binary data, 1 byte} other{Binary data, {count} bytes}}'**
  String scanBinaryData(int count);

  /// SCAN-11. Heading shown when a picked photo holds no readable code.
  ///
  /// In en, this message translates to:
  /// **'No code found'**
  String get noCodeFoundTitle;

  /// SCAN-11. The one hint under No code found.
  ///
  /// In en, this message translates to:
  /// **'Make sure the whole code is in the photo, sharp and well lit.'**
  String get noCodeFoundHint;

  /// SCAN-11. Largest control on No code found; opens the photo picker again.
  ///
  /// In en, this message translates to:
  /// **'Try another photo'**
  String get tryAnotherPhotoButton;

  /// A11Y-1. Screen-reader name and tooltip of the close buttons on the list of codes and on No code found.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// SCAN-12. Title of the typed-entry screen.
  ///
  /// In en, this message translates to:
  /// **'Type a code'**
  String get manualEntryTitle;

  /// SCAN-12. Label of the multi-line field the content is typed into.
  ///
  /// In en, this message translates to:
  /// **'Code content'**
  String get manualEntryFieldLabel;

  /// SCAN-12. Hint inside the empty typed-entry field.
  ///
  /// In en, this message translates to:
  /// **'A link, some text or a barcode number'**
  String get manualEntryFieldHint;

  /// SCAN-12. Largest control on typed entry, disabled while the field is empty; opens the same result as a camera scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get manualEntryScanButton;

  /// SET-5. First Settings group: theme, language, sound, vibration, copy on scan, search engine.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGroupGeneral;

  /// SET-5. Second Settings group: save history, send crash reports, privacy options.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsGroupPrivacy;

  /// SET-5, PRO-1. Third Settings group: remove ads, restore purchase. Pro is the product name, not a description.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get settingsGroupPro;

  /// SET-5. Fourth Settings group: feedback, privacy policy, open-source licences, version.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsGroupAbout;

  /// SET-1, SET-5. Settings row that opens the theme choice.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// LANG-1, SET-5. Settings row that opens the language choice.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// SET-2, SET-5. Switch for the scan sound, off by default.
  ///
  /// In en, this message translates to:
  /// **'Sound on scan'**
  String get settingsSoundOnScan;

  /// SET-2, SET-5. Switch for the scan vibration, on by default.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on scan'**
  String get settingsVibrateOnScan;

  /// SET-3, SET-5. Switch that copies the decoded text once the result is on screen, off by default.
  ///
  /// In en, this message translates to:
  /// **'Copy on scan'**
  String get settingsCopyOnScan;

  /// SET-4, SET-5. Settings row that chooses the engine used by Search the web.
  ///
  /// In en, this message translates to:
  /// **'Search engine'**
  String get settingsSearchEngine;

  /// HIS-8, SET-5. Switch that stores scans and created codes, on by default.
  ///
  /// In en, this message translates to:
  /// **'Save history'**
  String get settingsSaveHistory;

  /// PRIV-3, SET-5. Switch that turns on crash reporting, off by default.
  ///
  /// In en, this message translates to:
  /// **'Send crash reports'**
  String get settingsSendCrashReports;

  /// PRIV-2, SET-5. Settings row shown only where the consent SDK reports the region needs it.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get settingsPrivacyOptions;

  /// PRO-4, SET-5. Settings row that starts the one-time Pro purchase.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get settingsRemoveAds;

  /// PRO-1, PRO-3, PRO-5. Second line under Remove ads. Never a subscription, and no price or discount is shown here.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get settingsRemoveAdsSubtitle;

  /// PRO-6, SET-5. Settings row next to Remove ads that re-checks ownership.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get settingsRestorePurchase;

  /// SET-8, SET-5. Settings row that opens the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedback;

  /// SET-6, SET-5. Settings row that opens the published policy in Custom Tabs.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// SET-7, SET-5. Settings row that opens the Flutter licence page.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get settingsOpenSourceLicences;

  /// SET-5. Label of the last About row.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// SET-5. Value of the version row: the SemVer name followed by the build number in brackets.
  ///
  /// In en, this message translates to:
  /// **'{version} ({build})'**
  String settingsVersionValue(String version, String build);

  /// SET-1. Theme choice that follows the phone setting; the initial choice.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystemDefault;

  /// SET-1. Light theme choice.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// SET-1. Dark theme choice.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// LANG-1. Language choice that follows the device language and falls back to English. Kept apart from themeSystemDefault because languages that inflect need different wording here.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// LANG-1. English, written in its own language; the same in every message file.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// LANG-1. Arabic, written in its own language; the same in every message file.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// DATE-2, HIS-3. Date header for rows from the current local calendar day.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyHeaderToday;

  /// DATE-2, HIS-3. Date header for rows from the previous local calendar day.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyHeaderYesterday;

  /// DATE-2, HIS-3, LANG-3. Date header for rows from the last 7 days: the weekday name in the app language.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String historyHeaderWeekday(DateTime date);

  /// DATE-2, HIS-3, LANG-3. Date header for older rows: the local calendar day formatted for the app language.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String historyHeaderDate(DateTime date);

  /// HIS-4, LANG-3. Shown on a history row when the code was seen 2 or more times; the number follows the app language.
  ///
  /// In en, this message translates to:
  /// **'×{count}'**
  String historySeenCount(int count);

  /// HIS-6, DATA-8. A count of codes, used for a saved batch row and for empty states.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No codes} one{1 code} other{{count} codes}}'**
  String historyCodeCount(int count);

  /// HIS-1. Segmented control option showing every live record, scanned and created.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historySegmentAll;

  /// HIS-1. Segmented control option showing only records of kind scan.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get historySegmentScanned;

  /// HIS-1. Segmented control option showing only records of kind created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get historySegmentCreated;

  /// HIS-11. The one line shown when History holds no live records at all.
  ///
  /// In en, this message translates to:
  /// **'Codes you scan or create will show up here.'**
  String get historyEmptyMessage;

  /// HIS-11. On the empty History screen; switches to the Scan tab.
  ///
  /// In en, this message translates to:
  /// **'Scan a code'**
  String get historyEmptyScanButton;

  /// HIS-11. On the empty History screen; switches to the Create tab.
  ///
  /// In en, this message translates to:
  /// **'Create a code'**
  String get historyEmptyCreateButton;

  /// HIS-8, HIS-11. Second line on the empty History screen while Save history is off.
  ///
  /// In en, this message translates to:
  /// **'New scans aren\'\'t being saved.'**
  String get historyEmptyNotSavingMessage;

  /// HIS-8, HIS-11. On the empty History screen while Save history is off; switches to the Settings tab.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get historyEmptySettingsButton;

  /// HIS-1, A11Y-1. Screen-reader label for the spinner shown for the moment before History's first read completes.
  ///
  /// In en, this message translates to:
  /// **'Loading History'**
  String get historyLoading;

  /// DEL-2. Snackbar confirming a delete, with Undo beside it for HistoryState.undoWindow.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item deleted} other{{count} items deleted}}'**
  String historyDeletedSnackbar(int count);

  /// DEL-2. Action on historyDeletedSnackbar; restores what was just deleted.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get historyUndoButton;

  /// DEL-2. Snackbar when moving one or more records to Trash failed; History still shows them.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Try again.'**
  String get historyDeleteFailed;

  /// DEL-2. Snackbar when restoring from Trash failed; the records stay out of History.
  ///
  /// In en, this message translates to:
  /// **'Could not undo. Try again.'**
  String get historyUndoFailed;

  /// HIS-1. Snackbar when History could not be read from the database; the rows already shown stay.
  ///
  /// In en, this message translates to:
  /// **'History couldn\'\'t be loaded. Try again.'**
  String get historyLoadFailed;

  /// DEL-2. Title of History's app bar while rows are selected for deletion.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 selected} other{{count} selected}}'**
  String historySelectedCount(int count);

  /// DEL-2, A11Y-1. Screen-reader label and tooltip of the action that deletes every selected row.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDeleteSelectedButton;

  /// DEL-2, A11Y-1. Screen-reader label and tooltip of the action that leaves selection mode without deleting.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get historyCancelSelectionButton;

  /// SET-3, RES-2. Snackbar confirming what was copied. The placeholder takes an already translated noun, such as the link or the password.
  ///
  /// In en, this message translates to:
  /// **'Copied {what}'**
  String copiedSnackbar(String what);

  /// SET-3, RES-1. Fills copiedSnackbar after a link was copied.
  ///
  /// In en, this message translates to:
  /// **'the link'**
  String get copiedWhatLink;

  /// SET-3, RES-1. Fills copiedSnackbar after the decoded content of any other type was copied.
  ///
  /// In en, this message translates to:
  /// **'the content'**
  String get copiedWhatContent;

  /// RES-1, RES-3. Title of the result screen, whatever the source of the code.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// RES-1, DATA-1. First line of a result: the type, then the format it was read in. Both placeholders take already translated labels.
  ///
  /// In en, this message translates to:
  /// **'{type} · {format}'**
  String resultTypeAndFormat(String type, String format);

  /// RES-1. Copies the exact decoded text.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get resultCopyButton;

  /// RES-1. Opens the system share sheet with the exact decoded text.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get resultShareButton;

  /// DATA-4. Shown on a result when Save history is on but writing the scan failed; the result still works.
  ///
  /// In en, this message translates to:
  /// **'This scan could not be saved to History.'**
  String get resultNotSaved;

  /// RES-1. Snackbar when the clipboard refused the text.
  ///
  /// In en, this message translates to:
  /// **'Could not copy. Try again.'**
  String get resultCopyFailed;

  /// RES-1. Snackbar when the system share sheet could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open sharing. Try again.'**
  String get resultShareFailed;

  /// DATA-1. Label of the url type, on results and in the list of codes.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get parsedTypeUrl;

  /// DATA-1, RES-4. Label of the wifi type.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get parsedTypeWifi;

  /// DATA-1. Label of the text type: plain text that fits no other type.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get parsedTypeText;

  /// DATA-1, RES-6. Label of the contact type (vCard, MeCard).
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get parsedTypeContact;

  /// DATA-1, RES-7. Label of the phone type.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get parsedTypePhone;

  /// DATA-1, RES-7. Label of the email type.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get parsedTypeEmail;

  /// DATA-1, RES-7. Label of the sms type: a text message with an optional body.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get parsedTypeSms;

  /// DATA-1, RES-8. Label of the geo type.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get parsedTypeGeo;

  /// DATA-1, RES-6. Label of the event type (iCalendar).
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get parsedTypeEvent;

  /// DATA-1, RES-9. Label of the product type (EAN, UPC, ISBN).
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get parsedTypeProduct;

  /// DATA-1, GEN-10. Label of the app_store type: a Play Store app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get parsedTypeAppStore;

  /// DATA-1, RES-13. Label of the unknown type: a payload that fits no type.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get parsedTypeUnknown;

  /// DATA-1, SCAN-9. Name of the QR code format.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get symbologyQr;

  /// DATA-1, SCAN-9. Name of the Data Matrix format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'Data Matrix'**
  String get symbologyDataMatrix;

  /// DATA-1, SCAN-9. Name of the PDF417 format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'PDF417'**
  String get symbologyPdf417;

  /// DATA-1, SCAN-9. Name of the Aztec format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'Aztec'**
  String get symbologyAztec;

  /// DATA-1, SCAN-9. Name of the Code 128 format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'Code 128'**
  String get symbologyCode128;

  /// DATA-1, SCAN-9. Name of the Code 39 format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'Code 39'**
  String get symbologyCode39;

  /// DATA-1, SCAN-9. Name of the Code 93 format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'Code 93'**
  String get symbologyCode93;

  /// DATA-1, SCAN-9. Name of the Codabar format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'Codabar'**
  String get symbologyCodabar;

  /// DATA-1, SCAN-9. Name of the ITF (Interleaved 2 of 5) format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'ITF'**
  String get symbologyItf;

  /// DATA-1, SCAN-9, RES-9. Name of the EAN-13 format, which also carries ISBN; a proper name.
  ///
  /// In en, this message translates to:
  /// **'EAN-13'**
  String get symbologyEan13;

  /// DATA-1, SCAN-9, RES-9. Name of the EAN-8 format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'EAN-8'**
  String get symbologyEan8;

  /// DATA-1, SCAN-9, RES-9. Name of the UPC-A format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'UPC-A'**
  String get symbologyUpcA;

  /// DATA-1, SCAN-9, RES-9. Name of the UPC-E format; a proper name.
  ///
  /// In en, this message translates to:
  /// **'UPC-E'**
  String get symbologyUpcE;

  /// DATA-1. Name shown for a format this build cannot name.
  ///
  /// In en, this message translates to:
  /// **'Unknown format'**
  String get symbologyUnknown;

  /// LANG-2. Fills the screen when the app database will not open at launch, so the app says what happened instead of crashing or showing a blank frame. Not errorSaveFailed: nothing was being saved.
  ///
  /// In en, this message translates to:
  /// **'The app cannot open its storage. Close it and open it again.'**
  String get errorStorageUnavailable;

  /// Reliable writes: shown when a write fails and the change was rolled back, so no partial record is left.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved. Try again.'**
  String get errorSaveFailed;

  /// Button that runs the failed action again, shown with errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// SET-3, RES-4. Fills copiedSnackbar after a Wi-Fi password was copied.
  ///
  /// In en, this message translates to:
  /// **'the password'**
  String get copiedWhatPassword;

  /// RES-6, RES-7, RES-9. Snackbar when a hand-off to a system app, or a web search, could not be started.
  ///
  /// In en, this message translates to:
  /// **'Could not open. Try again.'**
  String get resultHandOffFailed;

  /// RES-4, RES-14. One-line reason shown when Open Wi-Fi settings is disabled.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi settings can\'\'t be opened on this device.'**
  String get resultUnavailableWifiSettings;

  /// RES-6, RES-14. One-line reason shown when Add to contacts is disabled.
  ///
  /// In en, this message translates to:
  /// **'No contacts app is installed.'**
  String get resultUnavailableContacts;

  /// RES-6, RES-14. One-line reason shown when Add to calendar is disabled.
  ///
  /// In en, this message translates to:
  /// **'No calendar app is installed.'**
  String get resultUnavailableCalendar;

  /// RES-7, RES-14. One-line reason shown when Call is disabled.
  ///
  /// In en, this message translates to:
  /// **'No phone app is installed.'**
  String get resultUnavailableDialer;

  /// RES-7, RES-14. One-line reason shown when Message is disabled on an SMS result.
  ///
  /// In en, this message translates to:
  /// **'No messaging app is installed.'**
  String get resultUnavailableSms;

  /// RES-7, RES-14. One-line reason shown when Email is disabled.
  ///
  /// In en, this message translates to:
  /// **'No email app is installed.'**
  String get resultUnavailableEmail;

  /// RES-9, RES-14. One-line reason shown when Search the web is disabled.
  ///
  /// In en, this message translates to:
  /// **'No browser is installed.'**
  String get resultUnavailableBrowser;

  /// LINK-3, LINK-8. Primary action of a link result with no checks triggered; opens the link in Custom Tabs.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get resultLinkOpenButton;

  /// LINK-3, LINK-4. Primary action of a link result with any check triggered; opens the warning sheet.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get resultLinkReviewButton;

  /// LINK-4. Title at the top of the warning sheet.
  ///
  /// In en, this message translates to:
  /// **'Before you open this link'**
  String get resultLinkWarningTitle;

  /// LINK-3, LINK-4. Plain-language line on the warning sheet for the ipAddressHost check.
  ///
  /// In en, this message translates to:
  /// **'The address is a raw IP number, not a name'**
  String get resultLinkCheckIpAddressHost;

  /// LINK-3, LINK-4. Plain-language line on the warning sheet for the userinfo check.
  ///
  /// In en, this message translates to:
  /// **'It contains a user name before the site name'**
  String get resultLinkCheckUserinfo;

  /// LINK-3, LINK-4. Plain-language line on the warning sheet for the insecureScheme check.
  ///
  /// In en, this message translates to:
  /// **'It isn\'\'t encrypted (http)'**
  String get resultLinkCheckInsecureScheme;

  /// LINK-3, LINK-4. Plain-language line on the warning sheet for the nonDefaultPort check.
  ///
  /// In en, this message translates to:
  /// **'It uses an unusual port'**
  String get resultLinkCheckNonDefaultPort;

  /// LINK-3, LINK-4. Plain-language line on the warning sheet for the longUrl check.
  ///
  /// In en, this message translates to:
  /// **'It\'\'s unusually long'**
  String get resultLinkCheckLongUrl;

  /// LINK-4. Filled button on the warning sheet; copies the link's exact text without opening it.
  ///
  /// In en, this message translates to:
  /// **'Copy without opening'**
  String get resultLinkCopyWithoutOpeningButton;

  /// LINK-4, LINK-8. Outlined button on the warning sheet; opens the link in Custom Tabs despite the checks.
  ///
  /// In en, this message translates to:
  /// **'Open anyway'**
  String get resultLinkOpenAnywayButton;

  /// LINK-5. Shown instead of Open or Review when the link's scheme is blocked; only Copy and Share remain.
  ///
  /// In en, this message translates to:
  /// **'{scheme} links can\'\'t be opened here.'**
  String resultLinkBlockedNotice(String scheme);

  /// RUN-8, LINK-3. One-time callout shown above the actions on the first link result ever shown.
  ///
  /// In en, this message translates to:
  /// **'This app checks links before opening them, so you can see where they lead first.'**
  String get resultLinkCalloutMessage;

  /// RUN-8, A11Y-1. Screen-reader label for the callout's close button; one tap dismisses it for good.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get resultLinkCalloutDismissTooltip;

  /// RES-4. Label above a Wi-Fi result's network name.
  ///
  /// In en, this message translates to:
  /// **'Network name'**
  String get resultWifiNetworkNameLabel;

  /// RES-4. Label above a Wi-Fi result's security type.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get resultWifiSecurityLabel;

  /// RES-4. Label above a Wi-Fi result's password, masked until revealed.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get resultWifiPasswordLabel;

  /// RES-4, A11Y-1. Screen-reader label of the icon button that reveals the masked Wi-Fi password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get resultWifiRevealPasswordTooltip;

  /// RES-4, A11Y-1. Screen-reader label of the same icon button once the password is revealed.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get resultWifiHidePasswordTooltip;

  /// RES-4. Note shown under a WEP network's fields.
  ///
  /// In en, this message translates to:
  /// **'Android can\'\'t join WEP networks from apps.'**
  String get resultWifiWepNotice;

  /// RES-4. Primary action of a Wi-Fi result.
  ///
  /// In en, this message translates to:
  /// **'Open Wi-Fi settings'**
  String get resultWifiPrimaryButton;

  /// RES-4. Secondary action that copies only the password, never the whole payload.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get resultWifiCopyPasswordButton;

  /// RES-4. Value of the security field for a WPA network; a proper name.
  ///
  /// In en, this message translates to:
  /// **'WPA'**
  String get resultWifiSecurityWpa;

  /// RES-4. Value of the security field for a WPA2 network; a proper name.
  ///
  /// In en, this message translates to:
  /// **'WPA2'**
  String get resultWifiSecurityWpa2;

  /// RES-4. Value of the security field for a WPA3 network; a proper name.
  ///
  /// In en, this message translates to:
  /// **'WPA3'**
  String get resultWifiSecurityWpa3;

  /// RES-4. Value of the security field for a WEP network; a proper name.
  ///
  /// In en, this message translates to:
  /// **'WEP'**
  String get resultWifiSecurityWep;

  /// RES-4. Value of the security field for a network with no password.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get resultWifiSecurityNone;

  /// RES-6. Label above a contact result's name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get resultContactNameLabel;

  /// RES-6. Label above each of a contact result's phone numbers.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get resultContactPhoneLabel;

  /// RES-6. Label above each of a contact result's email addresses.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get resultContactEmailLabel;

  /// RES-6. Label above a contact result's organisation.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get resultContactOrganisationLabel;

  /// RES-6. Primary action of a contact result.
  ///
  /// In en, this message translates to:
  /// **'Add to contacts'**
  String get resultContactPrimaryButton;

  /// RES-6. Label above an event result's title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get resultEventTitleLabel;

  /// RES-6. Label above an event result's start, shown exactly as encoded (DATE-3).
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get resultEventStartLabel;

  /// RES-6. Label above an event result's end, shown exactly as encoded (DATE-3).
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get resultEventEndLabel;

  /// RES-6. Label above an event result's location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get resultEventLocationLabel;

  /// RES-6. Label above an event result's notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get resultEventNotesLabel;

  /// RES-6. Note shown on an event result whose start has no time part.
  ///
  /// In en, this message translates to:
  /// **'All-day event.'**
  String get resultEventAllDayNotice;

  /// RES-6, DATE-3. An event time written in UTC, shown as encoded with UTC after it.
  ///
  /// In en, this message translates to:
  /// **'{time} UTC'**
  String resultEventTimeUtc(String time);

  /// RES-6, DATE-3. An event time written in a named time zone, shown as encoded with the zone name after it.
  ///
  /// In en, this message translates to:
  /// **'{time} ({zone})'**
  String resultEventTimeZoned(String time, String zone);

  /// RES-6, RES-14. Why Add to calendar is disabled for an event code with no readable start time.
  ///
  /// In en, this message translates to:
  /// **'This event has no start time, so it can\'\'t be added.'**
  String get resultUnavailableEventNoStart;

  /// RES-6. Primary action of an event result.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get resultEventPrimaryButton;

  /// RES-7. Label above a phone result's number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get resultPhoneNumberLabel;

  /// RES-7. Primary action of a phone result; opens the dialer prefilled and never calls.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get resultPhonePrimaryButton;

  /// RES-7. Label above an SMS result's recipient number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get resultSmsNumberLabel;

  /// RES-7. Label above an SMS result's pre-filled message, when it has one.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get resultSmsMessageLabel;

  /// RES-7. Primary action of an SMS result; opens the messaging app prefilled and never sends.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get resultSmsPrimaryButton;

  /// RES-7. Label above an email result's recipient address.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get resultEmailToLabel;

  /// RES-7. Label above an email result's subject, when it has one.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get resultEmailSubjectLabel;

  /// RES-7. Label above an email result's body, when it has one.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get resultEmailBodyLabel;

  /// RES-7. Primary action of an email result; opens the email app prefilled and never sends.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get resultEmailPrimaryButton;

  /// RES-9. Label above a product result's number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get resultProductNumberLabel;

  /// RES-9. Label above a product result's format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get resultProductFormatLabel;

  /// RES-9. Value of the format field for an EAN-13 product; a proper name.
  ///
  /// In en, this message translates to:
  /// **'EAN-13'**
  String get resultProductFormatEan13;

  /// RES-9. Value of the format field for an EAN-8 product; a proper name.
  ///
  /// In en, this message translates to:
  /// **'EAN-8'**
  String get resultProductFormatEan8;

  /// RES-9. Value of the format field for a UPC-A product; a proper name.
  ///
  /// In en, this message translates to:
  /// **'UPC-A'**
  String get resultProductFormatUpcA;

  /// RES-9. Value of the format field for a UPC-E product; a proper name.
  ///
  /// In en, this message translates to:
  /// **'UPC-E'**
  String get resultProductFormatUpcE;

  /// RES-9. Value of the format field for an ISBN, an EAN-13 whose digits mark it as one; a proper name.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get resultProductFormatIsbn;

  /// RES-9, SET-4. Primary action of a product result; searches with the engine chosen in Settings.
  ///
  /// In en, this message translates to:
  /// **'Search the web'**
  String get resultProductSearchButton;

  /// RES-8. Label above a location result's latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get resultLocationLatitudeLabel;

  /// RES-8. Label above a location result's longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get resultLocationLongitudeLabel;

  /// RES-8. Label above a location result's optional place name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get resultLocationNameLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
