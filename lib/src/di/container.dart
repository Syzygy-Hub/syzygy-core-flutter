/// Lifetime scope for a registered dependency.
enum Lifetime {
  /// A single instance is created and reused for all resolutions.
  singleton,

  /// A new instance is created on every resolution.
  transient,

  /// A single instance per child container scope.
  scoped,
}

/// A registration entry in the container.
class _Registration<T> {
  final Lifetime lifetime;
  final T Function(Container) factory;
  T? _singletonInstance;

  _Registration(this.lifetime, this.factory);
}

/// Synchronous dependency injection container with lifetime management
/// and circular dependency detection.
///
/// Supports parent-child relationships for scoped lifetimes.
/// ```dart
/// final container = Container();
/// container.register<MyService>(Lifetime.singleton, (c) => MyServiceImpl());
/// final service = container.resolve<MyService>();
/// ```
class Container {
  final Container? _parent;
  final Map<Type, _Registration> _registrations = {};
  final Map<Type, Object?> _scopedInstances = {};
  final Set<Type> _resolving = {};

  /// Creates a new container, optionally as a child of [parent].
  Container({Container? parent}) : _parent = parent;

  /// Registers a factory for type [T] with the given [lifetime].
  ///
  /// Throws [StateError] if [T] is already registered in this container.
  void register<T>(Lifetime lifetime, T Function(Container) factory) {
    if (_registrations.containsKey(T)) {
      throw StateError('Type $T is already registered.');
    }
    _registrations[T] = _Registration<T>(lifetime, factory);
  }

  /// Resolves an instance of type [T].
  ///
  /// Throws [StateError] if [T] is not registered or if a circular
  /// dependency is detected.
  T resolve<T>() {
    return _resolve<T>(T);
  }

  T _resolve<T>(Type type) {
    // Check for circular dependency.
    if (_resolving.contains(type)) {
      throw StateError('Circular dependency detected while resolving $type.');
    }

    final registration = _findRegistration(type);
    if (registration == null) {
      throw StateError('Type $type is not registered.');
    }

    switch (registration.lifetime) {
      case Lifetime.singleton:
        if (registration._singletonInstance != null) {
          return registration._singletonInstance as T;
        }
        _resolving.add(type);
        try {
          final instance = registration.factory(_rootContainer) as T;
          registration._singletonInstance = instance;
          return instance;
        } finally {
          _resolving.remove(type);
        }

      case Lifetime.transient:
        _resolving.add(type);
        try {
          return registration.factory(this) as T;
        } finally {
          _resolving.remove(type);
        }

      case Lifetime.scoped:
        if (_scopedInstances.containsKey(type)) {
          return _scopedInstances[type] as T;
        }
        _resolving.add(type);
        try {
          final instance = registration.factory(this) as T;
          _scopedInstances[type] = instance;
          return instance;
        } finally {
          _resolving.remove(type);
        }
    }
  }

  Container get _rootContainer {
    Container c = this;
    while (c._parent != null) {
      c = c._parent!;
    }
    return c;
  }

  _Registration? _findRegistration(Type type) {
    if (_registrations.containsKey(type)) {
      return _registrations[type];
    }
    return _parent?._findRegistration(type);
  }

  /// Creates a child container that inherits registrations from this container.
  ///
  /// Scoped registrations resolved in the child will have their own instances.
  Container createChildContainer() {
    return Container(parent: this);
  }
}
