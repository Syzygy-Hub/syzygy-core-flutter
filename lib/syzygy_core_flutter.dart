/// Core infrastructure modules for the Syzygy Flutter ecosystem.
// ignore: unnecessary_library_name
library syzygy_core_flutter;

export 'src/di/container.dart';
export 'src/state/state_store.dart';
export 'src/eventbus/event_bus.dart';
// HI-08: LogLevel is re-exported from Foundation (show LogLevel) so consumers
// get the canonical 5-case type directly. No Core-private level type exists.
export 'src/logging/logger.dart';
export 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    show LogLevel;
export 'src/featureflags/feature_flag_provider.dart';
export 'src/navigation/router.dart';
export 'src/validation/validator.dart';
export 'src/configuration/config_registry.dart';
export 'src/lifecycle/app_lifecycle_observer.dart';
export 'src/scheduling/scheduler.dart';
