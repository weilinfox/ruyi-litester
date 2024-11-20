# NOTE: Test ruyi xdg env support
# RUN: XDG_CACHE_HOME=~/.cache/rit-ruyi-advance-ruyi-xdg \
# RUN:     XDG_CACHE_HOME=~/.local/share/rit-ruyi-advance-ruyi-xdg \
# RUN:     XDG_STATE_HOME=~/.local/state/rit-ruyi-advance-ruyi-xdg \
# RUN:     bash %s | FileCheck %s --check-prefixes=CHECK-XDG,CHECK
# RUN: bash %s | FileCheck %s --check-prefixes=CHECK-DEF,CHECK

export RUYI_DEBUG=x

export XDG_CACHE_HOME=$XDG_CACHE_HOME
export XDG_DATA_HOME=$XDG_DATA_HOME
export XDG_STATE_HOME=$XDG_STATE_HOME

xdg_ruyi_dir="$XDG_CACHE_HOME"/ruyi
xdg_ruyi_data_dir="$XDG_DATA_HOME"/ruyi
xdg_ruyi_state_dir="$XDG_STATE_HOME"/ruyi
default_ruyi_dir=~/.cache/ruyi
default_ruyi_data_dir=~/.local/share/ruyi
default_ruyi_state_dir=~/.local/state/ruyi

[ -z "$XDG_CACHE_HOME" ] || mkdir -p "$XDG_CACHE_HOME"
[ -z "$XDG_DATA_HOME" ] || mkdir -p "$XDG_DATA_HOME"
[ -z "$XDG_STATE_HOME" ] || mkdir -p "$XDG_STATE_HOME"
rm -rf "$xdg_ruyi_dir" "$xdg_ruyi_data_dir" "$xdg_ruyi_state_dir"
rm -rf "$default_ruyi_dir" "$default_ruyi_data_dir" "$default_ruyi_state_dir"

ruyi update

ruyi list
# CHECK-LABEL: List of available packages:
ruyi list --verbose
# CHECK: Package declares
# CHECK: ### Binary artifacts
# CHECK: ### Toolchain metadata
ruyi news list
# CHECK-LABEL: News items:
ruyi news read 1
# CHECK-LABEL: RuyiSDK now supports displaying news
ruyi install gnu-plct

echo Now check directory creation
# CHECK-LABEL: Now check directory creation

[ -d $xdg_ruyi_dir ]; echo $?
[ -d $xdg_ruyi_data_dir ]; echo $?
[ -d $xdg_ruyi_state_dir ]; echo $?
# CHECK-DEF-COUNT-3: 1
# CHECK-XDG-COUNT-3: 0
[ -d $default_ruyi_dir ]; echo $?
[ -d $default_ruyi_data_dir ]; echo $?
[ -d $default_ruyi_state_dir ]; echo $?
# CHECK-DEF-COUNT-3: 0
# CHECK-XDG-COUNT-3: 1

# TODO: ruyi self clean remove test

rm -rf "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

