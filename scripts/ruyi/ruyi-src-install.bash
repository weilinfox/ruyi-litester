#!/bin/bash

SELF_PATH=$(realpath $(dirname $0)/../../)

TMP_DIR="/tmp/rit-script-ruyi-src-install"
RUYI_MASTER="https://github.com/ruyisdk/ruyi/"

mkdir -p "$TMP_DIR" ~/.local/bin/

git clone --depth=1 "$RUYI_MASTER" "$TMP_DIR"

python3 -m venv --copies "$TMP_DIR"/venv-ruyi
source "$TMP_DIR"/venv-ruyi/bin/activate
pip install -i https://mirrors.bfsu.edu.cn/pypi/web/simple build installer poetry \
       	arpy certifi jinja2 packaging pygit2 pyyaml requests rich semver tomlkit typing_extensions

python3 -m build --wheel --skip-dependency-check --no-isolation "$TMP_DIR"
python3 -m installer "$TMP_DIR"/dist/*.whl

deactivate

cat > ~/.local/bin/ruyi << EOF
#!/bin/bash

source "$TMP_DIR"/venv-ruyi/bin/activate

python3 -m ruyi \$@

deactivate
EOF

chmod +x ~/.local/bin/ruyi

rm -rf ~/.local/share/ruyi/ ~/.local/state/ruyi/ ~/.cache/ruyi/

if [ -z "$(whereis ruyi | cut -d: -f2)" ]; then
	echo "export PATH=~/.local/bin:$PATH" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.pre
	echo "export PATH=$PATH" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.post
fi

