import 'dart:async';

/// A cancellable handle for a scheduled operation.
abstract class CancellableTask {
  /// Cancels the scheduled operation.
  void cancel();

  /// Whether the task has been cancelled.
  bool get isCancelled;
}

/// Contract for scheduling delayed operations.
abstract class SchedulerProtocol {
  /// Schedules [action] to run after [delay].
  ///
  /// Returns a [CancellableTask] to cancel the pending action.
  CancellableTask schedule(Duration delay, void Function() action);
}

/// A [CancellableTask] backed by a Dart [Timer].
class _TimerTask implements CancellableTask {
  Timer? _timer;
  bool _cancelled = false;

  _TimerTask(Duration delay, void Function() action) {
    _timer = Timer(delay, () {
      if (!_cancelled) {
        action();
      }
    });
  }

  @override
  void cancel() {
    _cancelled = true;
    _timer?.cancel();
  }

  @override
  bool get isCancelled => _cancelled;
}

/// Default scheduler implementation using Dart [Timer]s.
class DefaultScheduler implements SchedulerProtocol {
  @override
  CancellableTask schedule(Duration delay, void Function() action) {
    return _TimerTask(delay, action);
  }
}

/// Debounces calls so only the last invocation within [delay] fires.
///
/// ```dart
/// final debouncer = Debouncer(Duration(milliseconds: 300));
/// debouncer.call(() => search(query));
/// ```
class Debouncer {
  final Duration _delay;
  final SchedulerProtocol _scheduler;
  CancellableTask? _pending;

  /// Creates a debouncer with the given [delay] and optional [scheduler].
  Debouncer(Duration delay, {SchedulerProtocol? scheduler})
      : _delay = delay,
        _scheduler = scheduler ?? DefaultScheduler();

  /// Schedules [action] to run after the delay, cancelling any pending call.
  void call(void Function() action) {
    _pending?.cancel();
    _pending = _scheduler.schedule(_delay, action);
  }

  /// Cancels any pending debounced action.
  void cancel() {
    _pending?.cancel();
    _pending = null;
  }
}

/// Throttles calls so at most one invocation fires per [interval].
///
/// The first call fires immediately; subsequent calls within the interval
/// are dropped. Once the cooldown period elapses, the next call fires again.
///
/// ```dart
/// final throttler = Throttler(Duration(milliseconds: 500));
/// throttler.call(() => saveScroll(position));
/// ```
class Throttler {
  final Duration _interval;
  final SchedulerProtocol _scheduler;

  /// Injectable clock function for deterministic testing. Defaults to
  /// [DateTime.now]. The scheduler governs actual delay timing; [clock] may
  /// be used by callers to inspect or record the current time in tests.
  final DateTime Function() clock;

  CancellableTask? _cooldown;
  bool _inCooldown = false;

  /// Creates a throttler with the given [interval], optional [scheduler], and
  /// optional [clock] (defaults to [DateTime.now]).
  Throttler(
    Duration interval, {
    SchedulerProtocol? scheduler,
    DateTime Function()? clock,
  })  : _interval = interval,
        _scheduler = scheduler ?? DefaultScheduler(),
        clock = clock ?? DateTime.now;

  /// Executes [action] if no cooldown is active, then starts the cooldown.
  void call(void Function() action) {
    if (_inCooldown) return;
    action();
    _inCooldown = true;
    _cooldown = _scheduler.schedule(_interval, () {
      _inCooldown = false;
    });
  }

  /// Cancels the cooldown, allowing the next call to fire immediately.
  void cancel() {
    _cooldown?.cancel();
    _cooldown = null;
    _inCooldown = false;
  }
}
