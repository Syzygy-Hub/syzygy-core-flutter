import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('EventBus', () {
    test('delivers events to subscribers', () {
      final bus = EventBus();
      final received = <String>[];
      bus.subscribe<String>((e) => received.add(e));
      bus.publish<String>('hello');
      expect(received, ['hello']);
      bus.dispose();
    });

    test('does not deliver after cancel', () {
      final bus = EventBus();
      final received = <String>[];
      final token = bus.subscribe<String>((e) => received.add(e));
      token.cancel();
      bus.publish<String>('hello');
      expect(received, isEmpty);
      expect(token.isCancelled, isTrue);
      bus.dispose();
    });

    test('delivers only to matching type subscribers', () {
      final bus = EventBus();
      final strings = <String>[];
      final ints = <int>[];
      bus.subscribe<String>((e) => strings.add(e));
      bus.subscribe<int>((e) => ints.add(e));
      bus.publish<String>('a');
      bus.publish<int>(1);
      expect(strings, ['a']);
      expect(ints, [1]);
      bus.dispose();
    });

    test('throws on publish after dispose', () {
      final bus = EventBus();
      bus.dispose();
      expect(() => bus.publish<String>('x'), throwsStateError);
    });

    test('cancels all subscriptions on dispose', () {
      final bus = EventBus();
      final token = bus.subscribe<String>((_) {});
      bus.dispose();
      expect(token.isCancelled, isTrue);
    });
  });
}
