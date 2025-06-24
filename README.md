# wasix-clang
A lightweight clang wrapper for use with wasix.

## Installation

`wasix-clang` will download a prebuild clang toolchain and wasix sysroot automatically when it is first launched. This will take a moment, as we need to fetch dependencies.

You can also fetch the dependencies manually by running `setup.sh`.

## Usage

There are many ways to use wasix-clang. One is to just use `wasix-clang` and `wasix-clang++` for CC and CXX in an existing build process.

You can also use `. activate` to add both (and the vendored LLVM) to your PATH.