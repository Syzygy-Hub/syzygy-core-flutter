/// Application lifecycle state.
enum AppLifecycleState {
  /// The app is visible and responding to user input.
  active,

  /// The app is visible but not receiving input (e.g. phone call overlay).
  inactive,

  /// The app is not visible (running in the background).
  background,

  /// The app is being terminated.
  terminated,
}

/// An observer that receives lifecycle change notifications.
abstract class AppLifecycleObserver {
  /// Called when the lifecycle transitions to [state].
  void onLifecycleChange(AppLifecycleState state);
}

/// Tracks the application lifecycle state and notifies registered observers.
///
/// ```dart
/// final tracker = AppLifecycleTracker();
/// tracker.addObserver(myObserver);
/// tracker.transition(AppLifecycleState.background);
/// ```
class AppLifecycleTracker {
  AppLifecycleState _currentState = AppLifecycleState.active;
  final List<AppLifecycleObserver> _observers = [];

  /// The current lifecycle state.
  AppLifecycleState get currentState => _currentState;

  /// Adds an [observer] to receive lifecycle notifications.
  void addObserver(AppLifecycleObserver observer) {
    _observers.add(observer);
  }

  /// Removes a previously added [observer].
  void removeObserver(AppLifecycleObserver observer) {
    _observers.remove(observer);
  }

  /// Transitions to [state] and notifies all observers.
  ///
  /// If the state is the same as the current state, observers are not notified.
  void transition(AppLifecycleState state) {
    if (_currentState == state) return;
    _currentState = state;
    for (final observer in List.of(_observers)) {
      observer.onLifecycleChange(state);
    }
  }
}
