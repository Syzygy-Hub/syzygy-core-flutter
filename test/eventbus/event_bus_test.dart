import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('EventBus', () {
    test('bus instantiates', () {
      final bus = EventBus();
      expect(bus, isNotNull);
    });
  });
}
