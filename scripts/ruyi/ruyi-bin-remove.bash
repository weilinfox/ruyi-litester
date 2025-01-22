#!/bin/bash

source "$RIT_DRIVER_PATH/utils/logging.bash"

LOG_DEBUG Running ruyi-bin-remove

~/.local/bin/ruyi self clean --all
rm -rf ~/.local/share/ruyi/ ~/.local/state/ruyi/ ~/.cache/ruyi/

~/.local/bin/ruyi telemetry upload
rm -f ~/.local/bin/ruyi

rm -f "$RIT_CASE_ENV_PATH"/ruyi_ruyi-bin-install.pre
rm -f "$RIT_CASE_ENV_PATH"/ruyi_ruyi-bin-install.post

