#!/usr/bin/env bash
# wechat-devtools-full-uninstall.sh
# macOS 微信开发者工具彻底卸载脚本
set -euo pipefail

RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; NC="\033[0m"

confirm=true
dry_run=false

for arg in "$@"; do
  case "$arg" in
    --force) confirm=false ;;
    --dry-run) dry_run=true ;;
    *) echo -e "${YELLOW}未知参数: $arg${NC}";;
  esac
done

function log() { echo -e "$@"; }
function act() {
  local target="$1"
  if $dry_run; then
    log "${YELLOW}[dry-run] 将删除:${NC} $target"
  else
    if [[ -e "$target" || -L "$target" || "$target" == *"*"* ]]; then
      rm -rf "$target" 2>/dev/null || true
    fi
  fi
}

# 1) 基本检查
if [[ "$(uname -s)" != "Darwin" ]]; then
  log "${RED}该脚本仅适用于 macOS.${NC}"; exit 1
fi

# 2) 提示确认
if $confirm && ! $dry_run; then
  read -r -p "将彻底卸载【微信开发者工具】并清理残留。继续? [y/N] " ans
  if [[ ! "${ans:-}" =~ ^[Yy]$ ]]; then
    log "已取消"; exit 0
  fi
fi

log "开始卸载 微信开发者工具 ..."

# 3) 结束相关进程
log "尝试结束相关进程 ..."
pids=$(pgrep -f "微信开发者工具|WeChat.*DevTools|wechatwebdevtools" || true)
if [[ -n "${pids}" ]]; then
  if $dry_run; then
    log "${YELLOW}[dry-run] 将 kill 进程:${NC} ${pids}"
  else
    pkill -f "微信开发者工具|WeChat.*DevTools|wechatwebdevtools" || true
    sleep 1
  fi
fi

# 4) 删除应用本体（可能的名称/位置）
app_dirs=(
  "/Applications"
  "$HOME/Applications"
)
app_globs=(
  "微信开发者工具*.app"
  "WeChat*DevTools*.app"
  "wechat*devtools*.app"
  "wechatwebdevtools*.app"
)

for d in "${app_dirs[@]}"; do
  for g in "${app_globs[@]}"; do
    for path in "$d"/$g; do
      [[ -e "$path" ]] && { log "删除应用: $path"; act "$path"; }
    done
  done
done

# 5) 清理配置/缓存/日志/偏好/状态等
paths=(
  # Application Support / 配置
  "$HOME/Library/Application Support/微信开发者工具"
  "$HOME/Library/Application Support/wechat_devtools"
  "$HOME/Library/Application Support/Tencent/微信开发者工具"
  "$HOME/Library/Application Support/Tencent/WeChatDevTools"
  "$HOME/Library/Application Support/wechatwebdevtools"

  # Caches
  "$HOME/Library/Caches/微信开发者工具"
  "$HOME/Library/Caches/com.tencent.wechatdevtools"
  "$HOME/Library/Caches/wechat_devtools"
  "$HOME/Library/Caches/wechatwebdevtools"

  # Preferences (.plist)
  "$HOME/Library/Preferences/微信开发者工具.plist"
  "$HOME/Library/Preferences/com.tencent.WeChatDevTools.plist"
  "$HOME/Library/Preferences/com.tencent.wechatdevtools.plist"

  # Saved Application State
  "$HOME/Library/Saved Application State/微信开发者工具.savedState"
  "$HOME/Library/Saved Application State/com.tencent.wechatdevtools.savedState"

  # Logs / 崩溃报告
  "$HOME/Library/Logs/微信开发者工具"
  "$HOME/Library/Logs/WeChatDevTools"
  "$HOME/Library/Logs/com.tencent.wechatdevtools"
  "$HOME/Library/Logs/DiagnosticReports/WeChatDevTools*"
  "$HOME/Library/Logs/DiagnosticReports/微信开发者工具*"

  # 可能的 CLI/配置目录
  "$HOME/.config/微信开发者工具"
  "$HOME/.config/wechat-devtools"
  "$HOME/.wechat_devtools"
)

for p in "${paths[@]}"; do
  # 检查路径是否包含通配符
  if [[ "$p" == *"*"* ]]; then
    # 包含通配符，需要展开
    for path in $p; do
      [[ -e "$path" || -L "$path" ]] && { log "清理: $path"; act "$path"; }
    done
  else
    # 不包含通配符，直接处理（保持引号避免空格问题）
    [[ -e "$p" || -L "$p" ]] && { log "清理: $p"; act "$p"; }
  fi
done

# 6) 如果曾通过 Homebrew 安装（可选清理）
if command -v brew >/dev/null 2>&1; then
  if brew list --cask 2>/dev/null | grep -qi "wechat.*devtools\|wechatwebdevtools"; then
    if $dry_run; then
      log "${YELLOW}[dry-run] 将执行: brew uninstall --cask wechatwebdevtools && brew zap --cask wechatwebdevtools${NC}"
    else
      brew uninstall --cask wechatwebdevtools 2>/dev/null || true
      # brew zap 会进一步清理已知残留
      brew zap --cask wechatwebdevtools 2>/dev/null || true
    fi
  fi
fi

# 7) 可选：重建 Launch Services 数据库（清理“打开方式”残影）
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [[ -x "$LSREGISTER" ]]; then
  if $dry_run; then
    log "${YELLOW}[dry-run] 将重建 Launch Services 数据库${NC}"
  else
    "$LSREGISTER" -kill -r -domain local -domain system -domain user >/dev/null 2>&1 || true
  fi
fi

log "${GREEN}已完成卸载与清理。建议重启一次 Finder 或注销/重启以彻底生效。${NC}"
