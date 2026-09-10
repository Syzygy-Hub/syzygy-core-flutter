# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-05

### Added

- DI Container — registration, resolution, scoping (singleton / transient / scoped), thread-safe container
- State Management — reactive state stores, observable properties, state reducers, state selectors
- Event Bus — typed pub/sub channels, scoped subscriptions, async event dispatch
- Logging — log levels, formatters, log pipeline routing, `LogDestination` + `ConsoleLogDestination`
- Feature Flags — evaluation rules, flag definitions, local overrides, A/B variant selection
- Navigation — route definitions, deep link URL parsing, navigation stack model, route guards
- Validation — composable field validators, rule chaining, form-level validation pipeline, built-in rules
- Configuration — in-memory config registry, environment-based switching, typed config access
- App Lifecycle — foreground/background state tracking, lifecycle observers, lifecycle-aware scoping
- Scheduling — debounce, throttle, delayed execution, cancellable timers

[1.0.0]: https://github.com/Syzygy-Hub/syzygy-core-flutter/releases/tag/1.0.0
