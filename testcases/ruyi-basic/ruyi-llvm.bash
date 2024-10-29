# NOTE: Test ruyi venv --sysroot-from with llvm toolchain
# REQUIRES: x86_64 || riscv64
#
# RUN: bash %s 2>&1 | FileCheck %s

qemu_pkg=qemu-user-riscv-upstream
qemu_cmd="-e qemu-user-riscv-upstream"
qemu_bin=ruyi-qemu
if [ "$(python3 -c "import platform; print(platform.machine())")" == "riscv64" ]; then
	qemu_pkg=
	qemu_cmd=
	qemu_bin=
fi

ruyi update

ruyi install llvm-upstream gnu-plct $qemu_pkg

venv_path=/tmp/rit-ruyi-basic-ruyi-llvm
ruyi venv -t llvm-upstream --sysroot-from gnu-plct $qemu_cmd generic "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.
# CHECK: ruyi-deactivate
# CHECK: /tmp/rit-ruyi-basic-ruyi-llvm/sysroot

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
clang -O3 "$venv_path"/test_tmp/hello_ruyi.c -o "$venv_path"/test_tmp/hello_ruyi.o
echo $?
# CHECK-LABEL: Gcc compilation checkpoint
# CHECK-NEXT: 0

$qemu_bin "$venv_path"/test_tmp/hello_ruyi.o
# CHECK: hello, ruyi

ruyi-deactivate
rm -rf "$venv_path"

