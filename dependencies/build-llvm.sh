#!/usr/bin/env bash
set -euo pipefail

LLVM_COMMIT="c7b09c0a9de89e698038a146851c6bdd86fc8ea9"

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
check_command wget
check_command tar
check_command clang
check_command clang++
check_command lld
check_command cargo
check_command rustc
check_command python3

if test -n "${MISSING_DEPS[*]}" ; then
        echo 'Error: Some dependencies are missing `'"${MISSING_DEPS[*]}"'`. Please install it and try again.' >&2
        exit 1
fi

if test -d ./llvm.source ; then
    echo "Using existing llvm source directory" >&2
    cd ./llvm.source
    git fetch origin
else
    echo "Cloning llvm source code..." >&2
    git clone --recursive https://github.com/wasix-org/llvm-project.git ./llvm.source
fi

cd "$BUILDFILE_DIR/llvm.source"
git checkout "$LLVM_COMMIT"
git submodule update --init --recursive

CMAKE_COMMAND=( 
    cmake llvm
    -B build-wasix-llvm
    -G Ninja
    -DLLVM_PARALLEL_{COMPILE,LINK,TABLEGEN}_JOBS=4
    -DLLVM_ENABLE_PROJECTS='clang;lld;clang-tools-extra'
    -DLLVM_USE_LINKER=lld
    -DCMAKE_INSTALL_PREFIX=/wasix-llvm
    -DCMAKE_BUILD_TYPE=MinSizeRel
    -DLLVM_BUILD_TOOLS=ON
    -DLLVM_BUILD_UTILS=OFF
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF
    -DCLANG_ENABLE_OBJC_REWRITER=OFF
    -DLLVM_CCACHE_BUILD=ON
    -DLLVM_TARGETS_TO_BUILD="WebAssembly;X86"
)

"${CMAKE_COMMAND[@]}"

ninja -C "$BUILDFILE_DIR/llvm.source/build-wasix-llvm"

echo Done building LLVM/Clang

rm -rf "$BUILDFILE_DIR/wasix-llvm"
DESTDIR="$BUILDFILE_DIR" ninja -C "$BUILDFILE_DIR/llvm.source/build-wasix-llvm" install

if ! test -f "$BUILDFILE_DIR/wasix-llvm/bin/clang" ; then
    echo "It seems like the install is missing clang. Go investigate" >&2
    exit 1
fi

# Create symlinks for some tools that don't have the llvm- prefix
cd "$BUILDFILE_DIR/wasix-llvm/bin"
ln -sf /usr/bin/as ./as
ln -sf llvm-ranlib ./ranlib
ln -sf llvm-nm ./nm
ln -sf llvm-as ./as
ln -sf llvm-ar ./ar
ln -sf llvm-strip ./strip

cd "$BUILDFILE_DIR"
tar cvfJ wasix-llvm.tar.xz wasix-llvm
