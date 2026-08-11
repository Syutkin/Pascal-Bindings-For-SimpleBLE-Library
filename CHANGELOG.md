# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-08-12

### Fixed

- Declared the Lazarus package as `RunTime` so IDE design-time packages can
  depend on it.

### Changed

- Expanded native-loader tests for missing libraries, unresolved symbols, and
  failed reloads.

## [1.0.1] - 2026-08-08

### Fixed

- Kept pinned native libraries loaded while callbacks may still reference
  SimpleCBLE code.

## [1.0.0] - 2026-08-08

### Added

- Added Lazarus and FPC package metadata for the SimpleCBLE 1.0.0 bindings.

[1.0.2]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/releases/tag/v1.0.0
