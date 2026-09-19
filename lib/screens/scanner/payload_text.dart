import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../models/record_enums.dart';

/// The direction a decoded payload is laid out in (LANG-5).
///
/// Links, numbers, codes, addresses and phone numbers stay left to right in
/// every language, Arabic included. Only a plain-text payload that is itself
/// mostly right-to-left script (an Arabic sentence in a QR code) reads right to
/// left, so its punctuation lands where a reader of that script expects it.
TextDirection payloadDirectionOf(String text, ParsedType type) {
  if (type == ParsedType.text && intl.Bidi.detectRtlDirectionality(text)) {
    return TextDirection.rtl;
  }
  return TextDirection.ltr;
}

/// A payload drawn in its own direction ([payloadDirectionOf]) but aligned to
/// the start of the screen's direction, so a left-to-right link sits on the
/// right edge of an Arabic screen, where the rest of that screen's text
/// starts (LANG-5).
///
/// [selectable] draws it as [SelectableText], the full content RES-1 asks for:
/// never truncated, because it has no line limit.
class PayloadText extends StatelessWidget {
  const PayloadText(
    this.text, {
    required this.type,
    this.selectable = false,
    this.style,
    super.key,
  });

  /// The payload, or a one-line preview of it (SCAN-13).
  final String text;

  /// What the payload was parsed as, which decides its direction.
  final ParsedType type;

  /// Whether the user can select and copy parts of it (RES-1).
  final bool selectable;

  final TextStyle? style;

  /// The direction the text is laid out in, for a test to read.
  TextDirection get direction => payloadDirectionOf(text, type);

  @override
  Widget build(BuildContext context) {
    final TextAlign align = Directionality.of(context) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
    if (selectable) {
      return SelectableText(
        text,
        textDirection: direction,
        textAlign: align,
        style: style,
      );
    }
    return Text(text, textDirection: direction, textAlign: align, style: style);
  }
}
