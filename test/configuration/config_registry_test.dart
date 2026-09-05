import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('ConfigRegistry', () {
    test('registry instantiates with environment', () {
      final registry = ConfigRegistry(environment: Environment.development);
      expect(registry, isNotNull);
    });
  });
}
