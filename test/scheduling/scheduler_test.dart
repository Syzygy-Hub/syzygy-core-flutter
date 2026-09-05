import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('Scheduler', () {
    test('scheduler instantiates', () {
      final scheduler = Scheduler();
      expect(scheduler, isNotNull);
    });
  });
}
