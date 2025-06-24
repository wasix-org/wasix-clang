#!/usr/bin/env fish

set WASIX_CLANG_DIR $(cd (dirname (status -f)); and pwd)

export PATH="$WASIX_CLANG_DIR/bin:$WASIX_CLANG_DIR/wasix-llvm/bin:$PATH"