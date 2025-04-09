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

ruyi list --name-contains "" --verbose
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

ruyi list profiles
# CHECK: needs flavor(s):

ruyi list --category-contains ""
# NOTE: warn that output order of packages varies on machines
# CHECK-LABEL: List of available packages:
# CHECK-NOT: Package declares
# CHECK: * toolchain
# CHECK-NOT: Package declares

ruyi list --category-is "toolchain"
# NOTE: warn that output order of packages varies on machines
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

