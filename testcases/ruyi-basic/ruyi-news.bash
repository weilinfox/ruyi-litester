# NOTE: Test ruyi news items
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi update
# CHECK-LABEL: There are
# CHECK: You can read them with ruyi news read.

[ -f "~/.local/state/ruyi/news.read.txt" ] && rm ~/.local/state/ruyi/news.read.txt

ruyi news list
# CHECK-LABEL: News items:
# CHECK: No.
# CHECK-NEXT: ─────
# CHECK-NEXT: 2024-01-14-ruyi-news

ruyi news read 1
# CHECK-LABEL: # RuyiSDK

ruyi news list --new
# CHECK-LABEL: News items:
# CHECK: No.
# CHECK-NEXT: ─────
# CHECK-NEXT: 2024-01-15-new-board-images

ruyi news read
# CHECK: # Release notes

ruyi news list --new
# CHECK-LABEL: News items:
# CHECK-EMPTY:
# CHECK-NEXT:   (no unread item)

ruyi news list
# CHECK-LABEL: News items:
# CHECK: No.
# CHECK-NEXT: ─────
# CHECK-NEXT: 2024-01-14-ruyi-news

ruyi update
# CHECK-NOT: You can read them with ruyi news read.

