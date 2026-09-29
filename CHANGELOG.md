# Changelog

## [1.2.0] - 2026-09-29

### Changed

- Updated the C declarations and dynamic loader for the SimpleBLE/SimpleCBLE
  1.2.0 ABI. The loader rejects incompatible native versions before other ABI
  calls.
- Updated all three console examples to handle `out_error` and release native
  resources after use.
- Moved the console examples into `examples/` and renamed their projects to
  `SimpleBleScan`, `SimpleBleConnect`, and `SimpleBleNotify`.

### Added

- Added Pascal-owned copies for services, manufacturer data, read buffers and
  errors, plus hardware-free ABI, callback and ownership tests.

## [1.1.0] - 2026-08-12

### Changed

- Updated the bindings and native loader for the SimpleBLE/SimpleCBLE 1.1.0
  ABI.
- Removed the legacy BlueZ backend configuration selectors removed by
  SimpleCBLE 1.1.0.

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

[1.2.0]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library/releases/tag/v1.0.0
