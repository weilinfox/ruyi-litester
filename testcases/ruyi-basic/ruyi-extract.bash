# NOTE: Test ruyi install and extract
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi update

old_path=$(pwd)
tmp_path="/tmp/rit-ruyi-basic-ruyi-install"
mkdir "$tmp_path" && cd "$tmp_path"
ruyi extract ruyisdk-demo
# CHECK-LABEL: info: extracting
# CHECK: info: package
ls -la coremark.h
# CHECK: coremark.h
cd "$old_path"
rm -rf "$tmp_path"

