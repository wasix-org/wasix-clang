#!/usr/bin/env bash
set -euo pipefail

WASIX_SYSROOT_COMMIT="62a68e114db8a1c98f0955009e37c1b5c23e3b50"

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

if test -d ./wasix-sysroot.source ; then
    echo "Using existing wasix-sysroot source directory" >&2
    cd ./wasix-sysroot.source
    git fetch origin
else
    echo "Cloning wasix-sysroot source code..." >&2
    git clone https://github.com/wasix-org/build-scripts.git ./wasix-sysroot.source
fi

cd "$BUILDFILE_DIR/wasix-sysroot.source"
git checkout "$WASIX_SYSROOT_COMMIT"
git submodule update --recursive

bash -c "source ../../activate && make clean-build-artifacts && make pkgs/default.sysroot"

echo Done building wasix-sysroot

rm -rf "$BUILDFILE_DIR/wasix-sysroot"
mv pkgs/default.sysroot "$BUILDFILE_DIR/wasix-sysroot"

if ! test -f "$BUILDFILE_DIR/wasix-sysroot/include/stdint.h" ; then
    echo "It seems like the install is missing include/stdint.h. Go investigate" >&2
    exit 1
fi
if ! test -f "$BUILDFILE_DIR/wasix-sysroot/lib/wasm32-wasi/libc.a" ; then
    echo "It seems like the install is missing libc.a. Go investigate" >&2
    exit 1
fi
if ! test -f "$BUILDFILE_DIR/wasix-sysroot/usr/local/lib/wasm32-wasi/libffi.a" ; then
    echo "It seems like the install is missing libffi.a. Go investigate" >&2
    exit 1
fi

cd "$BUILDFILE_DIR"
tar cvfJ wasix-sysroot.tar.xz wasix-sysroot
