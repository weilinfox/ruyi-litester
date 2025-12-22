#!/usr/bin/env bash

set -euo pipefail

debug_env() {
  echo "================ ENV DEBUG BEGIN ================"
  echo "[DEBUG] date: $(date || echo 'date failed')"
  echo "[DEBUG] whoami: $(whoami || echo 'whoami failed')"
  echo "[DEBUG] id: $(id || echo 'id failed')"
  echo "[DEBUG] pwd: $(pwd || echo 'pwd failed')"
  echo "[DEBUG] shell options: \$- = $-"

  echo
  echo "---- uname -a ----"
  uname -a || true

  echo
  echo "---- /etc/os-release ----"
  if [[ -r /etc/os-release ]]; then
    cat /etc/os-release
  else
    echo "no /etc/os-release"
  fi

  echo
  echo "---- lsb_release -a ----"
  if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a || true
  else
    echo "lsb_release not installed"
  fi

  echo
  echo "---- locale ----"
  if command -v locale >/dev/null 2>&1; then
    locale || echo "locale command failed"
  else
    echo "locale command not found"
  fi

  echo
  echo "---- LANG / LC_* ----"
  echo "LANG=${LANG-<unset>}"
  echo "LC_ALL=${LC_ALL-<unset>}"
  env | grep '^LC_' || echo "no LC_* in env"

  echo
  echo "---- locale config files ----"
  for f in /etc/locale.gen /etc/locale.conf /etc/default/locale; do
    if [[ -r "$f" ]]; then
      echo ">>> $f"
      cat "$f"
    else
      echo ">>> $f (not present)"
    fi
  done

  echo "---- timezone ----"
  echo "TZ=${TZ-<unset>}"
  if [ -L /etc/localtime ]; then
    echo "/etc/localtime -> $(readlink -f /etc/localtime || true)"
  elif [ -f /etc/localtime ]; then
    echo "/etc/localtime is a regular file"
  else
    echo "/etc/localtime not found"
  fi

  echo
  echo "---- env (sorted) ----"
  env | sort

  echo
  echo "---- network ----"
  for host in github.com wps.com; do
    if nc -z "$host" 443; then
      echo "[OK] $host: succeeded"
    else
      echo "[WARN] $host: failed"
    fi
  done

  echo "================= ENV DEBUG END ================="
  echo
}

debug_env

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

