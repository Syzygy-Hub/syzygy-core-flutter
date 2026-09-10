/// Defines a feature flag with a typed default value.
///
/// ```dart
/// const darkMode = FeatureFlag<bool>(key: 'dark_mode', defaultValue: false);
/// ```
class FeatureFlag<T> {
  /// The unique key identifying this flag.
  final String key;

  /// The value returned when no override is set.
  final T defaultValue;

  /// A human-readable description of what this flag controls.
  final String description;

  /// Creates a feature flag.
  const FeatureFlag({
    required this.key,
    required this.defaultValue,
    this.description = '',
  });
}

/// Contract for evaluating feature flag values.
abstract class FeatureFlagProvider {
  /// Returns the current value of [flag].
  T value<T>(FeatureFlag<T> flag);
}

/// An in-memory feature flag provider with base values and override support.
///
/// Overrides take precedence over base values, which take precedence over
/// the flag's default value.
///
/// ```dart
/// final flags = InMemoryFeatureFlagProvider();
/// const flag = FeatureFlag<bool>(key: 'beta', defaultValue: false);
/// flags.setValue(flag, true);
/// print(flags.value(flag)); // true
/// ```
class InMemoryFeatureFlagProvider implements FeatureFlagProvider {
  final Map<String, Object?> _values = {};
  final Map<String, Object?> _overrides = {};

  /// Sets the base [value] for a [flag].
  void setValue<T>(FeatureFlag<T> flag, T value) {
    _values[flag.key] = value;
  }

  /// Sets a temporary override [value] for a [flag].
  ///
  /// Overrides take precedence over base values.
  void setOverride<T>(FeatureFlag<T> flag, T value) {
    _overrides[flag.key] = value;
  }

  /// Removes the override for [flag], reverting to the base value.
  void clearOverride<T>(FeatureFlag<T> flag) {
    _overrides.remove(flag.key);
  }

  @override
  T value<T>(FeatureFlag<T> flag) {
    if (_overrides.containsKey(flag.key)) {
      return _overrides[flag.key] as T;
    }
    if (_values.containsKey(flag.key)) {
      return _values[flag.key] as T;
    }
    return flag.defaultValue;
  }
}
