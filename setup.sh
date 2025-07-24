#!/usr/bin/env bash

function package_name {
    case "$1" in
        "xz")
            echo "xz-utils"
            ;;
        *)
            echo "$1"
            ;;
    esac 
}

MISSING_DEPS=()

function check_command {
    if ! command -v "$1" &> /dev/null ; then
        MISSING_DEPS+=( $(package_name "$1") )
    fi
}
function assert_commands {
    if test -n "${MISSING_DEPS}" ; then
        echo "Error: Some dependencies are missing `"${MISSING_DEPS[@]}"`. Please install it and try again." >&2
        echo "You can install it with your package manager, e.g.:" >&2
        echo "  ${SUDO} apt install ${MISSING_DEPS[@]}" >&2
        if command -v "apt" &> /dev/null ; then
            read -p "Do you want to execute that command now? [y/N]:" -n 1 -r </dev/tty
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                ${SUDO} apt install ${MISSING_DEPS[@]} || exit 1
                return 0
            fi
        fi
        exit 1
    fi
}

# Change into the correct directory
WASIX_CLANG_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $WASIX_CLANG_DIR


if test "$(id -u)" -ne 0 ; then
    check_command ${SUDO:-sudo}
fi
check_command git
check_command xz
check_command which
check_command curl
check_command bash
check_command wget
check_command tar
check_command awk
check_command nix


if ! test -f $WASIX_CLANG_DIR/bin/wasix-clang ; then
    # The script is most likely run via curl. In that case it's fine to be verbose
    export INTERACTIVE_INSTALL=true

    # Clone the repository into the users home, if we are not already in the repository
    set -e
    INSTALL_DIR=~/.wasix-clang
    if test -f $INSTALL_DIR/bin/wasix-clang ; then
        echo "Existing installation found, using that." >&2
        exec $INSTALL_DIR/setup.sh "$@"
    fi

    read -p "Install wasix-clang to $INSTALL_DIR? [y/N]:" -n 1 -r </dev/tty
    if ! [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Installation cancelled." >&2
        exit 1
    fi

    # Assert all commands after confirmation
    assert_commands

    echo "Installing wasix-clang to $INSTALL_DIR..." >&2
    git clone https://github.com/wasix-org/wasix-clang.git $INSTALL_DIR
    exec $INSTALL_DIR/setup.sh "$@"
fi

assert_commands

# Fetch llvm build if it is not there yet
if ! test -f wasix-llvm/finished ; then
    rm -rf wasix-llvm
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.4/wasix-llvm.tar.xz -O - | tar -xJ
    touch wasix-llvm/finished
fi

# Fetch wasix-sysroot if it is not there yet
if ! test -f wasix-sysroot/finished ; then
    rm -rf wasix-sysroot
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.4/wasix-sysroot.tar.xz -O - | tar -xJ
    touch wasix-sysroot/finished
fi

# Fetch wasix-wasmer if it is not there yet
if ! test -f wasix-wasmer/finished ; then
    rm -rf wasix-wasmer
    wget -c https://github.com/wasix-org/wasix-clang/releases/download/v0.0.4/wasix-wasmer.tar.xz -O - | tar -xJ
    touch wasix-wasmer/finished
fi

# Fetch a recent version of binaryen
if ! test -f binaryen/finished ; then
    rm -rf binaryen
    mkdir -p binaryen
    wget -c https://github.com/WebAssembly/binaryen/releases/download/version_123/binaryen-version_123-x86_64-linux.tar.gz -O - | tar -xz --strip-components=1 --keep-directory-symlink -C binaryen
    touch binaryen/finished
fi

if ! test -f .dependencies-ok ; then
    WASM_OPT_VERSION=$(binaryen/bin/wasm-opt --version | awk '{print $3}')
    if test "$WASM_OPT_VERSION" -lt 114 ; then
        echo "Error: wasm-opt version 114 or higher is required. Please update wasm-opt and try again." >&2
        exit 1
    fi

    # Check that nix flakes and nix command is enabled
    # if test "$(nix run nixpkgs#hello)" != "Hello, world!" ; then
    #     echo "Error: Nix flakes are not enabled. Please enable them by adding the following to your /etc/nix/nix.conf:" >&2
    #     echo "  experimental-features = nix-command flakes" >&2

    #     echo "Or see https://nixos.wiki/wiki/Flakes for more details" >&2
    #     exit 1
    # fi

    if ! wasix-wasmer/bin/wasmer --version > /dev/null ; then
        echo "Error: wasix-wasmer/bin/wasmer seems to be broken, make sure it works " >&2
        exit 1
    fi

    if ! wasix-llvm/bin/clang --version > /dev/null ; then
        echo "Error: clang seems to be broken, make sure it works " >&2
        exit 1
    fi

    touch .dependencies-ok
fi

if test "$INTERACTIVE_INSTALL" = "true" ; then
    echo "Done fetching dependencies. You can now use wasix-clang." >&2
    echo "To use it, run 'source $WASIX_CLANG_DIR/activate.sh' or 'source $WASIX_CLANG_DIR/activate.fish' in your shell." >&2
fi