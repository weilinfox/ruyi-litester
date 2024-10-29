# NOTE: Test ruyi gnu-plct-rv64ilp32-elf toolchain
# RUN: bash %s 2>&1 | FileCheck %s

export RUYI_DEBUG=x

ruyi update

ruyi install gnu-plct-rv64ilp32-elf

venv_path=/tmp/rit-ruyi-basic-ruyi-toolchain_gnu-plct-rv64ilp32-elf
ruyi venv -t gnu-plct-rv64ilp32-elf --without-sysroot baremetal-rv64ilp32 "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at {{.*}}
# CHECK: info: The virtual environment is now created.

mkdir "$venv_path"/test_tmp
cat > "$venv_path"/test_tmp/test.c << EOF
long long add(long long *a, long long b) { return *a + b; }
void check(int);
void checkSizes(void) { check(sizeof(int)); check(sizeof(long)); check(sizeof(long long)); check(sizeof(void *)); }
EOF

source "$venv_path"/bin/ruyi-activate

riscv64-plct-elf-gcc -O2 -c "$venv_path"/test_tmp/test.c -o "$venv_path"/test_tmp/test.o
echo "Gcc check point $?"
# CHECK-LABEL: Gcc check point 0
riscv64-plct-elf-readelf -h "$venv_path"/test_tmp/test.o
# CHECK-LABEL: ELF Header:
# CHECK: ELF32
riscv64-plct-elf-objdump -dw "$venv_path"/test_tmp/test.o
# CHECK: elf32-littleriscv
# CHECK: a0

ruyi-deactivate
rm -rf "$venv_path"

