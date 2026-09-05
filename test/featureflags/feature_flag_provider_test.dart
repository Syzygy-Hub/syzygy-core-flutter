import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('FeatureFlagProvider', () {
    test('flag holds default value', () {
      final flag = FeatureFlag(key: 'dark_mode', defaultValue: false);
      expect(flag.defaultValue, isFalse);
    });
  });
}
