import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('Validation', () {
    test('valid result is Valid', () {
      final result = Valid();
      expect(result, isA<Valid>());
    });
  });
}
