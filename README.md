# Pascal Bindings For SimpleBLE Library
These are Lazarus/FreePascal bindings for the SimpleBLE cross-platform Bluetooth LE (BLE) library.

Current Pascal bindings release: **v1.0.1**, targeting the SimpleBLE/SimpleCBLE
1.0.0 ABI.

## SimpleBLE
SimpleBLE is a cross-platform native Bluetooth Low Energy library. SimpleCBLE
exposes its C ABI; this project provides a Pascal unit for that ABI for use
with [Lazarus](https://www.lazarus-ide.org/) and
[Free Pascal](https://www.freepascal.org/).

The native project is maintained in the
[`simpleble/simpleble`](https://github.com/simpleble/simpleble) repository.
Its documentation is available on
[Read the Docs](https://simpleble.readthedocs.io/en/latest/).

## Usage
The bindings are provided by the single unit
`SimpleBleUnit/simpleble.pas`. Add this unit and its directory to the source
paths of a Lazarus or Free Pascal project.

Applications must call `SimpleBleLoadLibrary` before using the API. Pass an
explicit directory to load libraries from that location, including when the
libraries are stored next to the executable. Calling it without a directory
uses the platform's standard dynamic-library search path. Call
`SimpleBleUnloadLibrary` only after subscriptions, callbacks and native handles
have been released. A backend that uses adapters or callbacks should call
`SimpleBlePinLibrary` after a successful load. Pinning is process-wide and
keeps the native libraries mapped until process termination, while
`SimpleBleUnloadLibrary` still clears the resolved Pascal API pointers.

Pascal bindings release v1.0.1 targets the SimpleCBLE 1.0.0 ABI and requires:

* `SimpleBleUnit/simpleble.pas`: the Pascal declarations and dynamic loader;
* `simplecble.dll`, `libsimplecble.so`, or `libsimplecble.dylib`: the C ABI;
* `simpleble.dll`, `libsimpleble.so`, or `libsimpleble.dylib`: the native
  implementation used by SimpleCBLE.

Release v1.0.1 has been built and tested with Lazarus 4.8 and Free Pascal
3.2.2 on Linux x86_64. The current fork has not yet been verified on Windows.

## Examples
The original SimpleBLE project comes with three C examples, which have been ported to Lazarus:

* **SimpleBleScanExample**: A console application based on scan.c from SimpleBLE and demonstrates scanning for BLE advertisements from peripherals. The output shows a list of devices with BLE MAC address, device name (if present), RSSI value and manufacturer data (if present).
* **SimpleBleConnectExample**: A console application based on connect.c from SimpleBLE and demonstrates
  * Scanning for BLE advertisements from peripherals like above.
  * Selecting a peripheral to connect to.
  * Fetch BLE services, characteristics and descriptors from the peripherals's GATT table and shows as a list.
* **SimpleBleNotifyExample**: A console application based on notify.c from SimpleBLE and demonstrates
  * Scanning for BLE advertisements from peripherals like above.
  * Selecting a peripheral to connect to.
  * Fetch BLE services, characteristics and descriptors from the peripherals's GATT table and shows as a list.
  * Selecting a characteristic and subscribe to notifications.
  * If characteristic value changes on the peripheral, the new values are shown.

There are some more examples, but those are C++ and weren't (yet...) ported to Pascal.

### Building the Examples
Build the console examples from the repository root:

```sh
lazbuild --ws=qt6 SimpleBleScanExample/SimpleBleScanExample.lpi
lazbuild --ws=qt6 SimpleBleConnectExample/SimpleBleConnectExample.lpi
lazbuild --ws=qt6 SimpleBleNotifyExample/SimpleBleNotifyExample.lpi
```

The examples search for the native libraries in this order:

1. The directory specified by `SIMPLECBLE_LIBRARY_DIR`.
2. The directory containing the example executable.
3. The platform's standard dynamic-library search path.

On Linux the third option includes `LD_LIBRARY_PATH`, embedded
`RPATH`/`RUNPATH`, the loader cache, and standard system library directories.

### Dynamic Library Loading
Dynamic loading is enabled by default on all platforms. Call
`SimpleBleLoadLibrary` with the directory containing both native libraries and
call `SimpleBleUnloadLibrary` during shutdown. When loading fails,
`SimpleBleGetLastLoadError` returns a diagnostic. Define `SIMPLEBLE_STATIC`
when compiling the unit only when static linking is configured explicitly.

Call `SimpleBlePinLibrary` before using adapter callbacks in a long-lived
backend. This prevents a late native backend destructor from referring to
callback code in an already unloaded SimpleCBLE library. Pinning cannot be
reversed during the process lifetime; the operating system releases the
libraries when the process exits. With static linking the call is a no-op.

Strings returned by adapter/peripheral identifier and address functions, and
buffers returned by read functions, belong to SimpleCBLE and must be released
exactly once with `SimpleBleFree`. The string returned by
`SimpleBleGetVersion` is `const` and must not be freed. Adapter and peripheral
handles must be released with their matching release functions after callbacks
and subscriptions have been detached. Data passed to notification and
indication callbacks is borrowed from SimpleCBLE and is valid only for the
duration of the callback. Copy it into Pascal-owned memory before returning if
it is needed asynchronously.

## Tests

The native loader tests do not require a BLE adapter. Point
`SIMPLECBLE_LIBRARY_DIR` to a directory containing both shared libraries:

```sh
lazbuild --ws=qt6 tests/simpleblebindingstests.lpi
SIMPLECBLE_LIBRARY_DIR=/path/to/libraries \
  tests/bin/simpleblebindingstests --all --format=plain
```

The checked-in C oracle prints the platform ABI used by the Pascal layout
tests:

```sh
cc -std=c11 -Wall -Wextra -Werror -Ishared/include \
  tests/simplecbleabioracle.c -o tests/bin/simplecbleabioracle
tests/bin/simplecbleabioracle
```

## Package Builds

The bindings can be built as an FPC source package without loading the native
libraries:

```sh
fppkg build
```

The optional Lazarus package provides the same `SimpleBle` unit:

```sh
lazbuild --ws=qt6 simpleblepascal.lpk
```

## Building the SimpleBLE Shared Libraries
This repository does not vendor the SimpleBLE source tree or native binaries.
Obtain the native SimpleBLE and SimpleCBLE 1.0.0 artifacts from the
[official v1.0.0 release](https://github.com/simpleble/simpleble/releases/tag/v1.0.0),
or build the pinned `v1.0.0` tag using the upstream instructions. Do not build
an unpinned `main` branch for this bindings release.

Keep `simpleble` and `simplecble` from the same release and architecture.
Before redistributing native binaries, retain their native license notices and
confirm that the SimpleBLE licensing terms permit the intended distribution.

## Contributing

Issues and pull requests are welcome.

## License
Copyright (C) 2022 Erik Lins

Copyright (C) 2026 Andrey Syutkin (modifications)

The Pascal bindings are released under the MIT License. The native SimpleBLE
libraries retain their own BUSL-1.1/commercial licensing terms; the Pascal
license does not relicense native binaries.
