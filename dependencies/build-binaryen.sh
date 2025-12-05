#!/usr/bin/env bash
set -euo pipefail

BINARYEN_COMMIT="6ec7b5f9c615d3b224c67ae221d6812c8f8e1a96"

BUILDFILE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if ! test -d "${BUILDFILE_DIR}" ; then
    echo "Error: Faild to find buildfile directory" >&2
    exit 1
fi
cd "$BUILDFILE_DIR"

MISSING_DEPS=( )
function check_command {
    if ! command -v "$1" &> /dev/null ; then
        MISSING_DEPS+=( "$1" )
    fi
}

check_command git
check_command cmake
check_command ninja
check_command clang
check_command clang++
check_command lld

if test -n "${MISSING_DEPS[*]}" ; then
        echo 'Error: Some dependencies are missing `'"${MISSING_DEPS[*]}"'`. Please install it and try again.' >&2
        exit 1
fi

if test -d ./binaryen.source ; then
    echo "Using existing binaryen source directory" >&2
    cd ./binaryen.source
    git fetch origin
else
    echo "Cloning binaryen source code..." >&2
    git clone --recursive https://github.com/WebAssembly/binaryen.git ./binaryen.source
fi

cd "$BUILDFILE_DIR/binaryen.source"
git checkout "$BINARYEN_COMMIT"
git submodule update --init --recursive

CMAKE_COMMAND=( 
    cmake .
    -B build-binaryen
    -G Ninja
    -DCMAKE_CXX_FLAGS="-static"
    -DCMAKE_C_FLAGS="-static"
    -DCMAKE_BUILD_TYPE=MinSizeRel
    -DBUILD_STATIC_LIB=ON
    -DBUILD_MIMALLOC=ON
    -DCMAKE_INSTALL_PREFIX=/binaryen
)

"${CMAKE_COMMAND[@]}"

cmake --build build-binaryen -j16

echo Done building binaryen

rm -rf "$BUILDFILE_DIR/binaryen"
DESTDIR="$BUILDFILE_DIR" cmake --install build-binaryen

if ! test -f "$BUILDFILE_DIR/binaryen/bin/wasm-opt" ; then
    echo "It seems like the install is missing wasm-opt. Go investigate" >&2
    exit 1
fi

cd "$BUILDFILE_DIR"
tar cvfJ binaryen.tar.xz binaryen
