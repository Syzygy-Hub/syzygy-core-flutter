import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

class _TestDestination implements LogDestination {
  final List<(String, LogLevel, Map<String, String>)> messages = [];

  @override
  void write(String message, LogLevel level, Map<String, String> metadata) {
    messages.add((message, level, metadata));
  }
}

void main() {
  group('Logger', () {
    test('routes messages to destinations', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest);
      logger.info('hello');
      expect(dest.messages.length, 1);
      expect(dest.messages.first.$1, 'hello');
      expect(dest.messages.first.$2, LogLevel.info);
    });

    test('filters by minimum level', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest, minLevel: LogLevel.warning);
      logger.debug('skip');
      logger.warning('keep');
      expect(dest.messages.length, 1);
      expect(dest.messages.first.$2, LogLevel.warning);
    });

    test('convenience methods use correct levels', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest);
      logger.verbose('v');
      logger.debug('d');
      logger.critical('c');
      expect(dest.messages.map((m) => m.$2).toList(), [
        LogLevel.verbose,
        LogLevel.debug,
        LogLevel.critical,
      ]);
    });

    test('passes metadata through', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest);
      logger.info('msg', metadata: {'key': 'val'});
      expect(dest.messages.first.$3, {'key': 'val'});
    });

    test('LogLevel comparison works correctly', () {
      expect(LogLevel.error >= LogLevel.debug, isTrue);
      expect(LogLevel.debug >= LogLevel.error, isFalse);
      expect(LogLevel.info.compareTo(LogLevel.warning), isNegative);
    });
  });
}
