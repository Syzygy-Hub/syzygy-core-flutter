import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('Router', () {
    test('router instantiates', () {
      final router = Router();
      expect(router, isNotNull);
    });
  });
}
