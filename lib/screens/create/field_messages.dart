import '../../generator/generator_field_error.dart';
import '../../l10n/app_localizations.dart';

/// Translated messages for [GeneratorFieldError] (GEN-1), the same pattern
/// `code_labels.dart` and `result_labels.dart` use for their own enums.
///
/// One message per error code, never per field: [GeneratorFieldError] itself
/// carries no field identity, and the field's own label already says which
/// field is wrong, so "This field is required." under the network name field
/// reads the same as it would under any other.
extension GeneratorFieldErrorMessages on AppLocalizations {
  /// The inline message a Create form shows under a field, or null once
  /// [error] is null (the field validates).
  String? generatorFieldErrorMessage(GeneratorFieldError? error) =>
      switch (error) {
        null => null,
        GeneratorFieldError.required => createFieldErrorRequired,
        GeneratorFieldError.invalidScheme => createFieldErrorInvalidUrl,
        GeneratorFieldError.invalidEmail => createFieldErrorInvalidEmail,
        GeneratorFieldError.invalidPhone => createFieldErrorInvalidPhone,
      };
}
