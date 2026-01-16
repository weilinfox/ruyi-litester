# NOTE: Test ruyi list
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi version
# CHECK-LABEL: Ruyi
# CHECK: License: Apache-2.0

ruyi update

ruyi list --name-contains ""
# NOTE: warn that output order of packages varias on machines
# CHECK-LABEL: List of available packages:
# CHECK-NOT: Package declares
# CHECK: * toolchain
# CHECK-NOT: Package declares

ruyi list --name-contains "gnu-plct-xthead" --verbose
# CHECK-LABEL: ## toolchain/gnu-plct-xthead {{.*}}
# CHECK: * Slug: (none)
# CHECK: * Package kind:
# CHECK: * Vendor: PLCT
# CHECK: * Upstream version number:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ### Binary artifacts
# CHECK: ### Toolchain metadata
# CHECK: * Target:
# CHECK: * Quirks:
# CHECK: * Components:

ruyi uninstall gnu-upstream -y || true
ruyi list --name-contains 'gnu-upstream' --is-installed y
# CHECK-LABEL: List of available packages:
# CHECK-NOT: installed

ruyi list --name-contains 'gnu-upstream' --is-installed n
# CHECK-LABEL: List of available packages:
# CHECK: toolchain/gnu-upstream

ruyi install gnu-upstream
ruyi list --name-contains 'gnu-upstream' --is-installed y
# CHECK-LABEL: List of available packages:
# CHECK: installed

ruyi list --name-contains 'gnu-upstream' --is-installed n
# CHECK-LABEL: List of available packages:
# CHECK-NOT: toolchain/gnu-upstream

ruyi list --category-is source
# CHECK-LABEL: List of available packages:
# CHECK: source/coremark

ruyi list --category-contains sourc
# CHECK-LABEL: List of available packages:
# CHECK: source/coremark

ruyi list profiles
# CHECK: needs quirks:

