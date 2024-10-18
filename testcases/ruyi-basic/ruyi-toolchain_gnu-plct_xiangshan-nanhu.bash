# NOTE: Test ruyi gnu-plct toolchain xiangshan-nanhu profile
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi update

ruyi install gnu-plct

venv_path=/tmp/rit-ruyi-basic-ruyi-toolchain_gnu-plct_xiangshan-nanhu
ruyi venv -t gnu-plct xiangshan-nanhu "$venv_path"
# CHECK-LABEL: info: Creating a Ruyi virtual environment at
# CHECK: info: The virtual environment is now created.

mkdir "$venv_path"/test_tmp
cat > "$venv_path"/test_tmp/test.c << EOF
int main()
{
        int a = 1, b = 2, c = 3, ret;

        asm ("add.uw %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );          // zba
        asm ("orn %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );             // zbb
        asm ("clmul %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );           // zbc
        asm ("bclr %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );            // zbs
        asm ("pack %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );            // zbkb
        asm ("clmul %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );           // zbkc
        asm ("xperm8 %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );          // zbkx
        asm ("aes64dsm %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );        // zknd
        asm ("aes64es %0, %1, %2" :"=r"(ret) :"r"(a), "r"(b) );         // zkne
        asm ("sha512sig0 %0, %1" :"=r"(ret) :"r"(a) );                  // zknh
        asm ("sm4ed %0, %1, %2, 1" :"=r"(ret) :"r"(a), "r"(b) );        // zksed
        asm ("sm3p0 %0, %1" :"=r"(ret) :"r"(a) );                       // zksh
        // CFH                                                          // zicbom
        // CFH                                                          // zicboz

        return 0;
}
EOF

source "$venv_path"/bin/ruyi-activate

echo "Gcc check point"
# CHECK-LABEL Gcc check point
riscv64-plct-linux-gnu-gcc -O2 -c -o "$venv_path"/test_tmp/test.o "$venv_path"/test_tmp/test.c
echo $?
# CHECK-NEXT: 0

ruyi-deactivate
rm -rf "$venv_path"

