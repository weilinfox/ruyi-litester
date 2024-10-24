# NOTE: Test ruyi config file
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

tmp_path="/tmp/rit-ruyi-advance-ruyi-config"
tmp_repo="$tmp_path"/packages-index

cfg_f="~/.config/ruyi/config.toml"
cfg_bak="$tmp_path"/config.toml

rm -rf "$tmp_path"
mkdir -p "$tmp_path"

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

cp "$cfg_bak" "$cfg_f"
echo Check bad remote repo
# CHECK-LABEL: Check bad remote repo
sed -i "s|remote.*|remote = \"https://wrong_magic\"|" $cfg_f
ruyi update
# CHECK: wrong_magic

cp "$cfg_bak" "$cfg_f"
echo Check bad branch
# CHECK-LABEL: Check bad branch
sed -i "s|branch.*|branch = \"wrong_magic\"|" $cfg_f
ruyi update
# CHECK: wrong_magic

mv "$cfg_bak" "$cfg_f"
rm -rf "$tmp_repo"

