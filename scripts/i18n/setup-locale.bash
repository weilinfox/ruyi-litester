#!/bin/bash
for i in $RIT_CASE_FEATURES; do
if [[ "$i" == "ubuntu" ]] || [[ "$i" == "debian" ]] || [[ "$i" == "gentoo" ]]; then
    echo $1.UTF-8 UTF-8 | sudo tee /etc/locale.gen

    sudo locale-gen
    break

elif [[ "$i" == "fedora" ]] || [[ "$i" == "openeuler" ]]; then
    sudo localedef -c -i $1 -f UTF-8 $1.UTF-8

    break
fi
done

cat > "$RIT_CASE_ENV_PATH"/ruyi_ruyi-i18n.pre <<EOF
export LANG=$1.UTF-8
export PYTHONIOENCODING=utf-8
export LC_ALL=$1.UTF-8
EOF
