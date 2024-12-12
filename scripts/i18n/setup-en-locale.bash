#!/bin/bash
echo en_US.UTF-8 UTF-8 | sudo tee /etc/locale.gen

sudo locale-gen

cat > /tmp/locale.sh <<EOF
export LANG=en_US.UTF-8
export PYTHONIOENCODING=utf-8
export LC_ALL=en_US.UTF-8
EOF

chmod +x /tmp/locale.sh