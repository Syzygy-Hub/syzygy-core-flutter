/// A navigable route with a path and parameters.
abstract class Route {
  /// The path component of this route (e.g. '/home').
  String get path;

  /// Parameters extracted from the route (e.g. path or query params).
  Map<String, String> get parameters;
}

/// A guard that can allow or deny navigation to a route.
abstract class RouteGuard {
  /// Returns true if navigation to [to] is allowed.
  bool canNavigate(Route to);
}

/// Manages a navigation stack with route guards.
///
/// Guards are evaluated in order; if any guard denies navigation,
/// the operation is rejected.
///
/// ```dart
/// final router = Router();
/// router.push(HomeRoute());
/// router.push(DetailRoute(id: '42'));
/// router.pop();
/// ```
class Router {
  final List<Route> _stack = [];
  final List<RouteGuard> _guards = [];

  /// The currently active route, or null if the stack is empty.
  Route? get currentRoute => _stack.isNotEmpty ? _stack.last : null;

  /// The number of routes currently on the stack.
  int get stackDepth => _stack.length;

  /// Pushes [route] onto the stack if all guards allow it.
  ///
  /// Returns true if the navigation succeeded.
  bool push(Route route) {
    if (!_checkGuards(route)) return false;
    _stack.add(route);
    return true;
  }

  /// Pops the top route from the stack.
  ///
  /// Returns the popped route, or null if the stack is empty.
  Route? pop() {
    if (_stack.isEmpty) return null;
    return _stack.removeLast();
  }

  /// Pops all routes except the first (root) route.
  void popToRoot() {
    if (_stack.length <= 1) return;
    final root = _stack.first;
    _stack.clear();
    _stack.add(root);
  }

  /// Replaces the top route with [route] if all guards allow it.
  ///
  /// Returns true if the replacement succeeded.
  bool replace(Route route) {
    if (!_checkGuards(route)) return false;
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
    _stack.add(route);
    return true;
  }

  /// Adds a [guard] that will be consulted on every navigation.
  void addGuard(RouteGuard guard) {
    _guards.add(guard);
  }

  bool _checkGuards(Route route) {
    for (final guard in _guards) {
      if (!guard.canNavigate(route)) return false;
    }
    return true;
  }
}

/// Parses deep link URLs into [Route] instances using registered patterns.
///
/// Patterns use `:param` syntax for path parameters.
///
/// ```dart
/// final parser = DeepLinkParser();
/// parser.register('/user/:id', (params) => UserRoute(params['id']!));
/// final route = parser.parse('/user/42');
/// ```
class DeepLinkParser {
  final List<_PatternEntry> _patterns = [];

  /// Registers a URL [pattern] and a [routeFactory] to create a route
  /// from extracted parameters.
  void register(
    String pattern,
    Route Function(Map<String, String>) routeFactory,
  ) {
    _patterns.add(_PatternEntry(pattern, routeFactory));
  }

  /// Attempts to parse a [url] into a [Route].
  ///
  /// Returns null if no registered pattern matches.
  Route? parse(String url) {
    // Strip scheme/host if present.
    String path;
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      path = uri.path;
    } else {
      path = url;
    }

    for (final entry in _patterns) {
      final params = entry.match(path);
      if (params != null) {
        return entry.routeFactory(params);
      }
    }
    return null;
  }
}

class _PatternEntry {
  final String pattern;
  final Route Function(Map<String, String>) routeFactory;
  final List<String> _segments;
  final List<String?> _paramNames;

  _PatternEntry(this.pattern, this.routeFactory)
      : _segments = pattern.split('/').where((s) => s.isNotEmpty).toList(),
        _paramNames =
            pattern
                .split('/')
                .where((s) => s.isNotEmpty)
                .map((s) => s.startsWith(':') ? s.substring(1) : null)
                .toList();

  Map<String, String>? match(String path) {
    final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (pathSegments.length != _segments.length) return null;

    final params = <String, String>{};
    for (var i = 0; i < _segments.length; i++) {
      final paramName = _paramNames[i];
      if (paramName != null) {
        params[paramName] = pathSegments[i];
      } else if (_segments[i] != pathSegments[i]) {
        return null;
      }
    }
    return params;
  }
}
