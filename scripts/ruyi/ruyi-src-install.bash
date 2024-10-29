#!/bin/bash

SELF_PATH=$(realpath $(dirname $0)/../../)

source "$SELF_PATH/driver/utils/logging.bash"

LOG_DEBUG Running ruyi-src-install

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

python3 -m ruyi \$@
EOF

chmod +x ~/.local/bin/ruyi

rm -rf ~/.local/share/ruyi/ ~/.local/state/ruyi/ ~/.cache/ruyi/

PYTHON_INTER=$(ls "$TMP_DIR"/venv-ruyi/lib)
echo "export PYTHONPATH=$TMP_DIR/venv-ruyi/lib/$PYTHON_INTER/site-packages/" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.pre
echo "export PYTHONPATH=$PYTHONPATH" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.post
if [ -z "$(whereis ruyi | cut -d: -f2)" ]; then
	echo "export PATH=~/.local/bin:$PATH" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.pre
	echo "export PATH=$PATH" >> "$SELF_PATH"/rit.bash_env/ruyi_ruyi-src-install.post
fi

