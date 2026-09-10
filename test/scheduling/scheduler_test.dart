import 'dart:async';
import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

/// A fake scheduler that captures scheduled actions for manual execution.
class _FakeScheduler implements SchedulerProtocol {
  final List<_FakeTask> tasks = [];

  @override
  CancellableTask schedule(Duration delay, void Function() action) {
    final task = _FakeTask(action);
    tasks.add(task);
    return task;
  }

  void runAll() {
    for (final t in tasks) {
      if (!t.isCancelled) t._action();
    }
    tasks.clear();
  }
}

class _FakeTask implements CancellableTask {
  final void Function() _action;
  bool _cancelled = false;
  _FakeTask(this._action);

  @override
  void cancel() => _cancelled = true;
  @override
  bool get isCancelled => _cancelled;
}

void main() {
  group('DefaultScheduler', () {
    test('executes action after delay', () async {
      final scheduler = DefaultScheduler();
      final completer = Completer<void>();
      scheduler.schedule(const Duration(milliseconds: 10), completer.complete);
      await completer.future.timeout(const Duration(seconds: 1));
    });

    test('cancelled task does not execute', () async {
      final scheduler = DefaultScheduler();
      var ran = false;
      final task = scheduler.schedule(const Duration(milliseconds: 10), () => ran = true);
      task.cancel();
      expect(task.isCancelled, isTrue);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(ran, isFalse);
    });
  });

  group('Debouncer', () {
    test('only fires the last call', () {
      final scheduler = _FakeScheduler();
      final debouncer = Debouncer(const Duration(milliseconds: 100), scheduler: scheduler);
      var count = 0;
      debouncer.call(() => count = 1);
      debouncer.call(() => count = 2);
      debouncer.call(() => count = 3);
      // First two tasks should be cancelled.
      expect(scheduler.tasks.where((t) => !t.isCancelled).length, 1);
      scheduler.runAll();
      expect(count, 3);
    });
  });

  group('Throttler', () {
    test('fires first call, ignores subsequent until cooldown', () {
      final scheduler = _FakeScheduler();
      final throttler = Throttler(const Duration(milliseconds: 100), scheduler: scheduler);
      var count = 0;
      throttler.call(() => count++);
      throttler.call(() => count++); // should be dropped
      expect(count, 1);
      // Reset cooldown manually
      throttler.cancel();
      throttler.call(() => count++);
      expect(count, 2);
    });
  });
}
