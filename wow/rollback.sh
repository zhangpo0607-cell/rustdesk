#!/bin/bash
# 换回原版 RustDesk 1.5.3（官方签名）。不用 sudo。
set -euo pipefail
B=~/RustDesk-backup
[ -d "$B/RustDesk-1.5.3-original.app" ] || { echo "找不到备份"; exit 1; }
osascript -e 'quit app "RustDesk"' || true; sleep 3
rm -rf /Applications/RustDesk.app
ditto "$B/RustDesk-1.5.3-original.app" /Applications/RustDesk.app
pkill -u "$(id -u)" -f RustDesk.app || true; sleep 5
open -a /Applications/RustDesk.app
echo "已换回原版。如果远程连不上，到 系统设置 > 隐私与安全性 重新勾选 RustDesk 的辅助功能和屏幕录制。"
