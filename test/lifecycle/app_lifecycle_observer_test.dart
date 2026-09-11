import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';
import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart';

class _TestObserver implements AppLifecycleObserver {
  final List<AppLifecycleState> changes = [];
  @override
  void onLifecycleChange(AppLifecycleState state) => changes.add(state);
}

void main() {
  group('AppLifecycleTracker', () {
    test('starts in active state', () {
      final tracker = AppLifecycleTracker();
      expect(tracker.currentState, AppLifecycleState.active);
    });

    test('notifies observers on transition', () {
      final tracker = AppLifecycleTracker();
      final observer = _TestObserver();
      tracker.addObserver(observer);
      tracker.transition(AppLifecycleState.background);
      expect(observer.changes, [AppLifecycleState.background]);
      expect(tracker.currentState, AppLifecycleState.background);
    });

    test('does not notify on same-state transition', () {
      final tracker = AppLifecycleTracker();
      final observer = _TestObserver();
      tracker.addObserver(observer);
      tracker.transition(AppLifecycleState.active); // same as initial
      expect(observer.changes, isEmpty);
    });

    test('removeObserver stops notifications', () {
      final tracker = AppLifecycleTracker();
      final observer = _TestObserver();
      tracker.addObserver(observer);
      tracker.removeObserver(observer);
      tracker.transition(AppLifecycleState.inactive);
      expect(observer.changes, isEmpty);
    });

    test('supports terminated state', () {
      final tracker = AppLifecycleTracker();
      final observer = _TestObserver();
      tracker.addObserver(observer);
      tracker.transition(AppLifecycleState.terminated);
      expect(tracker.currentState, AppLifecycleState.terminated);
    });

    test('lastTransitionAt is null before any transition', () {
      final tracker = AppLifecycleTracker();
      expect(tracker.lastTransitionAt, isNull);
    });

    test('lastTransitionAt is recorded on transition', () {
      final tracker = AppLifecycleTracker();
      final before = SyzygyTimestamp.now();
      tracker.transition(AppLifecycleState.background);
      final after = SyzygyTimestamp.now();
      expect(tracker.lastTransitionAt, isNotNull);
      expect(
        tracker.lastTransitionAt!.millisecondsSinceEpoch,
        greaterThanOrEqualTo(before.millisecondsSinceEpoch),
      );
      expect(
        tracker.lastTransitionAt!.millisecondsSinceEpoch,
        lessThanOrEqualTo(after.millisecondsSinceEpoch),
      );
    });

    test('lastTransitionAt is not updated on same-state transition', () {
      final tracker = AppLifecycleTracker();
      tracker.transition(AppLifecycleState.active); // same state — no-op
      expect(tracker.lastTransitionAt, isNull);
    });
  });
}
