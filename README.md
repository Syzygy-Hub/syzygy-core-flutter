[![Flutter](https://img.shields.io/badge/Flutter-Dart-7F77DD?style=flat)](https://flutter.dev/) [![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?logo=dart&logoColor=white&style=flat)](https://dart.dev/) [![CI](https://img.shields.io/github/actions/workflow/status/Syzygy-Hub/syzygy-core-flutter/ci.yml?label=ci&style=flat)](https://github.com/Syzygy-Hub/syzygy-core-flutter/actions/workflows/ci.yml) [![Version](https://img.shields.io/badge/version-1.0.0-D85A30?style=flat)](https://github.com/Syzygy-Hub/syzygy-core-flutter/releases) [![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Syzygy-Hub/.github/main/brand/assets/banners/syzygy-banner-dark-1200.png">
  <img src="https://raw.githubusercontent.com/Syzygy-Hub/.github/main/brand/assets/banners/syzygy-banner-light-1200.png" alt="Syzygy" width="600">
</picture>

# syzygy-core-flutter

Core infrastructure modules for the Syzygy Flutter ecosystem — dependency injection, state management, event bus, logging, feature flags, navigation, validation, configuration, app lifecycle, and scheduling.

---

## Modules

| Module | Description |
|--------|-------------|
| **DI Container** | Registration, resolution, scoping (singleton / transient / scoped), thread-safe container |
| **State Management** | Reactive state stores, observable properties, state reducers, state selectors |
| **Event Bus** | Typed pub/sub channels, scoped subscriptions, async event dispatch |
| **Logging** | Log levels, formatters, log pipeline routing, `LogDestination` + `ConsoleLogDestination` |
| **Feature Flags** | Evaluation rules, flag definitions, local overrides, A/B variant selection |
| **Navigation** | Route definitions, deep link URL parsing, navigation stack model, route guards |
| **Validation** | Composable field validators, rule chaining, form-level validation pipeline, built-in rules |
| **Configuration** | In-memory config registry, environment-based switching, typed config access |
| **App Lifecycle** | Foreground/background state tracking, lifecycle observers, lifecycle-aware scoping |
| **Scheduling** | Debounce, throttle, delayed execution, cancellable timers |

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  syzygy_core_flutter:
    git:
      url: https://github.com/Syzygy-Hub/syzygy-core-flutter.git
      ref: '1.1.0'
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';

final container = Container();
final bus = EventBus();
final scheduler = Scheduler();
```

## Requirements

| Requirement | Version |
|-------------|---------|
| Dart SDK | ≥ 3.0.0, < 4.0.0 |
| Flutter | ≥ 3.0 |

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `syzygy_foundation_flutter` | ≥ 1.1.0 | Foundation primitives (Result, Clock, protocols) |

## Ecosystem

This package is part of **Syzygy** — a modular, multi-platform app architecture.

→ [Syzygy Hub](https://github.com/Syzygy-Hub)

## License

MIT
