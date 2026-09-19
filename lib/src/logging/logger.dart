import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    as foundation;

// TODO(v1.2.0): add a Core-only verbose tier once Foundation 1.2.0 ships its
// equivalent.  Until then, Logger.verbose() maps to foundation.LogLevel.debug.

/// Adds a `>=` comparison operator to Foundation's [foundation.LogLevel]
/// for use in Core's level-filtering logic.
extension FoundationLogLevelComparison on foundation.LogLevel {
  /// Returns true if this level is at least as severe as [other].
  bool operator >=(foundation.LogLevel other) => severity >= other.severity;
}

/// A destination that receives formatted log messages.
abstract class LogDestination {
  /// Writes a log [message] at the given [level] with optional [metadata].
  ///
  /// [timestamp] is the point-in-time the message was generated; it is null
  /// when the message originates from Core convenience methods rather than a
  /// Foundation [foundation.LogEntry].
  ///
  /// [error] carries an associated exception or error object, if any.
  void write(
    String message,
    foundation.LogLevel level,
    Map<String, String> metadata, {
    foundation.SyzygyTimestamp? timestamp,
    Object? error,
  });
}

/// A log destination that prints to stdout.
class ConsoleLogDestination implements LogDestination {
  @override
  void write(
    String message,
    foundation.LogLevel level,
    Map<String, String> metadata, {
    foundation.SyzygyTimestamp? timestamp,
    Object? error,
  }) {
    final ts = timestamp != null
        ? ' [${timestamp.toDateTime().toIso8601String()}]'
        : '';
    final meta = metadata.isNotEmpty
        ? ' ${metadata.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';
    // ignore: avoid_print
    print('[${level.name.toUpperCase()}]$ts $message$meta');
    if (error != null) {
      // ignore: avoid_print
      print('  error: $error');
    }
  }
}

class _DestinationEntry {
  final LogDestination destination;
  final foundation.LogLevel minLevel;
  _DestinationEntry(this.destination, this.minLevel);
}

/// Routes log messages through registered destinations with level filtering,
/// and implements [foundation.LoggerProtocol] for interoperability.
///
/// Because [foundation.LogLevel] is now the public level type, no translation
/// is needed when messages arrive via [log(LogEntry)].  The Core-only
/// [verbose] convenience method maps to [foundation.LogLevel.debug] at
/// the destination boundary.
///
/// ```dart
/// final logger = Logger();
/// logger.addDestination(ConsoleLogDestination(), minLevel: LogLevel.info);
/// logger.info('Application started');
/// ```
class Logger implements foundation.LoggerProtocol {
  final List<_DestinationEntry> _destinations = [];

  /// Adds a [destination] that receives messages at or above [minLevel].
  /// Defaults to [foundation.LogLevel.debug], the most permissive
  /// Foundation level.
  void addDestination(
    LogDestination destination, {
    foundation.LogLevel minLevel = foundation.LogLevel.debug,
  }) {
    _destinations.add(_DestinationEntry(destination, minLevel));
  }

  // ------------------------------------------------------------------ //
  // Foundation LoggerProtocol implementation                            //
  // ------------------------------------------------------------------ //

  /// Dispatches a Foundation [entry] to all registered Core destinations.
  /// No level translation is required because [foundation.LogLevel] is
  /// the public type.
  @override
  void log(foundation.LogEntry entry) {
    _dispatch(
      entry.level,
      entry.message,
      entry.metadata,
      timestamp: entry.timestamp,
      error: entry.error,
    );
  }

  // Override Foundation's convenience defaults.

  @override
  void debug(String message, {Map<String, String> metadata = const {}}) =>
      _dispatch(foundation.LogLevel.debug, message, metadata);

  @override
  void info(String message, {Map<String, String> metadata = const {}}) =>
      _dispatch(foundation.LogLevel.info, message, metadata);

  @override
  void warning(String message, {Map<String, String> metadata = const {}}) =>
      _dispatch(foundation.LogLevel.warning, message, metadata);

  @override
  void error(
    String message, {
    Object? error,
    Map<String, String> metadata = const {},
  }) =>
      _dispatch(foundation.LogLevel.error, message, metadata, error: error);

  @override
  void critical(
    String message, {
    Object? error,
    Map<String, String> metadata = const {},
  }) =>
      _dispatch(foundation.LogLevel.critical, message, metadata, error: error);

  // ------------------------------------------------------------------ //
  // Core-only extensions                                                //
  // ------------------------------------------------------------------ //

  /// Logs a verbose message. Core-only; not part of [foundation.LoggerProtocol].
  // verbose maps to foundation.LogLevel.debug until Foundation v1.2.0
  // adds LogLevel.verbose. Verbose-only log destinations will receive
  // debug-level entries.
  // TODO(Foundation-v1.2.0): update to LogLevel.verbose.
  /// Dispatched as [foundation.LogLevel.debug] to all registered destinations.
  void verbose(String message, {Map<String, String>? metadata}) =>
      _dispatch(foundation.LogLevel.debug, message, metadata ?? const {});

  // ------------------------------------------------------------------ //
  // Internal routing                                                    //
  // ------------------------------------------------------------------ //

  void _dispatch(
    foundation.LogLevel level,
    String message,
    Map<String, String> meta, {
    foundation.SyzygyTimestamp? timestamp,
    Object? error,
  }) {
    for (final entry in _destinations) {
      if (level >= entry.minLevel) {
        entry.destination.write(
          message,
          level,
          meta,
          timestamp: timestamp,
          error: error,
        );
      }
    }
  }
}
