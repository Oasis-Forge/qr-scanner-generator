import '../models/parsed_payload.dart';
import '../models/record_enums.dart';

/// Whether [digits] would build a [Product] for [symbology] (RES-9).
///
/// Only once [digits] is all ASCII digits and exactly the length
/// [symbology] encodes is its GS1 check digit verified; a wrong one means
/// this isn't a product. A shorter, longer or non-digit payload — or
/// [Symbology.upcE], whose zero-suppressed digits this build does not
/// expand to check — is trusted as the scanner reported it, same as before
/// this check existed.
///
/// `classifyPayload` (`lib/models/payload_classifier.dart`) calls this too,
/// so the two can never disagree about whether a payload is a product.
bool isValidProductCode(String digits, Symbology symbology) {
  final int? length = _digitLengthOf(symbology);
  if (length == null ||
      digits.length != length ||
      !_digitsOnly.hasMatch(digits)) {
    return true;
  }
  return hasValidGtinCheckDigit(digits);
}

/// Builds the [Product] for [digits] and [symbology]. Callers check
/// [isValidProductCode] first: this never re-checks the digit.
Product buildProduct(String digits, Symbology symbology) {
  return Product(code: digits, format: _formatOf(digits, symbology));
}

final RegExp _digitsOnly = RegExp(r'^[0-9]+$');

/// The digit count each product symbology's check digit spans. UPC-E has
/// none here: its 6–8 compressed digits need zero-suppression expanded to a
/// UPC-A before its check digit means anything, which this build doesn't do
/// (RES-9).
int? _digitLengthOf(Symbology symbology) => switch (symbology) {
  Symbology.ean13 => 13,
  Symbology.ean8 => 8,
  Symbology.upcA => 12,
  _ => null,
};

/// [ProductCodeFormat.isbn] for an EAN-13 whose digits start `978` or `979`
/// (Bookland), otherwise the format matching [symbology].
ProductCodeFormat _formatOf(String digits, Symbology symbology) {
  if (symbology == Symbology.ean13 &&
      (digits.startsWith('978') || digits.startsWith('979'))) {
    return ProductCodeFormat.isbn;
  }
  return switch (symbology) {
    Symbology.ean8 => ProductCodeFormat.ean8,
    Symbology.upcA => ProductCodeFormat.upcA,
    Symbology.upcE => ProductCodeFormat.upcE,
    _ => ProductCodeFormat.ean13,
  };
}

/// The GS1 mod-10 check (EAN-13, EAN-8, UPC-A): from the digit before the
/// check digit, weights alternate 3, 1, 3, 1 ... right to left. The one copy
/// of the algorithm: the classifier uses it too.
bool hasValidGtinCheckDigit(String digits) {
  if (digits.length < 2) {
    return false;
  }
  var sum = 0;
  var weight = 3;
  for (var i = digits.length - 2; i >= 0; i--) {
    sum += (digits.codeUnitAt(i) - 0x30) * weight;
    weight = weight == 3 ? 1 : 3;
  }
  final int check = (10 - sum % 10) % 10;
  return check == digits.codeUnitAt(digits.length - 1) - 0x30;
}
