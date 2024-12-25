# NOTE: Test box64
# REQUIRES: riscv64
#
# RUN: bash %s 2>&1 | FileCheck %s

ruyi update

ruyi install box64-upstream

~/.local/share/ruyi/binaries/riscv64/box64-upstream-*/bin/box64 --version
# CHECK: Box64

