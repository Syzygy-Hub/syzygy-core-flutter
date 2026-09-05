<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/AKS-Work/.github/main/assets/syzygy-banner-dark.png">
    <img alt="Syzygy" src="https://raw.githubusercontent.com/AKS-Work/.github/main/assets/syzygy-banner-light.png" width="600">
  </picture>
</p>

<h3 align="center">syzygy-core-flutter</h3>
<p align="center">Pure app-infrastructure framework for Flutter — DI, state, events, logging, feature flags, navigation, validation, configuration, lifecycle &amp; scheduling.</p>

<p align="center">
  <a href="https://github.com/AKS-Work/syzygy-core-flutter/actions/workflows/ci.yml"><img src="https://github.com/AKS-Work/syzygy-core-flutter/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/version-1.0.0-blue" alt="Version">
  <img src="https://img.shields.io/badge/dart-%3E%3D3.0.0-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/flutter-%3E%3D3.0-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

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
      url: https://github.com/AKS-Work/syzygy-core-flutter.git
      ref: 1.0.0
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

→ [Syzygy Hub](https://github.com/AKS-Work)

## License

MIT
