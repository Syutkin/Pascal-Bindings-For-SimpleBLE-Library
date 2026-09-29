#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p tests/bin tests/lib/linux-x86_64

cc -std=c11 -Wall -Wextra -Werror -Ishared/include \
  tests/simplecbleabioracle.c -o tests/bin/simplecbleabioracle
cc -std=c11 -Wall -Wextra -Werror -fPIC -shared -Ishared/include \
  tests/simplecblefixture.c -o tests/bin/libsimplecblefixture.so
cc -std=c11 -Wall -Wextra -Werror -fPIC -shared -Ishared/include \
  -DSIMPLEBLE_FIXTURE_VERSION='"1.1.0"' \
  tests/simplecblefixture.c -o tests/bin/libsimplecblefixture-1.1.so

tests/bin/simplecbleabioracle
lazbuild --ws=qt6 tests/simpleblebindingstests.lpi
SIMPLECBLE_LIBRARY_DIR="$PWD/shared/lib" \
SIMPLECBLE_FIXTURE_LIBRARY="$PWD/tests/bin/libsimplecblefixture.so" \
SIMPLECBLE_OLD_FIXTURE_LIBRARY="$PWD/tests/bin/libsimplecblefixture-1.1.so" \
  tests/bin/simpleblebindingstests --all --format=plain
fpc -FuSimpleBleUnit -FEtests/bin -FUtests/lib/linux-x86_64 \
  tests/simplebleownershiptests.lpr
tests/bin/simplebleownershiptests
