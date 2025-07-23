# NOTE: Test --output-completion-script
#
# RUN: bash %s 2>&1 | FileCheck %s

ruyi --output-completion-script
# CHECK-LABEL: argument --output-completion-script: expected one argument

ruyi --output-completion-script=bash
# CHECK-LABEL: #compdef ruyi
# CHECK: _python_argcomplete_ruyi

ruyi --output-completion-script=zsh
# CHECK-LABEL: #compdef ruyi
# CHECK: if [[ -z "${ZSH_VERSION-}" ]]; then

ruyi --output-completion-script=fish
# CHECK-LABEL: ValueError: Unsupported shell: fish

