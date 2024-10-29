# NOTE: Test ruyi venv creation
# RUN: bash %s 2>&1 | FileCheck %s

export RUYI_DEBUG=x

ruyi update

ruyi install gnu-plct

venv_path=/tmp/rit-ruyi-basic-ruyi-venv
# NOTE: too many debug messages
RUYI_DEBUG= ruyi venv --toolchain gnu-plct milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-venv/sysroot

oldps1="$PS1"
source "$venv_path"/bin/ruyi-activate
echo "$PS1"
# CHECK: «Ruyi rit-ruyi-basic-ruyi-venv»

riscv64-plct-linux-gnu-gcc --version
# CHECK-LABEL: riscv64-plct-linux-gnu-gcc
# CHECK: Copyright

ruyi-deactivate
echo PS1 checkpoint
# CHECK-LABEL: PS1 checkpoint
[[ "$PS1" == "$oldps1" ]]; echo $?
# CHECK-NEXT: 0

rm -rf "$venv_path"

