import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('StateStore', () {
    test('holds initial state', () {
      final store = StateStore(0);
      expect(store.state, equals(0));
    });
  });
}
