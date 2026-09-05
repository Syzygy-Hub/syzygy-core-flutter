import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('Logger', () {
    test('log level ordering', () {
      expect(LogLevel.debug.index, lessThan(LogLevel.error.index));
    });

    test('console destination writes', () {
      final dest = ConsoleLogDestination();
      dest.write('test', LogLevel.info);
    });
  });
}
