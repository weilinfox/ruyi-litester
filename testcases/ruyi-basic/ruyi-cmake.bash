# NOTE: Test ruyi venv cmake toolchain file
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi update

ruyi install gnu-plct-xthead

venv_path=/tmp/rit-ruyi-basic-ruyi-cmake
ruyi venv -t gnu-plct-xthead sipeed-lpi4a "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-cmake/sysroot

. "$venv_path"/bin/ruyi-activate

echo Gcc compilation checkpoint
old_path="$(pwd)"
mkdir "$venv_path"/test_tmp && cd "$venv_path"/test_tmp
ruyi extract coremark\(1.0.1\)
# CHECK-LABEL: info: extracting
# CHECK: info: package

sed -i 's/\bgcc\b/riscv64-plctxthead-linux-gnu-gcc/g' linux64/core_portme.mak
make PORT_DIR=linux64 link
# CHECK-LABEL: riscv64-plctxthead-linux-gnu-gcc
# CHECK: Link performed along with compile

riscv64-plctxthead-linux-gnu-readelf -h ./coremark.exe
# CHECK-LABEL: ELF Header:
# CHECK: ELF64
# CHECK: RISC-V

ruyi-deactivate
cd "$old_path"
rm -rf "$venv_path"

