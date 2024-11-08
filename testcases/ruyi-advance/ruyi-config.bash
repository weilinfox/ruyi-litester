# NOTE: Test ruyi config file
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

tmp_path="/tmp/rit-ruyi-advance-ruyi-config"
tmp_repo="$tmp_path"/packages-index

cfg_d="~/.config/ruyi"
cfg_f="$cfg_d/config.toml"
cfg_bak="$tmp_path"/config.toml

rm -rf "$tmp_path"
mkdir -p "$cfg_d" "$tmp_path"

# NOTE: backup old config file
[ -f "$cfg_f" ] && mv -v "$cfg_f" "$cfg_bak"

# NOTE: create test config
function config_create() {
	cat >"$cfg_f" <<EOF
[repo]
remote = "https://github.com/ruyisdk/packages-index.git"
branch = "main"
EOF
}

config_create
cat >>"$cfg_f" <<EOF
local = "$tmp_path"
EOF
ruyi update
ruyi update
echo Check reconfigured local repo
# CHECK-LABEL: Check reconfigured local repo
[ -d "$tmp_repo" ]; echo $?
# CHECK-NEXT: 0
rm -rf "$tmp_repo"

config_create
echo Check bad remote repo
# CHECK-LABEL: Check bad remote repo
sed -i "s|remote.*|remote = \"https://wrong_magic\"|" $cfg_f
ruyi update
# CHECK: wrong_magic

config_create
echo Check bad branch
# CHECK-LABEL: Check bad branch
sed -i "s|branch.*|branch = \"wrong_magic\"|" $cfg_f
ruyi update
# CHECK: wrong_magic

[ -f "$cfg_bak" ] && mv -v "$cfg_bak" "$cfg_f"
rm -rf "$tmp_repo"

