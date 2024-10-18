# NOTE: Test ruyi install and extract
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi update

# NOTE: binary install test
http_proxy=http://wrong.proxy https_proxy=http://wrong.proxy ruyi install gnu-upstream
# CHECK-LABEL: info: downloading
# CHECK-COUNT-3: warn: failed to fetch distfile
# CHECK: fatal error: failed to fetch
# CHECK: Downloads can fail for a multitude of reasons
# CHECK: * Basic connectivity problems
ruyi install gnu-upstream
# CHECK-LABEL: info: downloading
# CHECK: info: extracting
# CHECK: info: package
ruyi install gnu-upstream
ruyi install name:gnu-upstream
ruyi install gnu-upstream'(0.20231212.0)'
# CHECK-COUNT-3: info: skipping already installed package

