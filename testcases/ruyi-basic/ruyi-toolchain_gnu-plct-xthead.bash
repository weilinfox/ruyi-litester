# NOTE: Test ruyi xthead toolchain and its qemu
# REQUIRES: x86_64 || revyos
#
# RUN: bash %s 2>&1 | FileCheck %s

export RUYI_DEBUG=x

qemu_pkg=qemu-user-riscv-xthead
qemu_cmd="-e qemu-user-riscv-xthead"
qemu_bin=ruyi-qemu
if [ "$(python3 -c "import platform; print(platform.machine())")" == "riscv64" ]; then
	qemu_pkg=
	qemu_cmd=
	qemu_bin=
fi

ruyi update

ruyi install gnu-plct-xthead $qemu_pkg

venv_path=/tmp/rit-ruyi-basic-ruyi-toolchain_gnu-plct-xthead
ruyi venv -t gnu-plct-xthead $qemu_cmd sipeed-lpi4a "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.

. "$venv_path"/bin/ruyi-activate

mkdir "$venv_path"/test_tmp
cat > "$venv_path"/test_tmp/hello_ruyi.c << EOF
#include <stdio.h>

int main()
{
    printf("hello, ruyi");

    return 0;
}
EOF

riscv64-plctxthead-linux-gnu-gcc "$venv_path"/test_tmp/hello_ruyi.c -o "$venv_path"/test_tmp/hello_ruyi.o

$qemu_bin "$venv_path"/test_tmp/hello_ruyi.o
# CHECK: hello, ruyi

ruyi-deactivate
rm -rf "$venv_path"

