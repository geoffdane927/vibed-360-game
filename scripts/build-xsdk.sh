#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="$HOME/xsdk"
PREFIX="$HOME/xsdk-gcc"
WORK="$HOME/xsdk-gcc-work"
GLSLANG_DIR="$HOME/glslang-xenon"

if [ ! -f "$SDK_DIR/tools/toolchain/build.sh" ]; then
  echo "xsdk checkout not found at $SDK_DIR. Run scripts/prepare-lubuntu.sh first." >&2
  exit 1
fi

echo "This builds source code from upstream xenosworks repositories."
echo "Expected peak free disk space: about 10 GB. Build logs/toolchain sources stay in $WORK."
read -r -p "Start build? [y/N] " answer
case "$answer" in
  y|Y|yes|YES) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

# Upstream toolchain script verifies SHA-256 for downloaded binutils, GCC and newlib archives.
cd "$SDK_DIR"
PREFIX="$PREFIX" WORK="$WORK" JOBS="$(nproc)" tools/toolchain/build.sh

# xsdk's documented HLSL/GLSL path uses the xenosworks glslang fork.
if [ ! -d "$GLSLANG_DIR/.git" ]; then
  if [ -e "$GLSLANG_DIR" ]; then
    echo "$GLSLANG_DIR exists but is not a Git checkout; refusing to overwrite it." >&2
    exit 1
  fi
  git clone --depth 1 --branch xenon https://github.com/xenosworks/glslang-xenon.git "$GLSLANG_DIR"
fi

cd "$GLSLANG_DIR"
python3 update_glslang_sources.py
cmake -S "$GLSLANG_DIR" -B "$GLSLANG_DIR/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DENABLE_OPT=ON \
  -DSPIRV_SKIP_EXECUTABLES=ON -DGLSLANG_TESTS=OFF
cmake --build "$GLSLANG_DIR/build"
install -m 0755 "$GLSLANG_DIR/build/StandAlone/glslang" "$PREFIX/bin/glslang"

cd "$SDK_DIR"
make -j"$(nproc)" TOOLCHAIN="$PREFIX/bin/powerpc-xsdk-elf-"
make samples TOOLCHAIN="$PREFIX/bin/powerpc-xsdk-elf-"

# Configure the game's separate CMake project against the built SDK.
cmake -S "$REPO_DIR/game" -B "$REPO_DIR/build-game" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$SDK_DIR/cmake/xsdk.cmake" \
  -DXSDK_TOOLCHAIN="$PREFIX"
cmake --build "$REPO_DIR/build-game"

echo
echo "Build commands completed."
echo "Compiler: $PREFIX/bin/powerpc-xsdk-elf-gcc"
echo "SDK library: $SDK_DIR/build/libxsdk.a"
echo "SDK test: $SDK_DIR/build/xsdk_test.xex"
echo "Sample XEX files: $SDK_DIR/build/samples/"
echo "Game XEX: $REPO_DIR/build-game/vibed360.xex"
echo "These outputs have not been tested on your Xbox 360 by this script."
