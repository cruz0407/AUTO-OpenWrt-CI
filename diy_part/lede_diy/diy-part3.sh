#!/bin/bash
#=================================================
# Description: LEDE DIY Part3 — 编译中裁剪（编译过程中执行，可选）
#=================================================

echo "=========================================="
echo "  LEDE DIY Part3: 编译中优化"
echo "=========================================="

# 在此添加内核模块裁剪、删除不需要的包等操作
# 目前为占位，后续可扩展

# 修复 smartdns 缺少 zlib 依赖声明（kenzo feed 上游 Makefile 未声明 DEPENDS:=+zlib）
if [ -f feeds/kenzo/smartdns/Makefile ] && ! grep -q '+zlib' feeds/kenzo/smartdns/Makefile 2>/dev/null; then
  sed -i 's/DEPENDS:=/DEPENDS:=+zlib /' feeds/kenzo/smartdns/Makefile
  echo "✓ 已修复 smartdns 缺少 zlib 依赖"
fi

echo "DIY Part3: 无需额外操作（占位）"
echo "DIY Part3 完成！"
