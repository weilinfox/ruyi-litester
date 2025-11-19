#!/usr/bin/bash

[ -d ~/.config/ruyi ] && rm -rf ~/.config/ruyi
rm -rf /tmp/rit.bash

./rit.bash ruyi -p ruyi-bin

cat >> ruyi-litester-reports/report_my_configs.sh <<EOF
TEST_LITESTER_PATH=$(pwd)
TEST_START_TIME=${TEST_START_TIME}
EOF

DISTRO_ID=${DISTRO_ID}-$(uname -m)
cp -v ruyi_ruyi-bin_ruyi-basic_*.log ruyi-litester-reports/report_tmpl/26test_log.md
bash ruyi-litester-reports/report_gen.sh ${DISTRO_ID}

rm -f *.md

sudo mv ruyi-test-logs.tar.gz /artifacts/ruyi-test-${DISTRO_ID}-logs.tar.gz
sudo mv ruyi-test-logs_failed.tar.gz /artifacts/ruyi-test-${DISTRO_ID}-logs_failed.tar.gz
sudo mv ruyi_report/*.md /artifacts/

