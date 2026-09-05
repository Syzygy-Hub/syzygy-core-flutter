/// Environment identifier for configuration switching.
enum Environment { development, staging, production }

/// In-memory configuration registry with typed access and environment switching.
class ConfigRegistry {
  final Environment environment;

  ConfigRegistry({this.environment = Environment.production});

  // TODO: key-value storage, environment-based overlays, typed getters
}
