import 'dart:async';

/// A function that produces a new state from the current [state] and an [action].
typedef StateReducer<S, A> = S Function(S state, A action);

/// A reactive store that holds application state and emits changes.
///
/// Uses a reducer function to process dispatched actions into new state.
/// Observers receive state updates via [stream] or the [select] projection.
///
/// ```dart
/// final store = StateStore<int, String>(0, reducer: (s, a) => a == 'inc' ? s + 1 : s);
/// store.stream.listen(print);
/// store.dispatch('inc');
/// ```
class StateStore<S, A> {
  S _state;
  final StateReducer<S, A> _reducer;
  final StreamController<S> _controller = StreamController<S>.broadcast();
  bool _disposed = false;

  /// Creates a store with [initialState] and the given [reducer].
  StateStore(S initialState, {required StateReducer<S, A> reducer})
      : _state = initialState,
        _reducer = reducer;

  /// The current state value.
  S get state => _state;

  /// A broadcast stream of state changes.
  Stream<S> get stream => _controller.stream;

  /// Dispatches an [action] through the reducer to produce a new state.
  ///
  /// If the state changes (by identity), the new state is emitted on [stream].
  /// Throws [StateError] if the store has been disposed.
  void dispatch(A action) {
    if (_disposed) {
      throw StateError('Cannot dispatch on a disposed StateStore.');
    }
    final newState = _reducer(_state, action);
    if (!identical(newState, _state)) {
      _state = newState;
      _controller.add(_state);
    }
  }

  /// Returns a stream of distinct projected values derived from state.
  ///
  /// The [selector] maps each state to a value of type [T].
  /// Only emits when the selected value changes.
  Stream<T> select<T>(T Function(S) selector) {
    return stream.map(selector).distinct();
  }

  /// Closes the stream and releases resources.
  void dispose() {
    _disposed = true;
    _controller.close();
  }
}
