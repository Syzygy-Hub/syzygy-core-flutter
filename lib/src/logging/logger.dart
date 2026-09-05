/// Severity level for log messages.
enum LogLevel { debug, info, warning, error, fatal }

/// A destination that receives formatted log messages.
abstract class LogDestination {
  void write(String message, LogLevel level);
}

/// Console log destination that prints to stdout.
class ConsoleLogDestination implements LogDestination {
  @override
  void write(String message, LogLevel level) {
    // ignore: avoid_print
    print('[${level.name}] $message');
  }
}

/// Logger that routes messages through a pipeline of destinations.
class Logger {
  // TODO: destinations, formatters, pipeline routing, minimum level filtering
}
