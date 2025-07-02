# wasix-clang
A lightweight clang wrapper for use with wasix.

## Installation

`wasix-clang` will download a prebuild clang toolchain and wasix sysroot automatically when it is first launched. This will take a moment, as we need to fetch dependencies.

You can also fetch the dependencies manually by running `setup.sh`.

Example on how to install it in a clean ubuntu environment: using `multipass shell`

```bash
sudo apt update -y
sudo apt install -y git wget curl sudo xz-utils
git clone https://github.com/wasix-org/wasix-clang.git

# This installs the latest binaryen in your root.
# You dont need this if your distro ships a recent binaryen version (>=114) 
wget https://github.com/WebAssembly/binaryen/releases/download/version_123/binaryen-version_123-x86_64-linux.tar.gz
sudo tar xzf binaryen-version_123-x86_64-linux.tar.gz --strip-components=1 --keep-directory-symlink -C /

# Install nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo sh -s -- install $(! test -f /.dockerenv || echo "linux --init none") --no-confirm
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

bash ./wasix-clang/setup.sh
```

The above example was tested in a clean ubuntu environment created with:

```bash
multipass launch 25.04 -n wasix-test --disk 50G
multipass shell wasix-test
```

## Usage

There are many ways to use wasix-clang. One is to just use `wasix-clang` and `wasix-clang++` for CC and CXX in an existing build process.

You can also use `. activate` to add both (and the vendored LLVM) to your PATH.

Example for building a ton of python packages:

```bash
# Install deps and clone repo
sudo apt install -y build-essential make cmake python3.13 python3.13-venv autopoint libtool pkg-config autoconf dejagnu meson ninja-build
git clone --recursive https://github.com/wasix-org/build-scripts.git
```

Build stuff

```bash
cd build-scripts
source ../wasix-clang/activate
make install-libs
# make install-wheels
```
