import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    as foundation;

/// Severity level for log messages, ordered from least to most severe.
///
/// Extends Foundation's [foundation.LogLevel] with a Core-only [verbose] level
/// that sits below [debug].
enum LogLevel implements Comparable<LogLevel> {
  /// Extremely detailed tracing information. Core-only; maps to [foundation.LogLevel.debug]
  /// when routing through [foundation.LoggerProtocol].
  verbose,

  /// Diagnostic information useful during development.
  debug,

  /// General informational messages.
  info,

  /// Potentially harmful situations.
  warning,

  /// Error events that might still allow the app to continue.
  error,

  /// Severe errors that will likely cause the app to abort.
  critical;

  @override
  int compareTo(LogLevel other) => index.compareTo(other.index);

  /// Returns true if this level is at least as severe as [other].
  bool operator >=(LogLevel other) => index >= other.index;
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
    LogLevel level,
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
    LogLevel level,
    Map<String, String> metadata, {
    foundation.SyzygyTimestamp? timestamp,
    Object? error,
  }) {
    final ts =
        timestamp != null
            ? ' [${timestamp.toDateTime().toIso8601String()}]'
            : '';
    final meta =
        metadata.isNotEmpty
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
  final LogLevel minLevel;
  _DestinationEntry(this.destination, this.minLevel);
}

/// Routes log messages through registered destinations with level filtering,
/// and implements [foundation.LoggerProtocol] for interoperability.
///
/// Core's [verbose] level is retained as a Core-only extension; it maps to
/// [foundation.LogLevel.debug] when messages arrive via [log(LogEntry)].
///
/// ```dart
/// final logger = Logger();
/// logger.addDestination(ConsoleLogDestination(), minLevel: LogLevel.info);
/// logger.info('Application started');
/// ```
class Logger implements foundation.LoggerProtocol {
  final List<_DestinationEntry> _destinations = [];

  /// Adds a [destination] that receives messages at or above [minLevel].
  void addDestination(
    LogDestination destination, {
    LogLevel minLevel = LogLevel.verbose,
  }) {
    _destinations.add(_DestinationEntry(destination, minLevel));
  }

  // ------------------------------------------------------------------ //
  // Foundation LoggerProtocol implementation                            //
  // ------------------------------------------------------------------ //

  /// Dispatches a Foundation [entry] to all registered Core destinations,
  /// forwarding [foundation.LogEntry.timestamp] and [foundation.LogEntry.error].
  @override
  void log(foundation.LogEntry entry) {
    _dispatch(
      _toCoreLevel(entry.level),
      entry.message,
      entry.metadata,
      timestamp: entry.timestamp,
      error: entry.error,
    );
  }

  // Override Foundation's convenience defaults with Core signatures that
  // also accept a nullable error object for error/critical.

  @override
  void debug(String message, {Map<String, String> metadata = const {}}) =>
      _dispatch(LogLevel.debug, message, metadata);

  @override
  void info(String message, {Map<String, String> metadata = const {}}) =>
      _dispatch(LogLevel.info, message, metadata);

  @override
  void warning(String message, {Map<String, String> metadata = const {}}) =>
      _dispatch(LogLevel.warning, message, metadata);

  @override
  void error(
    String message, {
    Object? error,
    Map<String, String> metadata = const {},
  }) =>
      _dispatch(LogLevel.error, message, metadata, error: error);

  @override
  void critical(
    String message, {
    Object? error,
    Map<String, String> metadata = const {},
  }) =>
      _dispatch(LogLevel.critical, message, metadata, error: error);

  // ------------------------------------------------------------------ //
  // Core-only extensions                                                //
  // ------------------------------------------------------------------ //

  /// Logs a verbose message. Core-only; not part of [foundation.LoggerProtocol].
  void verbose(String message, {Map<String, String>? metadata}) =>
      _dispatch(LogLevel.verbose, message, metadata ?? const {});

  // ------------------------------------------------------------------ //
  // Internal routing                                                    //
  // ------------------------------------------------------------------ //

  void _dispatch(
    LogLevel level,
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

  /// Maps a Foundation [foundation.LogLevel] to Core's [LogLevel].
  static LogLevel _toCoreLevel(foundation.LogLevel level) => switch (level) {
        foundation.LogLevel.debug => LogLevel.debug,
        foundation.LogLevel.info => LogLevel.info,
        foundation.LogLevel.warning => LogLevel.warning,
        foundation.LogLevel.error => LogLevel.error,
        foundation.LogLevel.critical => LogLevel.critical,
      };
}
