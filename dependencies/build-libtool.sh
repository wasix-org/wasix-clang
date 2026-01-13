#!/usr/bin/env bash
set -euo pipefail

LIBTOOL_COMMIT="8b431ae3d4fb0d36589ec0db73bb61a5f00d0af0"

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
check_command help2man
check_command clang
check_command clang++
check_command xz
check_command automake
check_command autoconf


if test -n "${MISSING_DEPS[*]}" ; then
        echo 'Error: Some dependencies are missing `'"${MISSING_DEPS[*]}"'`. Please install it and try again.' >&2
        exit 1
fi

if test -d ./libtool.source ; then
    echo "Using existing libtool source directory" >&2
    cd ./libtool.source
    git fetch origin
else
    echo "Cloning libtool source code..." >&2
    git clone --recursive https://github.com/wasix-org/libtool.git ./libtool.source
fi

cd "$BUILDFILE_DIR/libtool.source"
git checkout "$LIBTOOL_COMMIT"
git submodule update --init --recursive

bash bootstrap
./configure --prefix=/
make -j16

echo Done building libtool

rm -rf "$BUILDFILE_DIR/libtool"
make install DESTDIR="$BUILDFILE_DIR/libtool"
ln -s ../aclocal ../libtool/share/libtool/m4

if ! test -f "$BUILDFILE_DIR/libtool/bin/libtool" ; then
    echo "It seems like the install is missing libtool. Go investigate" >&2
    exit 1
fi

cd "$BUILDFILE_DIR"
tar cvfJ libtool.tar.xz libtool
