#!/usr/bin/env fish

set WORKDIR (pwd)
set WASIX_CLANG_DIR $(cd (dirname (status -f)); and pwd)
cd $WORKDIR

if ! test -f $WASIX_CLANG_DIR/.dependencies-ok
    echo "You are running wasix-clang for the first time. This will take a moment, as we need to fetch dependencies." >&2
    if ! bash $WASIX_CLANG_DIR/setup.sh
        echo "Failed to set up dependencies. Please check the output above for errors." >&2
        exit 1
    end
end

if test -z "$SUDO" && test (id -u) -ne 0
    set SUDO (which sudo)
end

export PATH="$WASIX_CLANG_DIR/bin:$WASIX_CLANG_DIR/wasix-llvm/bin:$WASIX_CLANG_DIR/wasix-wasmer/bin:$WASIX_CLANG_DIR/binaryen/bin:$PATH"

export WASIX_SYSROOT="$WASIX_CLANG_DIR/wasix-sysroot"
export WASIX_LLVM="$WASIX_CLANG_DIR/wasix-llvm"
export WASIX_WASMER="$WASIX_CLANG_DIR/wasix-wasmer"
export WASIX_BINARYEN="$WASIX_CLANG_DIR/binaryen"

export WASMER="$WASIX_CLANG_DIR/wasix-wasmer/bin/wasmer"
export CC=wasix-clang
export CXX=wasix-clang++
export AR=llvm-ar
export NM=llvm-nm
export LD=wasm-ld
export RANLIB=llvm-ranlib
export AS=llvm-as

# Register Wasmer as a binfmt handler
if test $SUDO != ""
    $SUDO $WASMER binfmt reregister >/dev/null || echo "Warning: Failed to register wasmer as a binfmt handler. You might need to run 'sudo $WASMER binfmt register' manually." >&2
else
    $WASMER binfmt reregister >/dev/null || echo "Warning: Failed to register wasmer as a binfmt handler. You might need to run 'sudo $WASMER binfmt register' manually." >&2
end
