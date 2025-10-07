#!/usr/bin/env bash
set -euo pipefail

bash build-sysroot.sh
bash build-wasmer.sh
bash build-binaryen.sh
bash build-llvm.sh