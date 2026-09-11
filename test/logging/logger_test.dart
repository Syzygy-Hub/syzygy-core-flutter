import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';
import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    as foundation;

class _TestDestination implements LogDestination {
  final List<
    (
      String,
      LogLevel,
      Map<String, String>,
      foundation.SyzygyTimestamp?,
      Object?,
    )
  > messages = [];

  @override
  void write(
    String message,
    LogLevel level,
    Map<String, String> metadata, {
    foundation.SyzygyTimestamp? timestamp,
    Object? error,
  }) {
    messages.add((message, level, metadata, timestamp, error));
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

    // FIX 8 — Foundation LogEntry path tests

    test('log(LogEntry) maps all 5 Foundation LogLevels to correct Core LogLevels', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest);

      final ts = foundation.SyzygyTimestamp.now();
      final pairs = [
        (foundation.LogLevel.debug, LogLevel.debug),
        (foundation.LogLevel.info, LogLevel.info),
        (foundation.LogLevel.warning, LogLevel.warning),
        (foundation.LogLevel.error, LogLevel.error),
        (foundation.LogLevel.critical, LogLevel.critical),
      ];

      for (final (fLevel, cLevel) in pairs) {
        dest.messages.clear();
        logger.log(
          foundation.LogEntry(
            level: fLevel,
            message: 'test',
            timestamp: ts,
          ),
        );
        expect(dest.messages.first.$2, cLevel,
            reason: 'Foundation ${fLevel.name} should map to Core ${cLevel.name}');
      }
    });

    test('log(LogEntry) forwards metadata', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest);

      logger.log(
        foundation.LogEntry(
          level: foundation.LogLevel.info,
          message: 'meta test',
          timestamp: foundation.SyzygyTimestamp.now(),
          metadata: {'k': 'v', 'x': 'y'},
        ),
      );

      expect(dest.messages.first.$3, {'k': 'v', 'x': 'y'});
    });

    test('log(LogEntry) forwards timestamp to destination', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest);

      final ts = foundation.SyzygyTimestamp(1000000);
      logger.log(
        foundation.LogEntry(
          level: foundation.LogLevel.info,
          message: 'ts test',
          timestamp: ts,
        ),
      );

      expect(dest.messages.first.$4, ts);
    });

    test('log(LogEntry) forwards error to destination', () {
      final logger = Logger();
      final dest = _TestDestination();
      logger.addDestination(dest);

      final err = Exception('boom');
      logger.log(
        foundation.LogEntry(
          level: foundation.LogLevel.error,
          message: 'err test',
          timestamp: foundation.SyzygyTimestamp.now(),
          error: err,
        ),
      );

      expect(dest.messages.first.$5, err);
    });
  });
}
