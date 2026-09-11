# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-11

### Fixed

- FIX 7: Extended `LogDestination.write()` to carry `SyzygyTimestamp?` and `Object? error`; `ConsoleLogDestination` includes timestamp and error in output; `Logger.log(LogEntry)` forwards `entry.timestamp` and `entry.error`
- FIX 8: Added test coverage for `Logger.log(LogEntry)` Foundation path — all 5 `LogLevel` mappings, metadata, timestamp, and error forwarding
- FIX 9: Injected `DateTime Function() clock` into `Throttler`; fixed post-cooldown re-execution bug; added post-cooldown test
- FIX 10: `AppLifecycleTracker` now records a `SyzygyTimestamp` at each lifecycle transition via `lastTransitionAt`; added timestamp tests
- FIX 11: `EventBus` handler dispatch is now async via `Future.microtask`; a failing handler no longer blocks others; updated tests to flush the microtask queue
- FIX 16: Added scoped-container doc comment and tests for independent child scopes and parent-scope caching
- FIX 20: Added heuristic-pattern doc comment to `EmailValidator`
- FIX 22: Replaced unchecked `as T` casts in `InMemoryFeatureFlagProvider` and `ConfigRegistry` with type-checked casts that throw a descriptive `StateError`
- FIX 25: Corrected `syzygy.yml` Foundation dependency constraint from `>=1.1.0` to `^1.1.0`

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

[1.1.0]: https://github.com/Syzygy-Hub/syzygy-core-flutter/releases/tag/1.1.0
[1.0.0]: https://github.com/Syzygy-Hub/syzygy-core-flutter/releases/tag/1.0.0
