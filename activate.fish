#!/usr/bin/env fish

set WORKDIR (pwd)
set WASIX_CLANG_DIR $(cd (dirname (status -f)); and pwd)
cd $WORKDIR

if test -z "$SUDO" 
    set SUDO "$(which sudo)"
end

export PATH="$WASIX_CLANG_DIR/bin:$WASIX_CLANG_DIR/wasix-llvm/bin:$WASIX_CLANG_DIR/wasix-wasmer/bin:$PATH"

export WASIX_SYSROOT="$WASIX_CLANG_DIR/wasix-sysroot"
export WASIX_LLVM="$WASIX_CLANG_DIR/wasix-llvm"
export WASIX_WASMER="$WASIX_CLANG_DIR/wasix-wasmer"

export WASMER="$WASIX_CLANG_DIR/wasix-wasmer/bin/wasmer"
export CC=wasix-clang
export CXX=wasix-clang++
export AR=llvm-ar
export NM=llvm-nm
export LD=wasm-ld
export RANLIB=llvm-ranlib
export AS=llvm-as

# Register Wasmer as a binfmt handler
"$SUDO" $WASMER binfmt reregister >/dev/null