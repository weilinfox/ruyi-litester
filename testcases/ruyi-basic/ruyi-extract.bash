# NOTE: Test ruyi install and extract
# NOTE: I dont know why ``ruyi extract`` outputs:
# NOTE:   "info: extracting" and "info: package"
# NOTE:   are print to stderr
# RUN: bash %s 2>&1 | FileCheck %s

export RUYI_DEBUG=x

ruyi update

old_path=$(pwd)
tmp_path="/tmp/rit-ruyi-basic-ruyi-install"
mkdir "$tmp_path" && cd "$tmp_path"
ruyi extract ruyisdk-demo
# CHECK-LABEL: info: extracting {{.*}} for package {{.*}}
# CHECK: info: package
ls -la rvv-autovec
# CHECK: Makefile
# CHECK: test.c
cd "$old_path"
rm -rf "$tmp_path"

