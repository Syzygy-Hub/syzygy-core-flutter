import 'dart:async';
import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

/// Flushes all pending microtasks.
Future<void> pumpEventQueue() => Future.microtask(() {});

void main() {
  group('EventBus', () {
    test('delivers events to subscribers', () async {
      final bus = EventBus();
      final received = <String>[];
      bus.subscribe<String>((e) => received.add(e));
      bus.publish<String>('hello');
      await pumpEventQueue();
      expect(received, ['hello']);
      bus.dispose();
    });

    test('does not deliver after cancel', () async {
      final bus = EventBus();
      final received = <String>[];
      final token = bus.subscribe<String>((e) => received.add(e));
      token.cancel();
      bus.publish<String>('hello');
      await pumpEventQueue();
      expect(received, isEmpty);
      expect(token.isCancelled, isTrue);
      bus.dispose();
    });

    test('delivers only to matching type subscribers', () async {
      final bus = EventBus();
      final strings = <String>[];
      final ints = <int>[];
      bus.subscribe<String>((e) => strings.add(e));
      bus.subscribe<int>((e) => ints.add(e));
      bus.publish<String>('a');
      bus.publish<int>(1);
      await pumpEventQueue();
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

    test('failing handler does not block other handlers', () async {
      final bus = EventBus();
      final received = <String>[];
      bus.subscribe<String>((_) => throw Exception('bad handler'));
      bus.subscribe<String>((e) => received.add(e));
      bus.publish<String>('ok');
      await pumpEventQueue();
      expect(received, ['ok']);
      bus.dispose();
    });

    test('calls onHandlerError when handler throws', () async {
      Object? capturedError;
      dynamic capturedEvent;
      final bus = EventBus(
        onHandlerError: (error, event) {
          capturedError = error;
          capturedEvent = event;
        },
      );
      final thrownError = Exception('handler error');
      bus.subscribe<String>((_) => throw thrownError);
      bus.publish<String>('test-event');
      await Future.delayed(Duration.zero);
      expect(capturedError, thrownError);
      expect(capturedEvent, 'test-event');
      bus.dispose();
    });

    test('eventBusDisposePreventsPublish', () {
      final bus = EventBus();
      bus.dispose();
      expect(() => bus.publish<String>('x'), throwsStateError);
    });
  });
}
