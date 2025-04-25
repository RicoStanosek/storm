#!/usr/bin/env bash
set -euo pipefail

# Configure paths
LLVM_BIN="/opt/homebrew/opt/llvm/bin"
BUILD_DIR="build"
SRC_DIR="$(pwd)"

# Compiler environment variables
export CC="$LLVM_BIN/clang"
export CXX="$LLVM_BIN/clang++"
export PATH="$LLVM_BIN:$PATH"

# Default: do not clean
CLEAN_REBUILD=0

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --clean-rebuild)
      CLEAN_REBUILD=1
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [--clean-rebuild]"
      exit 1
      ;;
  esac
done

# Clean build directory if requested
if [[ $CLEAN_REBUILD -eq 1 ]]; then
  rm -rf "$BUILD_DIR"
fi

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Run cmake if needed (if no CMakeCache.txt or after clean)
if [[ ! -f "CMakeCache.txt" || $CLEAN_REBUILD -eq 1 ]]; then
  cmake \
    -DCMAKE_BUILD_TYPE=Debug \
    -DSTORM_DEVELOPER=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_OSX_SYSROOT="$(xcrun --show-sdk-path)" \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_CXX_COMPILER="$CXX" \
    -DCMAKE_CXX_FLAGS_DEBUG="-g -Wno-missing-template-arg-list-after-template-kw" \
    "$SRC_DIR"
fi

# Build with all cores
make -j"$(sysctl -n hw.ncpu)"
