import 'package:flutter/material.dart';

/// One text field of a Create form (GEN-1): a label, an inline error
/// (GEN-1), and an optional helper line (GEN-3's added `https://`).
///
/// Owns its own [TextEditingController], seeded once from [initialValue] and
/// never reset by a later build: the generator's state is watched by the
/// form around this field for validation and capacity, which rebuilds this
/// widget on every keystroke, and a controller replaced on every build would
/// throw the cursor to the end of the field as the user types. [onChanged]
/// is the only path back to that state — this field never reads its value
/// from anywhere else once built.
class CreateTextField extends StatefulWidget {
  const CreateTextField({
    required this.initialValue,
    required this.onChanged,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.forceLtr = false,
    this.maxLines = 1,
    this.minLines,
    this.fieldKey,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  /// LANG-5: URLs, numbers, codes and phone numbers stay left to right even
  /// on an Arabic screen.
  final bool forceLtr;
  final int? maxLines;
  final int? minLines;

  /// The key a widget test finds this field by, on the [TextField] itself so
  /// a test can read or set its text directly.
  final Key? fieldKey;

  @override
  State<CreateTextField> createState() => _CreateTextFieldState();
}

class _CreateTextFieldState extends State<CreateTextField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.fieldKey,
      controller: _controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textDirection: widget.forceLtr ? TextDirection.ltr : null,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        helperMaxLines: 3,
        errorText: widget.errorText,
        errorMaxLines: 3,
        border: const OutlineInputBorder(),
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}
