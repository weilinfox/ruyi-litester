#!/bin/bash

source "$RIT_DRIVER_PATH/utils/logging.bash"
source "$RIT_DRIVER_PATH/utils/libs.bash"

LOG_DEBUG Running ruyi-src-install

TMP_DIR="$RIT_TMP_PATH/rit-script-ruyi-src-install"
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

# Debian/Ubuntu FileCheck wrapper
if ( HOST_HAS_FEATURE "debian" || HOST_HAS_FEATURE "ubuntu" ) && \
    [ -z "$(whereis -b FileCheck | cut -d':' -f2)" ] && [ ! -z "$(ls /usr/bin/FileCheck*)" ]; then
	for fc in $(ls /usr/bin/FileCheck*); do
		ln -s $fc ~/.local/bin/FileCheck
		break
	done
fi

chmod +x ~/.local/bin/ruyi

rm -rf ~/.local/share/ruyi/ ~/.local/state/ruyi/ ~/.cache/ruyi/

PYTHON_INTER=$(ls "$TMP_DIR"/venv-ruyi/lib)
echo "export PYTHONPATH=$TMP_DIR/venv-ruyi/lib/$PYTHON_INTER/site-packages/" >> "$RIT_CASE_ENV_PATH"/ruyi_ruyi-src-install.pre
echo "export PYTHONPATH=$PYTHONPATH" >> "$RIT_CASE_ENV_PATH"/ruyi_ruyi-src-install.post
if [ -z "$(whereis ruyi | cut -d: -f2)" ]; then
	echo "export PATH=~/.local/bin:$PATH" >> "$RIT_CASE_ENV_PATH"/ruyi_ruyi-src-install.pre
	echo "export PATH=$PATH" >> "$RIT_CASE_ENV_PATH"/ruyi_ruyi-src-install.post
fi

