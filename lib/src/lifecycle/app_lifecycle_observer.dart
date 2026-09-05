/// Application lifecycle state.
enum AppLifecycleState { active, inactive, background }

/// Observes app lifecycle transitions.
abstract class AppLifecycleObserver {
  void onStateChange(AppLifecycleState state);
}

/// Tracks the app's current lifecycle state and notifies registered observers.
class AppLifecycleTracker {
  // TODO: observer registry, state tracking, lifecycle-aware scoping
}
