import 'package:test/test.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

void main() {
  group('ConfigRegistry', () {
    const apiUrl = ConfigKey<String>('api_url', defaultValue: 'https://prod.api');

    test('returns default when no value set', () {
      final config = ConfigRegistry();
      expect(config.get(apiUrl), 'https://prod.api');
    });

    test('returns global value', () {
      final config = ConfigRegistry();
      config.set(apiUrl, 'https://custom.api');
      expect(config.get(apiUrl), 'https://custom.api');
    });

    test('environment value overrides global', () {
      final config = ConfigRegistry(environment: SyzygyEnvironment.debug);
      config.set(apiUrl, 'https://global.api');
      config.setForEnvironment(apiUrl, 'https://dev.api', SyzygyEnvironment.debug);
      expect(config.get(apiUrl), 'https://dev.api');
    });

    test('switchEnvironment changes active overrides', () {
      final config = ConfigRegistry(environment: SyzygyEnvironment.debug);
      config.setForEnvironment(apiUrl, 'https://dev.api', SyzygyEnvironment.debug);
      config.setForEnvironment(apiUrl, 'https://staging.api', SyzygyEnvironment.staging);
      expect(config.get(apiUrl), 'https://dev.api');
      config.switchEnvironment(SyzygyEnvironment.staging);
      expect(config.get(apiUrl), 'https://staging.api');
      expect(config.environment, SyzygyEnvironment.staging);
    });

    test('falls through env -> global -> default', () {
      final config = ConfigRegistry(environment: SyzygyEnvironment.staging);
      // No staging override, no global -> default
      expect(config.get(apiUrl), 'https://prod.api');
      config.set(apiUrl, 'https://global.api');
      expect(config.get(apiUrl), 'https://global.api');
    });
  });
}
