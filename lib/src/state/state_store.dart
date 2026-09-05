/// A reactive store that holds state and notifies observers on change.
class StateStore<State> {
  State _state;

  StateStore(this._state);

  State get state => _state;

  // TODO: reduce, select, observe
}

/// Reduces the current state with an action to produce a new state.
abstract class StateReducer<State, Action> {
  State reduce(State state, Action action);
}
