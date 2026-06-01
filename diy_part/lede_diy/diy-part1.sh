#!/bin/bash
#=================================================
# Description: LEDE DIY Part1 — feeds 注入（feeds update 之前执行）
#=================================================

# 加载共享 feeds 配置
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../custom_feeds_and_packages.sh"

echo "=========================================="
echo "  LEDE DIY Part1: Feeds 冲突检查与注入"
echo "=========================================="

# 备份原始 feeds 配置
cp feeds.conf.default feeds.conf.default.bak
echo "✓ 已备份 feeds.conf.default"

# 删注释行（避免 grep 误匹配注释掉的 feed）
sed -i '/^#/d' feeds.conf.default

# 倒序遍历 repos 数组，检查冲突后只添加不重复的 feed
for ((i=${#repos[@]}-1; i>=0; i--)); do
  repo="${repos[$i]}"
  feed_name=$(echo "$repo" | awk '{print $2}')

  if ! grep -q "src-git $feed_name " feeds.conf.default; then
    echo "$repo" > /tmp/feeds_temp
    cat feeds.conf.default >> /tmp/feeds_temp
    mv /tmp/feeds_temp feeds.conf.default
    echo "✓ 已添加: $repo"
  else
    echo "⊙ 跳过（已存在）: $repo"
  fi
done

echo ""
echo "=== 最终 feeds.conf.default ==="
cat feeds.conf.default
echo "=========================================="

# 克隆自定义包
clone_custom_packages

echo "DIY Part1 完成！"
