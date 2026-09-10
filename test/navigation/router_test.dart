import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

class _TestRoute implements Route {
  @override
  final String path;
  @override
  final Map<String, String> parameters;
  _TestRoute(this.path, [this.parameters = const {}]);
}

class _BlockGuard implements RouteGuard {
  final String blockedPath;
  _BlockGuard(this.blockedPath);
  @override
  bool canNavigate(Route to) => to.path != blockedPath;
}

void main() {
  group('Router', () {
    test('push and pop routes', () {
      final router = Router();
      router.push(_TestRoute('/a'));
      router.push(_TestRoute('/b'));
      expect(router.stackDepth, 2);
      expect(router.currentRoute?.path, '/b');
      final popped = router.pop();
      expect(popped?.path, '/b');
      expect(router.currentRoute?.path, '/a');
    });

    test('guard blocks navigation', () {
      final router = Router();
      router.addGuard(_BlockGuard('/secret'));
      expect(router.push(_TestRoute('/secret')), isFalse);
      expect(router.stackDepth, 0);
      expect(router.push(_TestRoute('/public')), isTrue);
      expect(router.stackDepth, 1);
    });

    test('replace replaces top route', () {
      final router = Router();
      router.push(_TestRoute('/a'));
      router.replace(_TestRoute('/b'));
      expect(router.stackDepth, 1);
      expect(router.currentRoute?.path, '/b');
    });

    test('popToRoot keeps only root', () {
      final router = Router();
      router.push(_TestRoute('/root'));
      router.push(_TestRoute('/a'));
      router.push(_TestRoute('/b'));
      router.popToRoot();
      expect(router.stackDepth, 1);
      expect(router.currentRoute?.path, '/root');
    });
  });

  group('DeepLinkParser', () {
    test('parses parameterized URL', () {
      final parser = DeepLinkParser();
      parser.register('/user/:id', (params) => _TestRoute('/user/${params["id"]}', params));
      final route = parser.parse('/user/42');
      expect(route, isNotNull);
      expect(route!.parameters['id'], '42');
    });

    test('returns null for non-matching URL', () {
      final parser = DeepLinkParser();
      parser.register('/home', (params) => _TestRoute('/home'));
      expect(parser.parse('/about'), isNull);
    });
  });
}
