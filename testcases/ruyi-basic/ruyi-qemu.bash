# NOTE: Test ruyi venv --emulator with qemu-user-riscv-upstream
# REQUIRES: x86_64
#
# RUN: bash %s 2>&1 | FileCheck %s

export RUYI_DEBUG=x

ruyi update

ruyi install gnu-plct qemu-user-riscv-upstream

venv_path=/tmp/rit-ruyi-basic-ruyi-qemu
ruyi venv -t gnu-plct -e qemu-user-riscv-upstream milkv-duo "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-qemu/sysroot

. "$venv_path"/bin/ruyi-activate

echo Gcc compilation checkpoint
mkdir "$venv_path"/test_tmp
cat > "$venv_path"/test_tmp/hello_ruyi.c << EOF
#include <stdio.h>

int main()
{
    printf("hello, ruyi");

    return 0;
}
EOF
riscv64-plct-linux-gnu-gcc "$venv_path"/test_tmp/hello_ruyi.c -o "$venv_path"/test_tmp/hello_ruyi.o
echo $?
# CHECK-LABEL: Gcc compilation checkpoint
# CHECK-NEXT: 0

ruyi-qemu "$venv_path"/test_tmp/hello_ruyi.o
# NOTE: do not use CHECK-NEXT to skip qemu warnings
# CHECK: hello, ruyi

ruyi-deactivate
rm -rf "$venv_path"

