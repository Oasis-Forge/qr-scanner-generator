import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';

/// Translated labels for the enums the per-type result sections introduce
/// (RES-4, RES-9), the same pattern `code_labels.dart` uses for
/// `ParsedType` and `Symbology`.
extension ResultLabels on AppLocalizations {
  /// A Wi-Fi security type as RES-4 shows it, e.g. "WPA2" or "Open".
  String wifiSecurityLabel(WifiSecurity security) => switch (security) {
    WifiSecurity.wpa => resultWifiSecurityWpa,
    WifiSecurity.wpa2 => resultWifiSecurityWpa2,
    WifiSecurity.wpa3 => resultWifiSecurityWpa3,
    WifiSecurity.wep => resultWifiSecurityWep,
    WifiSecurity.none => resultWifiSecurityNone,
  };

  /// A product's code format as RES-9 shows it, e.g. "EAN-13" or "ISBN".
  ///
  /// Distinct from `symbologyLabel` (`code_labels.dart`): the format a
  /// [Product] carries can name something the read [Symbology] alone
  /// doesn't — an ISBN is still read as [Symbology.ean13].
  String productFormatLabel(ProductCodeFormat format) => switch (format) {
    ProductCodeFormat.ean13 => resultProductFormatEan13,
    ProductCodeFormat.ean8 => resultProductFormatEan8,
    ProductCodeFormat.upcA => resultProductFormatUpcA,
    ProductCodeFormat.upcE => resultProductFormatUpcE,
    ProductCodeFormat.isbn => resultProductFormatIsbn,
  };
}
