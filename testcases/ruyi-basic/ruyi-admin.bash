# NOTE: Test ruyi admin
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi admin manifest $0
# CHECK-SAME: [
# CHECK: "name":
# CHECK: "size":
# CHECK: "checksums":
ruyi admin manifest --format json $0
# CHECK-SAME: [
# CHECK: "name":
# CHECK: "size":
# CHECK: "checksums":

ruyi admin manifest --format toml $0
# CHECK-LABEL: [[distfiles]]
# CHECK-NEXT: name =
# CHECK-NEXT: size =
# CHECK-EMPTY:
# CHECK-NEXT: [distfiles.checksums]
# CHECK-NEXT: sha256 =
# CHECK-NEXT: sha512 =

