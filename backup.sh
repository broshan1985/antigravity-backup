#!/usr/bin/env bash
set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="$BACKUP_DIR/data"
ARCHIVE="$BACKUP_DIR/antigravity_data.tar.gz"

echo "=== 开始备份 Antigravity 配置与对话记录 ==="

# 1. 准备临时同步目录
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/config"
mkdir -p "$TEMP_DIR/antigravity"

# 2. 检查点 SQLite 数据库 (WAL 模式合并)
if [ -f "$HOME/.gemini/antigravity/conversation_summaries.db" ]; then
  sqlite3 "$HOME/.gemini/antigravity/conversation_summaries.db" "PRAGMA wal_checkpoint(TRUNCATE);" 2>/dev/null || true
fi

# 3. 复制配置
echo "-> 正在备份项目定义与配置..."
if [ -d "$HOME/.gemini/config/projects" ]; then
  mkdir -p "$TEMP_DIR/config/projects"
  rsync -a "$HOME/.gemini/config/projects/" "$TEMP_DIR/config/projects/" >/dev/null
fi
[ -f "$HOME/.gemini/config/config.json" ] && cp "$HOME/.gemini/config/config.json" "$TEMP_DIR/config/"
[ -f "$HOME/.gemini/config/mcp_config.json" ] && cp "$HOME/.gemini/config/mcp_config.json" "$TEMP_DIR/config/"

# 4. 复制会话与产物
echo "-> 正在备份对话历史与 Brain 产物..."
[ -f "$HOME/.gemini/antigravity/installation_id" ] && cp "$HOME/.gemini/antigravity/installation_id" "$TEMP_DIR/antigravity/"
[ -f "$HOME/.gemini/antigravity/antigravity_state.pbtxt" ] && cp "$HOME/.gemini/antigravity/antigravity_state.pbtxt" "$TEMP_DIR/antigravity/"
[ -f "$HOME/.gemini/antigravity/conversation_summaries.db" ] && cp "$HOME/.gemini/antigravity/conversation_summaries.db" "$TEMP_DIR/antigravity/"

if [ -d "$HOME/.gemini/antigravity/conversations" ]; then
  mkdir -p "$TEMP_DIR/antigravity/conversations"
  rsync -a "$HOME/.gemini/antigravity/conversations/" "$TEMP_DIR/antigravity/conversations/" >/dev/null
fi

if [ -d "$HOME/.gemini/antigravity/brain" ]; then
  mkdir -p "$TEMP_DIR/antigravity/brain"
  rsync -a --exclude=".DS_Store" "$HOME/.gemini/antigravity/brain/" "$TEMP_DIR/antigravity/brain/" >/dev/null
fi

# 5. 打包归档
echo "-> 正在打包压缩归档..."
tar -czf "$ARCHIVE" -C "$BACKUP_DIR" data
rm -rf "$TEMP_DIR"

echo "-> 本地打包完成 ($ARCHIVE)！"

# 6. Git 提交并推送到 GitHub
if [ -d "$BACKUP_DIR/.git" ]; then
  cd "$BACKUP_DIR"
  git add antigravity_data.tar.gz backup.sh restore.sh README.md .gitignore
  if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "✅ 无新改动需要提交。"
  else
    git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "-> 正在推送到 GitHub..."
    git push -u origin main
    echo "✅ 备份已成功推送至 GitHub！"
  fi
fi
