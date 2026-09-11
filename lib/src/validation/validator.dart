import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart';

// Re-export Foundation validation types so callers importing Core get them.
export 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    show ValidationResult, Valid, Invalid, ValidationRule;

/// Validates that a string value is non-null and non-empty.
class RequiredValidator extends ValidationRule<String?> {
  @override
  ValidationResult validate(String? value) {
    if (value == null || value.isEmpty) {
      return const Invalid(['Value is required.']);
    }
    return const Valid();
  }
}

/// Validates that a string has at least [minLength] characters.
class MinLengthValidator extends ValidationRule<String> {
  /// The minimum allowed length.
  final int minLength;

  /// Creates a validator requiring at least [minLength] characters.
  MinLengthValidator(this.minLength);

  @override
  ValidationResult validate(String value) {
    if (value.length < minLength) {
      return Invalid(['Must be at least $minLength characters.']);
    }
    return const Valid();
  }
}

/// Validates that a string has at most [maxLength] characters.
class MaxLengthValidator extends ValidationRule<String> {
  /// The maximum allowed length.
  final int maxLength;

  /// Creates a validator allowing at most [maxLength] characters.
  MaxLengthValidator(this.maxLength);

  @override
  ValidationResult validate(String value) {
    if (value.length > maxLength) {
      return Invalid(['Must be at most $maxLength characters.']);
    }
    return const Valid();
  }
}

/// Validates that a string looks like an email address.
///
/// Uses a well-formed heuristic pattern. Not RFC 5321 compliant by default.
/// When [strict] is true, applies RFC 5321 constraints:
/// - Local part (before @) must be at most 64 characters.
/// - Total length must be at most 255 characters.
/// - No consecutive dots anywhere.
/// - Local part must not start or end with a dot.
class EmailValidator extends ValidationRule<String> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// When true, applies strict RFC 5321 rules in addition to the basic pattern.
  final bool strict;

  /// Creates an [EmailValidator].
  ///
  /// Set [strict] to true to enable RFC 5321 additional constraints.
  const EmailValidator({this.strict = false});

  @override
  ValidationResult validate(String value) {
    if (!_emailRegex.hasMatch(value)) {
      return const Invalid(['Invalid email address.']);
    }
    if (strict) {
      final atIndex = value.indexOf('@');
      final local = value.substring(0, atIndex);

      if (local.length > 64) {
        return const Invalid(['Local part must be at most 64 characters.']);
      }
      if (value.length > 255) {
        return const Invalid(['Email address must be at most 255 characters.']);
      }
      if (value.contains('..')) {
        return const Invalid(['Email address must not contain consecutive dots.']);
      }
      if (local.startsWith('.') || local.endsWith('.')) {
        return const Invalid(['Local part must not start or end with a dot.']);
      }
    }
    return const Valid();
  }
}

/// Validates that a string matches a given [pattern].
class RegexValidator extends ValidationRule<String> {
  /// The regular expression pattern to match.
  final RegExp pattern;

  /// The message to return when the value does not match.
  final String message;

  /// Creates a regex validator with [pattern] and failure [message].
  RegexValidator(this.pattern, {this.message = 'Invalid format.'});

  @override
  ValidationResult validate(String value) {
    if (!pattern.hasMatch(value)) {
      return Invalid([message]);
    }
    return const Valid();
  }
}

/// Controls how a [ValidationPipeline] processes validators.
enum ValidationMode {
  /// Stops at the first [Invalid] result.
  shortCircuit,

  /// Runs all validators and collects all failures.
  collectAll,
}

/// Chains multiple validators into a pipeline for a value of type [T].
///
/// In [ValidationMode.shortCircuit] mode, returns the first failure.
/// In [ValidationMode.collectAll] mode, merges all failure messages into one [Invalid].
class ValidationPipeline<T> extends ValidationRule<T> {
  /// The validators in this pipeline.
  final List<ValidationRule<T>> validators;

  /// The mode controlling short-circuit vs. collect-all behaviour.
  final ValidationMode mode;

  /// Creates a pipeline with the given [validators] and [mode].
  ValidationPipeline(this.validators, {this.mode = ValidationMode.shortCircuit});

  @override
  ValidationResult validate(T value) {
    final errors = <String>[];
    for (final validator in validators) {
      final result = validator.validate(value);
      if (result is Invalid) {
        if (mode == ValidationMode.shortCircuit) {
          return result;
        }
        errors.addAll(result.messages);
      }
    }
    if (errors.isNotEmpty) {
      return Invalid(errors);
    }
    return const Valid();
  }
}
