import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('FeatureFlagProvider', () {
    const flag = FeatureFlag<bool>(key: 'dark', defaultValue: false, description: 'Dark mode');

    test('returns default when no value set', () {
      final provider = InMemoryFeatureFlagProvider();
      expect(provider.value(flag), isFalse);
    });

    test('returns set value', () {
      final provider = InMemoryFeatureFlagProvider();
      provider.setValue(flag, true);
      expect(provider.value(flag), isTrue);
    });

    test('override takes precedence over set value', () {
      final provider = InMemoryFeatureFlagProvider();
      provider.setValue(flag, false);
      provider.setOverride(flag, true);
      expect(provider.value(flag), isTrue);
    });

    test('clearOverride reverts to base value', () {
      final provider = InMemoryFeatureFlagProvider();
      provider.setValue(flag, true);
      provider.setOverride(flag, false);
      expect(provider.value(flag), isFalse);
      provider.clearOverride(flag);
      expect(provider.value(flag), isTrue);
    });

    test('works with different types', () {
      final provider = InMemoryFeatureFlagProvider();
      const intFlag = FeatureFlag<int>(key: 'max', defaultValue: 10);
      provider.setValue(intFlag, 42);
      expect(provider.value(intFlag), 42);
    });
  });
}
