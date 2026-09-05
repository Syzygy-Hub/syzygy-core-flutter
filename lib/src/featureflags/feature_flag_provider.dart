/// Defines a feature flag with a key and default value.
class FeatureFlag<T> {
  final String key;
  final T defaultValue;

  const FeatureFlag({required this.key, required this.defaultValue});
}

/// Provides feature flag evaluation with local overrides and variant selection.
class FeatureFlagProvider {
  // TODO: evaluation rules, override storage, A/B variant selection
}
