import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('DI Container', () {
    test('container instantiates', () {
      final container = Container();
      expect(container, isNotNull);
    });
  });
}
