#!/bin/bash

SELF_PATH=$(realpath $(dirname $0)/../../)

source "$SELF_PATH/driver/utils/logging.bash"

LOG_DEBUG Running ruyi-bin-install

mkdir -p ~/.local/bin/

RUYI_VERSION=${RUYI_VERSION:-"0.20.0"}

case "$(uname -m)" in
	x86_64)
		RUYI_ARCH="amd64"
		;;
	aarch64)
		RUYI_ARCH="arm64"
		;;
	riscv64)
		RUYI_ARCH="riscv64"
		;;
esac

RUYI_LINK="https://mirror.iscas.ac.cn/ruyisdk/ruyi/releases/${RUYI_VERSION}/ruyi.${RUYI_ARCH}"

if wget --help > /dev/null; then
	wget $RUYI_LINK -O ~/.local/bin/ruyi
elif curl --help > /dev/null; then
	curl $RUYI_LINK -o ~/.local/bin/ruyi
else
	LOG_ERROR "missing wget/curl support"
	exit -1
fi

chmod +x ~/.local/bin/ruyi

rm -rf ~/.local/share/ruyi/ ~/.local/state/ruyi/ ~/.cache/ruyi/

if [ -z "$(whereis ruyi | cut -d: -f2)" ]; then
	echo "export PATH=~/.local/bin:$PATH" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-bin-install.pre
	echo "export PATH=$PATH" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-bin-install.post
fi

