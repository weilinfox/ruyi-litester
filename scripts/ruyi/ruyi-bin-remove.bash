#!/bin/bash

SELF_PATH=$(realpath $(dirname $0)/../../)

rm -f ~/.local/bin/ruyi

rm -f "$SELF_PATH"/rit.bash_env/ruyi_ruyi-bin-install.pre
rm -f "$SELF_PATH"/rit.bash_env/ruyi_ruyi-bin-install.post

