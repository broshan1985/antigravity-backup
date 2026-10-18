#!/usr/bin/env bash
set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE="$BACKUP_DIR/antigravity_data.tar.gz"

if [ ! -f "$ARCHIVE" ]; then
  echo "❌ 未找到备份文件 $ARCHIVE"
  exit 1
fi

echo "=== 开始恢复 Antigravity 项目与历史记录 ==="

# 1. 检查 Antigravity 是否在运行
if pgrep -f "Antigravity" >/dev/null 2>&1; then
  echo "⚠️  检测到 Antigravity 正在运行，建议先退出 Antigravity 应用再执行恢复，以防数据覆盖冲突。"
  read -p "是否强制继续恢复? (y/N) " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "已取消。"
    exit 1
  fi
fi

# 2. 解压到临时目录
TEMP_DIR=$(mktemp -d)
tar -xzf "$ARCHIVE" -C "$TEMP_DIR"

# 3. 确保目标目录结构
mkdir -p "$HOME/.gemini/config"
mkdir -p "$HOME/.gemini/antigravity"

# 4. 恢复配置
echo "-> 正在恢复项目定义与配置..."
if [ -d "$TEMP_DIR/data/config/projects" ]; then
  mkdir -p "$HOME/.gemini/config/projects"
  rsync -a "$TEMP_DIR/data/config/projects/" "$HOME/.gemini/config/projects/"
fi
[ -f "$TEMP_DIR/data/config/config.json" ] && cp "$TEMP_DIR/data/config/config.json" "$HOME/.gemini/config/"
[ -f "$TEMP_DIR/data/config/mcp_config.json" ] && cp "$TEMP_DIR/data/config/mcp_config.json" "$HOME/.gemini/config/"

# 5. 恢复历史数据与产物
echo "-> 正在恢复对话历史与 Brain 产物..."
[ -f "$TEMP_DIR/data/antigravity/installation_id" ] && cp "$TEMP_DIR/data/antigravity/installation_id" "$HOME/.gemini/antigravity/"
[ -f "$TEMP_DIR/data/antigravity/antigravity_state.pbtxt" ] && cp "$TEMP_DIR/data/antigravity/antigravity_state.pbtxt" "$HOME/.gemini/antigravity/"
[ -f "$TEMP_DIR/data/antigravity/conversation_summaries.db" ] && cp "$TEMP_DIR/data/antigravity/conversation_summaries.db" "$HOME/.gemini/antigravity/"

if [ -d "$TEMP_DIR/data/antigravity/conversations" ]; then
  mkdir -p "$HOME/.gemini/antigravity/conversations"
  rsync -a "$TEMP_DIR/data/antigravity/conversations/" "$HOME/.gemini/antigravity/conversations/"
fi

if [ -d "$TEMP_DIR/data/antigravity/brain" ]; then
  mkdir -p "$HOME/.gemini/antigravity/brain"
  rsync -a "$TEMP_DIR/data/antigravity/brain/" "$HOME/.gemini/antigravity/brain/"
fi

rm -rf "$TEMP_DIR"

echo "============================================================"
echo "🎉 恢复完成！重新打开 Antigravity 即可看到所有 Projects、历史对话和 MCP 工具配置。"
echo "============================================================"
