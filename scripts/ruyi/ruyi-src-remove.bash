#!/bin/bash

source "$RIT_DRIVER_PATH/utils/logging.bash"

LOG_DEBUG Running ruyi-src-remove

TMP_DIR="$RIT_TMP_PATH/rit-script-ruyi-src-install"

# upload telemetry data
. "$RIT_CASE_ENV_PATH"/ruyi_ruyi-src-install.pre
ruyi telemetry upload
ruyi self clean --all
rm -rf ~/.local/share/ruyi/ ~/.local/state/ruyi/ ~/.cache/ruyi/

rm -rf "$TMP_DIR" ~/.local/bin/ruyi

rm -f "$RIT_CASE_ENV_PATH"/ruyi_ruyi-src-install.pre
rm -f "$RIT_CASE_ENV_PATH"/ruyi_ruyi-src-install.post

