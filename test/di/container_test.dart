import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('Container', () {
    test('registers and resolves a transient dependency', () {
      final container = Container();
      var count = 0;
      container.register<String>(Lifetime.transient, (_) => 'instance_${++count}');
      expect(container.resolve<String>(), 'instance_1');
      expect(container.resolve<String>(), 'instance_2');
    });

    test('singleton returns the same instance', () {
      final container = Container();
      container.register<List<int>>(Lifetime.singleton, (_) => <int>[]);
      final a = container.resolve<List<int>>();
      final b = container.resolve<List<int>>();
      expect(identical(a, b), isTrue);
    });

    test('scoped returns same instance in child, different across children', () {
      final container = Container();
      container.register<List<int>>(Lifetime.scoped, (_) => <int>[]);
      final child1 = container.createChildContainer();
      final child2 = container.createChildContainer();
      expect(identical(child1.resolve<List<int>>(), child1.resolve<List<int>>()), isTrue);
      expect(identical(child1.resolve<List<int>>(), child2.resolve<List<int>>()), isFalse);
    });

    test('throws on circular dependency', () {
      final container = Container();
      container.register<String>(Lifetime.transient, (c) {
        c.resolve<String>(); // circular
        return '';
      });
      expect(() => container.resolve<String>(), throwsStateError);
    });

    test('throws on unregistered type', () {
      final container = Container();
      expect(() => container.resolve<int>(), throwsStateError);
    });

    test('throws on duplicate registration', () {
      final container = Container();
      container.register<int>(Lifetime.transient, (_) => 1);
      expect(
        () => container.register<int>(Lifetime.transient, (_) => 2),
        throwsStateError,
      );
    });
  });
}
