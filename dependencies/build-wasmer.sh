#!/usr/bin/env bash
set -euo pipefail

WASMER_COMMIT="ab6f82070f7886369fa61fd2fa6ad5b788c34632"

BUILDFILE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if ! test -d "${BUILDFILE_DIR}" ; then
    echo "Error: Faild to find buildfile directory" >&2
    exit 1
fi
cd "$BUILDFILE_DIR"

export LLVM_SYS_180_PREFIX="${LLVM_SYS_180_PREFIX:="/usr/lib/llvm-18"}"

if ! test -d "${LLVM_SYS_180_PREFIX}" ; then
    echo "Error: LLVM 18 not found in ${LLVM_SYS_180_PREFIX}. Please install it and try again." >&2
    echo "On Ubuntu, you can install it with:" >&2
    echo "  sudo apt install llvm-18 clang-18 lld-18 libclang-18-dev" >&2
    exit 1
fi
if ! test -f "${LLVM_SYS_180_PREFIX}/bin/clang" ; then
    echo "Error: clang not found in ${LLVM_SYS_180_PREFIX}. Please install it and try again." >&2
    echo "On Ubuntu, you can install it with:" >&2
    echo "  sudo apt install llvm-18 clang-18 lld-18 libclang-18-dev" >&2
    exit 1
fi
if ! command -v "cargo" &> /dev/null ; then
    echo "Error: cargo not found in PATH. Please install Rust and try again." >&2
    echo "You can install it from https://rustup.rs/" >&2
    exit 1
fi
if ! command -v "git" &> /dev/null ; then
    echo "Error: git not found in PATH. Please install git and try again." >&2
    exit 1
fi

if test -d ./wasmer.source ; then
    echo "Using existing wasmer source directory" >&2
    cd ./wasmer.source
    git fetch origin
else
    echo "Cloning wasmer source code..." >&2
    git clone --recursive https://github.com/wasmerio/wasmer.git ./wasmer.source
fi
cd "$BUILDFILE_DIR/wasmer.source"
git checkout "$WASMER_COMMIT"
git submodule update --init --recursive

cargo build -j 4 --target x86_64-unknown-linux-gnu --profile release --features=cranelift\,wasmer-artifact-create\,static-artifact-create\,wasmer-artifact-load\,static-artifact-load\,llvm\,singlepass --manifest-path lib/cli/Cargo.toml --bin wasmer

cd "$BUILDFILE_DIR"
mkdir -p ./wasix-wasmer/bin
cp ./wasmer.source/target/x86_64-unknown-linux-gnu/release/wasmer ./wasix-wasmer/bin/wasmer

tar cvfJ wasix-wasmer.tar.xz wasix-wasmer