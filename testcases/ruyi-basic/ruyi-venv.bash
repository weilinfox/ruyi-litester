# RUN: bash %s 2>&1 | FileCheck %s

export RUYI_DEBUG=x

RUYI_DEBUG= ruyi update >/dev/null 2>&1
RUYI_DEBUG= ruyi install gnu-plct >/dev/null 2>&1
RUYI_DEBUG= ruyi install gnu-milkv-milkv-duo-musl-bin >/dev/null 2>&1

venv_path=/tmp/rit-ruyi-basic-ruyi-venv-single
rm -rf "$venv_path"

RUYI_DEBUG= ruyi venv --toolchain gnu-plct milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-single/sysroot

readlink "$venv_path/sysroot"
# CHECK: {{.*}}sysroot

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

rm -rf "$venv_path"

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --without-sysroot milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate

test ! -e "$venv_path/sysroot" && echo "no sysroot"
# CHECK: no sysroot

rm -rf "$venv_path"

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --sysroot-from gnu-milkv-milkv-duo-musl-bin milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-single/sysroot

test -d "$venv_path/sysroot/usr/lib" && echo "sysroot usr/lib exists"
# CHECK: sysroot usr/lib exists

rm -rf "$venv_path"

venv_path=/tmp/rit-ruyi-basic-ruyi-venv-multi
rm -rf "$venv_path"

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --toolchain gnu-milkv-milkv-duo-musl-bin --sysroot-from gnu-plct milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-multi/sysroot

source "$venv_path"/bin/ruyi-activate
riscv64-plct-linux-gnu-gcc --version
# CHECK-LABEL: riscv64-plct-linux-gnu-gcc
# CHECK: Copyright

riscv64-unknown-linux-musl-gcc --version
# CHECK-LABEL: riscv64-unknown-linux-musl-gcc
# CHECK: Copyright

readlink "$venv_path/sysroot"
# CHECK: {{.*}}plct

ruyi-deactivate

rm -rf "$venv_path"

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --toolchain gnu-milkv-milkv-duo-musl-bin --without-sysroot milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate

test ! -e "$venv_path/sysroot" && echo "no sysroot"
# CHECK: no sysroot

rm -rf "$venv_path"

RUYI_DEBUG= ruyi venv --toolchain gnu-plct --toolchain gnu-milkv-milkv-duo-musl-bin --sysroot-from gnu-milkv-milkv-duo-musl-bin milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv-multi/sysroot

readlink "$venv_path/sysroot"
# CHECK: sysroot.riscv64-unknown-linux-musl

test -d "$venv_path/sysroot/usr/lib" && echo "sysroot usr/lib exists"
# CHECK: sysroot usr/lib exists

rm -rf "$venv_path"

