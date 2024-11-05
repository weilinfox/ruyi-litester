#!/bin/bash

SELF_PATH=$(realpath $(dirname $0)/../../)

source "$SELF_PATH/driver/utils/logging.bash"

LOG_DEBUG Running ruyi-src-remove

TMP_DIR="/tmp/rit-script-ruyi-src-install"

~/.local/bin/ruyi self clean --all
rm -rf ~/.local/share/ruyi/ ~/.local/state/ruyi/ ~/.cache/ruyi/

rm -rf "$TMP_DIR" ~/.local/bin/ruyi

rm -f "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.pre
rm -f "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.post

