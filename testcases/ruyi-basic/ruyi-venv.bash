# NOTE: Test ruyi venv creation and sysroot options
# RUN: bash %s 2>&1 | FileCheck %s

export RUYI_DEBUG=x

ruyi update
ruyi install gnu-plct
ruyi install gnu-milkv-milkv-duo-musl-bin
ruyi install gnu-milkv-milkv-duo-elf-bin

# Test single toolchain with different sysroot options
venv_path=/tmp/rit-ruyi-basic-ruyi-venv-single

RUYI_DEBUG= ruyi venv --toolchain gnu-plct milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-single/sysroot

ls -la "$venv_path/sysroot"
# CHECK: usr
# CHECK: lib
# CHECK: etc

oldps1="$PS1"
source "$venv_path"/bin/ruyi-activate
echo "$PS1"
# CHECK: «Ruyi rit-ruyi-basic-ruyi-venv-single»

riscv64-plct-linux-gnu-gcc --version
# CHECK-LABEL: riscv64-plct-linux-gnu-gcc
# CHECK: Copyright

ruyi-deactivate
echo PS1 checkpoint
# CHECK-LABEL: PS1 checkpoint
[[ "$PS1" == "$oldps1" ]]; echo $?
# CHECK-NEXT: 0

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --without-sysroot milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate

test ! -d "$venv_path/sysroot" && echo "no sysroot"
# CHECK: no sysroot

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --sysroot-from gnu-milkv-milkv-duo-musl-bin milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-single/sysroot

ls -la "$venv_path/sysroot/usr/lib"
# CHECK: libc.so

rm -rf "$venv_path"

# Test multiple toolchains with different sysroot options
venv_path=/tmp/rit-ruyi-basic-ruyi-venv-multi

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --toolchain gnu-milkv-milkv-duo-musl-bin --toolchain gnu-milkv-milkv-duo-elf-bin milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-multi/sysroot

source "$venv_path"/bin/ruyi-activate
riscv64-plct-linux-gnu-gcc --version
# CHECK-LABEL: riscv64-plct-linux-gnu-gcc
# CHECK: Copyright

ruyi-deactivate

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --toolchain gnu-milkv-milkv-duo-musl-bin --toolchain gnu-milkv-milkv-duo-elf-bin --without-sysroot milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate

test ! -d "$venv_path/sysroot" && echo "no sysroot"
# CHECK: no sysroot

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --toolchain gnu-milkv-milkv-duo-musl-bin --toolchain gnu-milkv-milkv-duo-elf-bin --sysroot-from gnu-milkv-milkv-duo-musl-bin milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-multi/sysroot

ls -la "$venv_path/sysroot/usr/lib"
# CHECK: libc.so

rm -rf "$venv_path"
