import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart';

// Re-export SyzygyEnvironment so callers importing Core get it directly.
export 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    show SyzygyEnvironment;

/// A typed configuration key with a [name] and [defaultValue].
class ConfigKey<T> {
  /// The unique name for this config entry.
  final String name;

  /// The value returned when no explicit value is set.
  final T defaultValue;

  /// Creates a configuration key.
  const ConfigKey(this.name, {required this.defaultValue});
}

/// In-memory configuration registry with typed access and per-environment overlays.
///
/// Global values apply to all environments. Per-environment values override
/// globals when the matching environment is active.
///
/// ```dart
/// final config = ConfigRegistry(environment: SyzygyEnvironment.debug);
/// const key = ConfigKey<String>('api_url', defaultValue: 'https://prod.api');
/// config.setForEnvironment(key, 'https://dev.api', SyzygyEnvironment.debug);
/// print(config.get(key)); // https://dev.api
/// ```
class ConfigRegistry {
  SyzygyEnvironment _environment;
  final Map<String, Object?> _globalValues = {};
  final Map<SyzygyEnvironment, Map<String, Object?>> _envValues = {};

  /// Creates a registry for the given [environment].
  ConfigRegistry({SyzygyEnvironment environment = SyzygyEnvironment.production})
      : _environment = environment;

  /// The currently active environment.
  SyzygyEnvironment get environment => _environment;

  /// Returns the value for [key], checking environment overrides first,
  /// then global values, then the key's default.
  T get<T>(ConfigKey<T> key) {
    final envMap = _envValues[_environment];
    if (envMap != null && envMap.containsKey(key.name)) {
      final raw = envMap[key.name];
      if (raw is T) return raw;
      throw StateError(
        'Config key "${key.name}" environment value has type '
        '${raw?.runtimeType} but expected $T.',
      );
    }
    if (_globalValues.containsKey(key.name)) {
      final raw = _globalValues[key.name];
      if (raw is T) return raw;
      throw StateError(
        'Config key "${key.name}" global value has type '
        '${raw?.runtimeType} but expected $T.',
      );
    }
    return key.defaultValue;
  }

  /// Sets a global [value] for [key] that applies to all environments.
  void set<T>(ConfigKey<T> key, T value) {
    _globalValues[key.name] = value;
  }

  /// Sets a [value] for [key] that only applies in [environment].
  void setForEnvironment<T>(
    ConfigKey<T> key,
    T value,
    SyzygyEnvironment environment,
  ) {
    _envValues.putIfAbsent(environment, () => {})[key.name] = value;
  }

  /// Switches the active environment, causing subsequent [get] calls to
  /// use that environment's overrides.
  void switchEnvironment(SyzygyEnvironment environment) {
    _environment = environment;
  }
}
