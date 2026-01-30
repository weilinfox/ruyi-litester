# NOTE: Test ruyi list
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi version
# CHECK-LABEL: Ruyi
# CHECK: License: Apache-2.0

ruyi update

ruyi list --name-contains ""
# NOTE: warn that output order of packages varies on machines
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

ruyi uninstall gnu-milkv-milkv-duo-bin -y || true
ruyi list --name-contains 'gnu-milkv-milkv-duo-bin' --is-installed y
# CHECK-LABEL: List of available packages:
# CHECK-NOT: installed

ruyi list --name-contains 'gnu-milkv-milkv-duo-bin' --is-installed n
# CHECK-LABEL: List of available packages:
# CHECK: toolchain/gnu-milkv-milkv-duo-bin

ruyi install gnu-milkv-milkv-duo-bin
ruyi list --name-contains 'gnu-milkv-milkv-duo-bin' --is-installed y
# CHECK-LABEL: List of available packages:
# CHECK: installed

ruyi list --name-contains 'gnu-milkv-milkv-duo-bin' --is-installed n
# CHECK-LABEL: List of available packages:
# CHECK-NOT: toolchain/gnu-milkv-milkv-duo-bin

ruyi list --category-is source
# CHECK-LABEL: List of available packages:
# CHECK: source/coremark

ruyi list --category-contains sourc
# CHECK-LABEL: List of available packages:
# CHECK: source/coremark

ruyi list profiles
# CHECK: needs quirks:

ruyi list --category-contains ""
# CHECK-LABEL: List of available packages:
# CHECK-NOT: Package declares
# CHECK: * toolchain
# CHECK-NOT: Package declares

ruyi list --category-contains "" --verbose
# CHECK-LABEL: ## {{.*}}
# CHECK: ## toolchain
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ### Binary artifacts
# CHECK: ### Toolchain metadata
# CHECK: * Target:
# CHECK: * Flavors:
# CHECK: * Components:

ruyi list --category-is "toolchain"
# CHECK-LABEL: List of available packages:
# CHECK-NOT: Package declares
# CHECK: * toolchain
# CHECK-NOT: Package declares

ruyi list --category-is "toolchain" --verbose
# CHECK-LABEL: ## {{.*}}
# CHECK: ## toolchain
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ### Binary artifacts
# CHECK: ### Toolchain metadata
# CHECK: * Target:
# CHECK: * Flavors:
# CHECK: * Components: