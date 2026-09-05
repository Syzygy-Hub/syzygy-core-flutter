/// Result of a single validation check.
sealed class ValidationResult {}

class Valid extends ValidationResult {}

class Invalid extends ValidationResult {
  final String message;
  Invalid(this.message);
}

/// A composable validator for a single field value.
abstract class FieldValidator<T> {
  ValidationResult validate(T value);
}

/// Chains multiple validators into a pipeline.
class ValidationPipeline<T> implements FieldValidator<T> {
  final List<FieldValidator<T>> validators;

  ValidationPipeline(this.validators);

  // TODO: short-circuit / collect-all modes
  @override
  ValidationResult validate(T value) => Valid();
}
