# NOTE: Ruyi news i18n test
# RUN: set -e; \
# RUN: source /tmp/locale.sh; \
# RUN: eval "$(locale | grep LC_CTYPE)"; lc_ctype=${LC_CTYPE::-6}; unset LC_CTYPE; \
# RUN: check_file=%s; [ -f "$check_file.$lc_ctype" ] && check_file="$check_file.$lc_ctype"; \
# RUN: bash %s | FileCheck --dump-input=always $check_file

ruyi news list
# CHECK-LABEL: News items
# CHECK: RuyiSDK now supports displaying news

ruyi news read 1
# CHECK-LABEL: # RuyiSDK now supports displaying news
# CHECK: Thank you for supporting RuyiSDK!

