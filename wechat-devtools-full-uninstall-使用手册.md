# 微信开发者工具彻底卸载脚本使用手册

## 概述

`wechat-devtools-full-uninstall.sh` 是一个专门为 macOS 设计的微信开发者工具彻底卸载脚本。它能够：

- 删除微信开发者工具应用程序
- 清理所有相关配置文件
- 删除缓存、日志和偏好设置
- 清理 Homebrew 安装记录（如适用）
- 重建 Launch Services 数据库

## 系统要求

- macOS 操作系统
- Bash shell（macOS 默认自带）

## 使用方法

### 基本用法

```bash
# 给脚本添加执行权限
chmod +x wechat-devtools-full-uninstall.sh

# 运行脚本
./wechat-devtools-full-uninstall.sh
```

### 命令行参数

| 参数 | 说明 |
|------|------|
| `--force` | 跳过确认提示，直接执行卸载 |
| `--dry-run` | 预览模式，只显示将要删除的文件，不实际执行 |

### 使用示例

```bash
# 标准卸载（需要确认）
./wechat-devtools-full-uninstall.sh

# 强制卸载（跳过确认）
./wechat-devtools-full-uninstall.sh --force

# 预览将要删除的文件
./wechat-devtools-full-uninstall.sh --dry-run

# 强制卸载并预览
./wechat-devtools-full-uninstall.sh --force --dry-run
```

## 卸载内容

脚本会清理以下位置的文件和目录：

### 1. 应用程序
- `/Applications/` 下的微信开发者工具相关应用
- `~/Applications/` 下的微信开发者工具相关应用

### 2. 配置文件
- `~/Library/Application Support/` 下的相关目录
- `~/.config/` 下的相关配置
- `~/.wechat_devtools` 目录

### 3. 缓存文件
- `~/Library/Caches/` 下的相关缓存

### 4. 偏好设置
- `~/Library/Preferences/` 下的 .plist 文件

### 5. 日志和崩溃报告
- `~/Library/Logs/` 下的日志文件
- `~/Library/Logs/DiagnosticReports/` 下的崩溃报告

### 6. 应用状态
- `~/Library/Saved Application State/` 下的保存状态

### 7. Homebrew 相关（如适用）
- 通过 Homebrew 安装的 cask 包

## 安全特性

1. **系统检查**：脚本会检查是否在 macOS 系统上运行
2. **确认提示**：默认情况下会要求用户确认（除非使用 `--force` 参数）
3. **干运行模式**：支持 `--dry-run` 参数预览将要执行的操作
4. **错误处理**：使用 `set -euo pipefail` 确保错误时立即停止

## 输出说明

脚本使用颜色编码的输出：

- 🟢 **绿色**：成功信息
- 🔴 **红色**：错误信息
- 🟡 **黄色**：警告信息（如干运行模式）

## 注意事项

1. **备份重要数据**：运行脚本前，请确保已备份微信开发者工具中的重要项目
2. **管理员权限**：某些操作可能需要管理员权限
3. **重启建议**：卸载完成后建议重启 Finder 或注销/重启系统以确保完全生效
4. **不可逆操作**：删除的文件无法恢复，请谨慎操作

## 故障排除

如果遇到问题：

1. 确保脚本有执行权限
2. 检查是否在 macOS 系统上运行
3. 使用 `--dry-run` 参数先预览操作
4. 如需调试，可以移除 `set -euo pipefail` 行或添加 `set -x` 来查看详细执行过程

## 版本历史

- v1.0 - 初始版本，支持完整的微信开发者工具卸载

## 许可证

本脚本遵循 MIT 许可证。