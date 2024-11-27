
# #############################################
# @Author    :   weilinfox
# @Contact   :   caiweilin@iscas.ac.cn
# @Date      :   2023/10/24
# @License   :   Apache-2.0
# @Desc      :   ruyi-mugen common libs
# #############################################

source "${RIT_DRIVER_PATH}"/utils/mugen_libs.bash

RUYI_VERSION=${RUYI_VERSION:="0.16.0"}

ruyi_cache_dir() {
	echo "${XDG_CACHE_HOME:=~/.cache}"/ruyi
}

ruyi_data_dir() {
	echo "${XDG_DATA_HOME:=~/.local/share}"/ruyi
}

ruyi_state_dir() {
	echo "${XDG_STATE_HOME:=~/.local/state}"/ruyi
}

ruyi_config_dir() {
	echo "${XDG_CONFIG_HOME:=~/.config}"/ruyi
}

ruyi_curl() {
	local trys=0
	while true; do
		[ $trys -ge 20 ] && break
		[ -f $1 ] && rm -f $1
		curl -L -o $1 $2
		[ $? = 0 ] && break
		((trys++))
	done
}

remove_ruyi_data() {
	rm -rf $(ruyi_cache_dir) $(ruyi_data_dir) $(ruyi_state_dir) $(ruyi_config_dir)
}

install_ruyi_bin() {
	local arch="$(uname -m)"
	local link=

	[ "$arch"  == "x86_64" ] && arch='amd64'
	[ "$arch"  == "aarch64" ] && arch='arm64'
	if [[ "$RUYI_VERSION" =~ "-" ]]; then
		link=https://mirror.iscas.ac.cn/ruyisdk/ruyi/testing/${RUYI_VERSION}/ruyi.${arch}
	else
		link=https://mirror.iscas.ac.cn/ruyisdk/ruyi/releases/${RUYI_VERSION}/ruyi.${arch}
	fi

	PKG_INSTALL --fedora "curl git tar bzip2 xz zstd unzip lz4" \
		--debian --ubuntu "curl git tar bzip2 xz-utils zstd unzip lz4" \
		--archlinux "curl git tar bzip2 xz zstd unzip lz4" \
		--gentoo "net-misc/curl dev-vcs/git app-arch/tar app-arch/bzip2 app-arch/xz-utils app-arch/zstd app-arch/unzip app-arch/lz4"

	ruyi_curl ruyi $link

	chmod +x ruyi
	sudo ln -s $(realpath ruyi) /usr/bin/ruyi
	remove_ruyi_data

	mkdir -p "$(ruyi_config_dir)"
	cat >"$(ruyi_config_dir)/config.toml" <<EOF
[repo]
remote = "https://gitee.com/ruyisdk/packages-index.git"
branch = "main"
EOF
}

remove_ruyi_bin() {
	PKG_REMOVE

	remove_ruyi_data

	rm -f ruyi
	sudo rm -f /usr/bin/ruyi
}
