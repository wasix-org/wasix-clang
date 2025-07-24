# wasix-clang

A lightweight clang wrapper that adds all the flags to build for WASIX.

## Installation

You can install `wasix-clang` by running the following command:

```bash
curl -sSf https://raw.githubusercontent.com/wasix-org/wasix-clang/refs/heads/main/setup.sh | bash
```

This will download a pre-built clang toolchain, wasmer executable, and WASIX sysroot and put them in `~/.wasix-clang`.

## Usage

After installing wasix-clang you can activate an `wasix-clang` environment for crosscompiling by typing

```bash
source ~/.wasix-clang/activate
```

This will add `wasix-clang` to your PATH, set all the common config variables (like `CC`, `CXX`, `LD`...), and setup a binfmt wrapper so you can run wasix binaries directly.

Alternatively, you can use `wasix-clang` and `wasix-clang++` without the environment. They are intended to work exactly like `clang` and `clang++`. If you are not using the activated environment and are running into issues, make sure that your are using the other tools from the LLVM build that is included with this project (in ~/.wasix-clang/wasix-llvm).


### Build something with the `wasix-clang` environment

Building most C/C++ projects should just work if you have activated `wasix-clang`. For example to build zlib do the fo

```bash
source ~/.wasix-clang/activate
git clone https://github.com/madler/zlib.git
cd zlib
./configure
make -j8
# You have build zlib for WASIX. Go link your other programs with it
```

### Simple example

You can use `wasix-clang` and `wasix-clang++` just like you would use `clang` and `clang++` (because they are only light wrappers around clang that add a few flags).

For example to build a helloworld program you can just do:

```bash
wasix-clang helloworld.c -o helloworld
wasmer run helloworld

# Or if you are in a wasix-clang environment just
./helloworld
```

### Old example

Example for building a ton of python packages:

```bash
# Install deps and clone repo
sudo apt install -y build-essential make cmake python3.13 python3.13-venv autopoint libtool pkg-config autoconf dejagnu meson ninja-build bison flex perl patchelf po4a yq
# Only for giflib docs
sudo apt install -y xmlto imagemagick
# Install nix (Required for pandoc)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo sh -s -- install $(! test -f /.dockerenv || echo "linux --init none") --no-confirm
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
git clone --recursive https://github.com/wasix-org/build-scripts.git

cd build-scripts
source ~/wasix-clang/activate
make install-libs
# make install-wheels
```

## Manual install

You can also fetch the dependencies manually by cloning the repository and running `setup.sh`.

```bash
sudo apt update -y
sudo apt install -y git wget curl sudo xz-utils
git clone https://github.com/wasix-org/wasix-clang.git

bash ./wasix-clang/setup.sh
```

The above example was tested in a clean ubuntu environment created with:

```bash
multipass launch 25.04 -n wasix-test --disk 50G --cpus 4 --momory 16G
multipass shell wasix-test
```