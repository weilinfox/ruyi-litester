#!/bin/bash
for i in $HOST_FEATURES; do
if [[ "$i" == "ubuntu" ]] || [[ "$i" == "debian" ]]; then
    echo en_US.UTF-8 UTF-8 | sudo tee /etc/locale.gen

    sudo locale-gen
	break
elif [[ "$i" == "gentoo" ]]; then

	break
elif [[ "$i" == "fedora" ]]; then
    localedef -c -i en_US -f UTF-8 en_US.UTF-8

	break
fi
done