#!/usr/bin/env bash

# Change into the correct directory
WASIX_CLANG_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $WASIX_CLANG_DIR

function package_name {
    case "$1" in
        "wasm-opt")
            echo "binaryen"
            ;;
        "xz")
            echo "xz-utils"
            ;;
        *)
            echo "$1"
            ;;
    esac 
}

function assert_command {
    if ! command -v "$1" &> /dev/null ; then
        echo "Error: $1 is not installed. Please install it and try again." >&2
        echo "You can install it with your package manager, e.g.:" >&2
        echo "  sudo apt install $(package_name "$1")" >&2
        exit 1
    fi
}

assert_command xz
assert_command which
assert_command sudo
assert_command bash
assert_command wget
assert_command tar
assert_command awk
assert_command wasm-opt
assert_command nix

# Fetch llvm build if it is not there yet
if ! test -f wasix-llvm/finished ; then
    rm -rf wasix-llvm
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.3/wasix-llvm.tar.xz -O - | tar -xJ
    touch wasix-llvm/finished
fi

# Fetch wasix-sysroot if it is not there yet
if ! test -f wasix-sysroot/finished ; then
    rm -rf wasix-sysroot
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.3/wasix-sysroot.tar.xz -O - | tar -xJ
    touch wasix-sysroot/finished
fi

# Fetch wasix-wasmer if it is not there yet
if ! test -f wasix-wasmer/finished ; then
    rm -rf wasix-wasmer
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.3/wasix-wasmer.tar.xz -O - | tar -xJ
    touch wasix-wasmer/finished
fi

if ! test -f .dependencies-ok ; then
    WASM_OPT_VERSION=$(wasm-opt --version | awk '{print $3}')
    if test "$WASM_OPT_VERSION" -lt 114 ; then
        echo "Error: wasm-opt version 114 or higher is required. Please update wasm-opt and try again." >&2
        exit 1
    fi

    # Check that nix flakes and nix command is enabled
    if test "$(nix run nixpkgs#hello)" != "Hello, world!" ; then
        echo "Error: Nix flakes are not enabled. Please enable them by adding the following to your /etc/nix/nix.conf:" >&2
        echo "  experimental-features = nix-command flakes" >&2

        echo "Or see https://nixos.wiki/wiki/Flakes for more details" >&2
        exit 1
    fi

    if ! wasix-wasmer/bin/wasmer --version ; then
        echo "Error: wasix-wasmer/bin/wasmer seems to be broken, make sure it works " >&2
        exit 1
    fi

    if ! wasix-llvm/bin/clang --version  ; then
        echo "Error: clang seems to be broken, make sure it works " >&2
        exit 1
    fi

    touch .dependencies-ok
fi