# NOTE: Test ruyi list
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi version
# CHECK-LABEL: Ruyi
# CHECK: License: Apache-2.0

ruyi update

ruyi list
# CHECK-LABEL: List of available packages:
# CHECK-NOT: Package declares
# CHECK: * source
# CHECK-NOT: Package declares
# CHECK: * toolchain
# CHECK-NOT: Package declares
# CHECK: * board-image
# CHECK-NOT: Package declares
# CHECK: * emulator
# CHECK-NOT: Package declares

ruyi list --verbose
# CHECK: ## source
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ## toolchain
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ### Binary artifacts
# CHECK: ### Toolchain metadata
# CHECK: * Target:
# CHECK: * Flavors:
# CHECK: * Components:
# CHECK: ## board-image
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ## emulator
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ### Binary artifacts

ruyi list profiles
# CHECK: needs flavor(s):

