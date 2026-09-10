/// A cancellable handle for an event bus subscription.
///
/// Call [cancel] to stop receiving events.
class SubscriptionToken {
  final void Function() _onCancel;
  bool _cancelled = false;

  SubscriptionToken._(this._onCancel);

  /// Cancels the subscription. Subsequent events will not be delivered.
  void cancel() {
    if (!_cancelled) {
      _cancelled = true;
      _onCancel();
    }
  }

  /// Whether this subscription has been cancelled.
  bool get isCancelled => _cancelled;
}

/// A typed publish/subscribe event bus for decoupled communication.
///
/// Events are dispatched synchronously to all subscribers of the matching type.
///
/// ```dart
/// final bus = EventBus();
/// bus.subscribe<String>((e) => print(e));
/// bus.publish('hello');
/// ```
class EventBus {
  final Map<Type, List<_Subscription>> _subscriptions = {};
  bool _disposed = false;

  /// Publishes an [event] to all subscribers of type [E].
  ///
  /// Throws [StateError] if the bus has been disposed.
  void publish<E>(E event) {
    if (_disposed) {
      throw StateError('Cannot publish on a disposed EventBus.');
    }
    final subs = _subscriptions[E];
    if (subs == null) return;
    // Iterate over a copy so handlers can cancel during iteration.
    for (final sub in List.of(subs)) {
      if (!sub.token.isCancelled) {
        (sub.handler as void Function(E))(event);
      }
    }
  }

  /// Subscribes [handler] to events of type [E].
  ///
  /// Returns a [SubscriptionToken] to cancel the subscription.
  SubscriptionToken subscribe<E>(void Function(E) handler) {
    if (_disposed) {
      throw StateError('Cannot subscribe on a disposed EventBus.');
    }
    final subs = _subscriptions.putIfAbsent(E, () => []);
    late final _Subscription sub;
    final token = SubscriptionToken._(() {
      subs.remove(sub);
    });
    sub = _Subscription(handler, token);
    subs.add(sub);
    return token;
  }

  /// Disposes the bus, cancelling all subscriptions.
  void dispose() {
    _disposed = true;
    for (final subs in _subscriptions.values) {
      for (final sub in List.of(subs)) {
        sub.token.cancel();
      }
    }
    _subscriptions.clear();
  }
}

class _Subscription {
  final Function handler;
  final SubscriptionToken token;
  _Subscription(this.handler, this.token);
}
