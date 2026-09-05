import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('AppLifecycleTracker', () {
    test('tracker instantiates', () {
      final tracker = AppLifecycleTracker();
      expect(tracker, isNotNull);
    });
  });
}
