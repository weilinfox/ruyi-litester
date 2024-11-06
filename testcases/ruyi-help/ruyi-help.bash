# NOTE: Test --help option for ruyi command and subcommands
# RUN: bash %s | FileCheck --dump-input=always %s

ruyi
# CHECK-LABEL: usage: ruyi [
# CHECK: RuyiSDK Package Manager
# CHECK: options:
# CHECK: subcommands:

ruyi --help
# CHECK-LABEL: usage: ruyi [
# CHECK: RuyiSDK Package Manager
# CHECK: options:
# CHECK: subcommands:

ruyi device --help
# CHECK-LABEL: usage: ruyi device [
# CHECK: options:
# CHECK: subcommands:

ruyi extract --help
# CHECK-LABEL: usage: ruyi extract [
# CHECK: positional arguments:
# CHECK: options:

ruyi install --help
# CHECK-LABEL: usage: ruyi install [
# CHECK: positional arguments:
# CHECK: options:

ruyi i --help
# CHECK-LABEL: usage: ruyi install [
# CHECK: positional arguments:
# CHECK: options:

ruyi list --help
# CHECK-LABEL: usage: ruyi list [
# CHECK: positional arguments:
# CHECK: options:

ruyi list profiles --help
# CHECK-LABEL: usage: ruyi list profiles [
# CHECK: options:

ruyi news --help
# CHECK-LABEL: usage: ruyi news [
# CHECK: options:
# CHECK: subcommands:

ruyi news read --help
# CHECK-LABEL: usage: ruyi news read [
# CHECK: Outputs news item(s)
# CHECK: positional arguments:
# CHECK: options:

ruyi news list --help
# CHECK-LABEL: usage: ruyi news list [
# CHECK: options:

ruyi update --help
# CHECK-LABEL: usage: ruyi update [
# CHECK: options:

ruyi venv --help
# CHECK-LABEL: usage: ruyi venv [
# CHECK: positional arguments:
# CHECK-NEXT: profile
# CHECK-NEXT: dest
# CHECK: options:

ruyi admin --help
# CHECK-LABEL: usage: ruyi admin [
# CHECK: options:
# CHECK: subcommands:

ruyi admin run-plugin-cmd --help
# CHECK-LABEL: usage: ruyi admin run-plugin-cmd [
# CHECK: positional arguments:

ruyi admin checksum --help
# CHECK-LABEL: usage: ruyi admin checksum [
# CHECK: positional arguments:
# CHECK-NEXT: file
# CHECK: options:

ruyi admin format-manifest --help
# CHECK-LABEL: usage: ruyi admin format-manifest [
# CHECK: positional arguments:
# CHECK-NEXT: file
# options:

ruyi self --help
# CHECK-LABEL: usage: ruyi self [
# CHECK: options:
# CHECK: subcommands:
# CHECK: clean
# CHECK: uninstall

ruyi self clean --help
# CHECK-LABEL: usage: ruyi self clean [
# CHECK: options:

ruyi self uninstall --help
# CHECK-LABEL: usage: ruyi self uninstall [
# CHECK: options:
# CHECK: --purge

ruyi version --help
# CHECK-LABEL: usage: ruyi version [
# CHECK: options:

