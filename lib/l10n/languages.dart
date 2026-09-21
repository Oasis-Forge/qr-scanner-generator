import 'package:flutter/widgets.dart' show Locale;

/// The app's languages (LANG-1, LANG-7), each named in its own language.
///
/// The names are deliberately left untranslated: someone who has opened the
/// app in a language they can't read still has to find their own, and
/// "Deutsch" is findable where a translated "German" is not.
///
/// English leads, as the language every message is written in first; the
/// other twenty follow in the order of their English names, since no one
/// order can be alphabetical across this many scripts.
const Map<String, String> appLanguages = <String, String>{
  'en': 'English',
  'ar': 'العربية',
  'bn': 'বাংলা',
  'zh': '简体中文',
  'nl': 'Nederlands',
  'fr': 'Français',
  'de': 'Deutsch',
  // Greek is translated and ready in `tool/translations/el.json`, but it is
  // not offered yet: Space Grotesk and IBM Plex Mono cover only part of the
  // Greek alphabet, so Flutter takes plain letters from them and accented
  // ones from a fallback, and the app renders "Προεπιλογη΄" for
  // "Προεπιλογή" (LANG-7, and Known bugs in docs/ROADMAP.md). Restore this
  // line and app_el.arb once a font that covers Greek is bundled.
  'hi': 'हिन्दी',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'ja': '日本語',
  'ko': '한국어',
  'pl': 'Polski',
  'pt': 'Português',
  'ru': 'Русский',
  'es': 'Español',
  'th': 'ไทย',
  'tr': 'Türkçe',
  'ur': 'اردو',
  'vi': 'Tiếng Việt',
};

/// The languages that read right to left (LANG-5). Flutter sets the direction
/// from the locale on its own; this is for the places that have to know
/// before a widget tree exists, such as the test harnesses.
const Set<String> rightToLeftLanguages = <String>{'ar', 'ur'};

/// The locale each language choice in Settings sets (LANG-1). "System
/// default" is `null`, which is why the picker's value type is nullable.
List<Locale> get appLocales => appLanguages.keys
    .map((String languageCode) => Locale(languageCode))
    .toList(growable: false);

/// The key the Settings picker gives the button for [languageCode], so a test
/// can tap one language without knowing the list's order (LANG-1).
String languageChoiceKey(String languageCode) =>
    'settings.language.$languageCode';
