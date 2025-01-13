#!/bin/bash

source "$RIT_DRIVER_PATH/utils/logging.bash"

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

if [[ "$RUYI_VERSION" =~ "-" ]]; then
	RUYI_LINK="https://mirror.iscas.ac.cn/ruyisdk/ruyi/testing/${RUYI_VERSION}/ruyi.${RUYI_ARCH}"
else
	RUYI_LINK="https://mirror.iscas.ac.cn/ruyisdk/ruyi/releases/${RUYI_VERSION}/ruyi.${RUYI_ARCH}"
fi

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
	echo "export PATH=~/.local/bin:$PATH" >> "$RIT_CASE_ENV_PATH"/ruyi_ruyi-bin-install.pre
	echo "export PATH=$PATH" >> "$RIT_CASE_ENV_PATH"/ruyi_ruyi-bin-install.post
fi

~/.local/bin/ruyi telemetry consent

