import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/record_enums.dart';

/// The translated names of the fixed type and format IDs a record stores
/// (DATA-1).
///
/// Records keep `url`, `qr`, `ean13` and so on; screens only ever show these
/// labels, so a language change relabels every record without touching the
/// database. Every [ParsedType] and every [Symbology] has its own message, in
/// every message file (LANG-2).
extension CodeLabels on AppLocalizations {
  /// What a payload was parsed as, e.g. "Link" (DATA-1, RES-1).
  String parsedTypeLabel(ParsedType type) => switch (type) {
    ParsedType.url => parsedTypeUrl,
    ParsedType.wifi => parsedTypeWifi,
    ParsedType.text => parsedTypeText,
    ParsedType.contact => parsedTypeContact,
    ParsedType.phone => parsedTypePhone,
    ParsedType.email => parsedTypeEmail,
    ParsedType.sms => parsedTypeSms,
    ParsedType.geo => parsedTypeGeo,
    ParsedType.event => parsedTypeEvent,
    ParsedType.product => parsedTypeProduct,
    ParsedType.appStore => parsedTypeAppStore,
    ParsedType.unknown => parsedTypeUnknown,
  };

  /// The format a code was read in, e.g. "QR code" (DATA-1, SCAN-9).
  String symbologyLabel(Symbology symbology) => switch (symbology) {
    Symbology.qr => symbologyQr,
    Symbology.dataMatrix => symbologyDataMatrix,
    Symbology.pdf417 => symbologyPdf417,
    Symbology.aztec => symbologyAztec,
    Symbology.code128 => symbologyCode128,
    Symbology.code39 => symbologyCode39,
    Symbology.code93 => symbologyCode93,
    Symbology.codabar => symbologyCodabar,
    Symbology.itf => symbologyItf,
    Symbology.ean13 => symbologyEan13,
    Symbology.ean8 => symbologyEan8,
    Symbology.upcA => symbologyUpcA,
    Symbology.upcE => symbologyUpcE,
    Symbology.unknown => symbologyUnknown,
  };

  /// RES-1's first line: "Link · QR code".
  ///
  /// Typed text was read from no code (SCAN-12), so a [Symbology.unknown]
  /// shows the type alone rather than claiming "Unknown format".
  String typeAndFormat(ParsedType type, Symbology symbology) {
    if (symbology == Symbology.unknown) {
      return parsedTypeLabel(type);
    }
    return resultTypeAndFormat(
      parsedTypeLabel(type),
      symbologyLabel(symbology),
    );
  }

  /// What a screen reader says when a code is detected (A11Y-3): "QR code
  /// detected: Link", or "Link detected" when the format has no name.
  String detectedAnnouncement(ParsedType type, Symbology symbology) {
    if (symbology == Symbology.unknown) {
      return scanTypeDetectedAnnouncement(parsedTypeLabel(type));
    }
    return scanDetectedAnnouncement(
      symbologyLabel(symbology),
      parsedTypeLabel(type),
    );
  }
}

/// The icon a type is drawn with in the multi-code list (SCAN-13) and on the
/// result (RES-1). Always shown next to the type's label, so the type is never
/// told by the icon or its colour alone (A11Y-6).
IconData parsedTypeIcon(ParsedType type) => switch (type) {
  ParsedType.url => Icons.link,
  ParsedType.wifi => Icons.wifi,
  ParsedType.text => Icons.notes,
  ParsedType.contact => Icons.person_outline,
  ParsedType.phone => Icons.phone_outlined,
  ParsedType.email => Icons.email_outlined,
  ParsedType.sms => Icons.sms_outlined,
  ParsedType.geo => Icons.place_outlined,
  ParsedType.event => Icons.event_outlined,
  ParsedType.product => Icons.shopping_bag_outlined,
  ParsedType.appStore => Icons.shop_outlined,
  ParsedType.unknown => Icons.help_outline,
};
