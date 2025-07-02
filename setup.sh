#!/usr/bin/env bash

# Change into the correct directory
WASIX_CLANG_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $WASIX_CLANG_DIR

function assert_command {
    if ! command -v "$1" &> /dev/null ; then
        echo "Error: $1 is not installed. Please install it and try again." >&2
        exit 1
    fi
}

assert_command bash
assert_command wget
assert_command tar
assert_command wasm-opt
assert_command nix

# Fetch llvm build if it is not there yet
if ! test -f wasix-llvm/finished ; then
    rm -rf wasix-llvm
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.2/wasix-llvm.tar.xz -O - | tar -xJ
    touch wasix-llvm/finished
fi

# Fetch wasix-sysroot if it is not there yet
if ! test -f wasix-sysroot/finished ; then
    rm -rf wasix-sysroot
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.2/wasix-sysroot.tar.xz -O - | tar -xJ
    touch wasix-sysroot/finished
fi
