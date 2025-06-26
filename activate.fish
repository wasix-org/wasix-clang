#!/usr/bin/env fish

set WORKDIR (pwd)
set WASIX_CLANG_DIR $(cd (dirname (status -f)); and pwd)
cd $WORKDIR

export PATH="$WASIX_CLANG_DIR/bin:$WASIX_CLANG_DIR/wasix-llvm/bin:$PATH"

export WASIX_SYSROOT="$WASIX_CLANG_DIR/wasix-sysroot"
export WASIX_LLVM="$WASIX_CLANG_DIR/wasix-llvm"

export CC=wasix-clang
export CXX=wasix-clang++
export AR=llvm-ar
export NM=llvm-nm
export LD=wasm-ld
export RANLIB=llvm-ranlib
export AS=llvm-as
