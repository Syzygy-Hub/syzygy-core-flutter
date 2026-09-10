import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('Validation', () {
    test('RequiredValidator rejects null and empty', () {
      final v = RequiredValidator();
      expect(v.validate(null), isA<Invalid>());
      expect(v.validate(''), isA<Invalid>());
      expect(v.validate('ok'), isA<Valid>());
    });

    test('MinLengthValidator and MaxLengthValidator', () {
      expect(MinLengthValidator(3).validate('ab'), isA<Invalid>());
      expect(MinLengthValidator(3).validate('abc'), isA<Valid>());
      expect(MaxLengthValidator(3).validate('abcd'), isA<Invalid>());
      expect(MaxLengthValidator(3).validate('abc'), isA<Valid>());
    });

    test('EmailValidator accepts and rejects', () {
      final v = EmailValidator();
      expect(v.validate('a@b.c'), isA<Valid>());
      expect(v.validate('not-email'), isA<Invalid>());
    });

    test('RegexValidator matches pattern', () {
      final v = RegexValidator(RegExp(r'^\d+$'), message: 'digits only');
      expect(v.validate('123'), isA<Valid>());
      final result = v.validate('abc');
      expect(result, isA<Invalid>());
      expect((result as Invalid).messages, ['digits only']);
    });

    test('ValidationPipeline shortCircuit stops at first error', () {
      final pipeline = ValidationPipeline<String>(
        [MinLengthValidator(5), MaxLengthValidator(3)],
        mode: ValidationMode.shortCircuit,
      );
      final result = pipeline.validate('ab');
      expect(result, isA<Invalid>());
      expect((result as Invalid).messages.first, contains('at least 5'));
    });

    test('ValidationPipeline collectAll joins all errors', () {
      final pipeline = ValidationPipeline<String>(
        [MinLengthValidator(5), RegexValidator(RegExp(r'^\d+$'), message: 'digits')],
        mode: ValidationMode.collectAll,
      );
      final result = pipeline.validate('ab');
      expect(result, isA<Invalid>());
      final msgs = (result as Invalid).messages;
      expect(msgs.any((m) => m.contains('at least 5')), isTrue);
      expect(msgs.any((m) => m.contains('digits')), isTrue);
    });
  });
}
