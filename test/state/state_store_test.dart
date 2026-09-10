import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('StateStore', () {
    test('holds initial state', () {
      final store = StateStore<int, String>(0, reducer: (s, a) => s);
      expect(store.state, 0);
      store.dispose();
    });

    test('dispatches actions through reducer', () {
      final store = StateStore<int, String>(
        0,
        reducer: (s, a) => a == 'inc' ? s + 1 : s,
      );
      store.dispatch('inc');
      expect(store.state, 1);
      store.dispatch('noop');
      expect(store.state, 1);
      store.dispose();
    });

    test('stream emits state changes', () async {
      final store = StateStore<int, String>(0, reducer: (s, a) => s + 1);
      final future = store.stream.take(2).toList();
      store.dispatch('a');
      store.dispatch('b');
      expect(await future, [1, 2]);
      store.dispose();
    });

    test('select emits distinct projected values', () async {
      final store = StateStore<int, String>(0, reducer: (s, a) => s + 1);
      final future = store.select<bool>((s) => s > 0).take(1).toList();
      store.dispatch('a');
      store.dispatch('b');
      expect(await future, [true]);
      store.dispose();
    });

    test('throws on dispatch after dispose', () {
      final store = StateStore<int, String>(0, reducer: (s, a) => s);
      store.dispose();
      expect(() => store.dispatch('x'), throwsStateError);
    });
  });
}
