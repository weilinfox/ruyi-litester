#!/bin/bash

for i in $HOST_FEATURES; do
if [[ "$i" == "ubuntu" ]] || [[ "$i" == "debian" ]]; then
    echo zh_CN.UTF-8 UTF-8 | sudo tee /etc/locale.gen

    sudo locale-gen
	break
elif [[ "$i" == "gentoo" ]]; then

	break
elif [[ "$i" == "fedora" ]]; then
    sudo localedef -c -i zh_CN -f UTF-8 zh_CN.UTF-8

	break
fi
done

cat > /tmp/locale.sh <<EOF
export LANG=zh_CN.UTF-8
export PYTHONIOENCODING=utf-8
export LC_ALL=zh_CN.UTF-8
EOF

chmod +x /tmp/locale.sh
