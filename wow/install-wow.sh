#!/bin/bash
# 安装打了魔兽鼠标补丁的 RustDesk 1.5.3（macOS arm64）。不用 sudo。
set -euo pipefail
B=~/RustDesk-backup; URL=https://github.com/zhangpo0607-cell/rustdesk/releases/download/wow-1.5.3/rustdesk-1.5.3-wow-aarch64.dmg; SIZE=31118983
echo "== 0. 检查 UU 远程（备用通道）"
ps aux | grep -i -E "uu ?remote|uuyc|UU远程" | grep -v grep || { echo "没找到 UU 远程进程，停止，不替换"; exit 1; }
mkdir -p "$B"
echo "== 1. 备份原版"
[ -d "$B/RustDesk-1.5.3-original.app" ] || ditto /Applications/RustDesk.app "$B/RustDesk-1.5.3-original.app"
codesign -dv "$B/RustDesk-1.5.3-original.app" 2>&1 | grep -E "Identifier|TeamIdentifier"
echo "== 2. 下载并校验"
curl -fL -o "$B/wow.dmg" "$URL"
[ "$(stat -f%z "$B/wow.dmg")" = "$SIZE" ] || { echo "大小不对，停止"; exit 1; }
MP=$(hdiutil attach -nobrowse -readonly "$B/wow.dmg" | grep -o '/Volumes/.*' | head -1)
rm -rf "$B/RustDesk-wow.app"; ditto "$MP/RustDesk.app" "$B/RustDesk-wow.app"; hdiutil detach "$MP" -quiet
xattr -cr "$B/RustDesk-wow.app"
codesign --force --deep -s - "$B/RustDesk-wow.app"
echo "== 3. 替换"
osascript -e 'quit app "RustDesk"' || true; sleep 3
rm -rf "$B/RustDesk-replaced-tmp.app"
mv /Applications/RustDesk.app "$B/RustDesk-replaced-tmp.app"
ditto "$B/RustDesk-wow.app" /Applications/RustDesk.app
pkill -u "$(id -u)" -f RustDesk.app || true; sleep 5
open -a /Applications/RustDesk.app
sleep 5; ps aux | grep -i rustdesk | grep -v grep
echo "完成。去 系统设置 > 隐私与安全性，重新勾选 RustDesk 的『辅助功能』和『屏幕录制』（先删掉旧条目再加）。"
