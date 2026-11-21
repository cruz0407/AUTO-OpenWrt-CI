#!/bin/bash
#=================================================
# Description: LEDE DIY Part2 — 配置修改（feeds install 之后、defconfig 之前执行）
#=================================================

echo "=========================================="
echo "  LEDE DIY Part2: 配置定制"
echo "=========================================="

# Go 软件包可按 go.mod 要求升级构建用工具链。
go_package_mk=feeds/packages/lang/golang/golang-package.mk
sed -i 's/GOTOOLCHAIN=local/GOTOOLCHAIN=auto/' "$go_package_mk" || exit 1
grep -q 'GOTOOLCHAIN=auto' "$go_package_mk" || exit 1

# 测试内核的 xt_FLOWOFFLOAD 与当前内核 API 不兼容。
SELECTED_VER=$(awk -F ':=' '/^KERNEL_PATCHVER:=/ {print $2; exit}' target/linux/x86/Makefile)
if [ -z "$SELECTED_VER" ]; then
  echo '无法确定 LEDE x86 稳定内核版本' >&2
  exit 1
fi
sed -i '/^CONFIG_TESTING_KERNEL=/d; /^# CONFIG_TESTING_KERNEL is not set$/d' .config || exit 1
echo '# CONFIG_TESTING_KERNEL is not set' >> .config
echo "✓ 使用稳定内核: $SELECTED_VER"

# 确保 .config 中的 CONFIG_LINUX_X_XX 与实际内核版本一致
CONFIGURED_KERNEL=$(grep -oP 'CONFIG_LINUX_\K[0-9_]+(?==y)' .config 2>/dev/null | head -1 | tr '_' '.')
if [ -n "$CONFIGURED_KERNEL" ] && [ "$CONFIGURED_KERNEL" != "$SELECTED_VER" ]; then
  echo "⚠ .config 内核版本 ($CONFIGURED_KERNEL) 与源码树 ($SELECTED_VER) 不一致，自动修正..."
  sed -i '/CONFIG_LINUX_[0-9]_[0-9]*=/d' .config
  KERNEL_UNDERSCORE=$(echo "$SELECTED_VER" | tr '.' '_')
  echo "CONFIG_LINUX_${KERNEL_UNDERSCORE}=y" >> .config
  echo "✓ 已修正为内核 $SELECTED_VER"
else
  echo "✓ 内核版本 $SELECTED_VER 与源码树一致"
fi

# opkg uses -N for the package release, while APK uses -rN.
homeproxy_mk=package/feeds/small/luci-app-homeproxy/Makefile
if [ -f "$homeproxy_mk" ]; then
  sed -i -E '/^LUCI_EXTRA_DEPENDS:=sing-box /s/-r([0-9]+)\)/-\1)/' "$homeproxy_mk" || exit 1
fi

# 修改默认IP为 192.168.5.3
sed -i 's/192.168.1.1/192.168.5.3/g' package/base-files/files/bin/config_generate
echo "✓ 默认 IP: 192.168.5.3"

# 在 DISTRIB_REVISION 前插入编译日期
BUILD_DATE=$(date +%Y/%-m/%-d)
sed -i "s|DISTRIB_REVISION='|DISTRIB_REVISION='[$BUILD_DATE] |g" package/lean/default-settings/files/zzz-default-settings
echo "✓ 编译日期: $BUILD_DATE"

# ttyd 自动免密登录 root
sed -i "s|/bin/login'|/bin/login -f root'|g" feeds/packages/net/ttyd/files/ttyd.config 2>/dev/null || true
echo "✓ ttyd 免密登录"

# 清除默认密码
sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true
echo "✓ 已清除默认密码"

# 配置 OTA 固件更新插件 (luci-app-ghfu)
mkdir -p files/etc/uci-defaults
cat << 'EOF' > files/etc/uci-defaults/99-ghfu-config
#!/bin/sh
uci set ghfu.@ghfu[0].repo='cruz0407/AUTO-OpenWrt-CI'
uci set ghfu.@ghfu[0].enabled='1'
uci commit ghfu
exit 0
EOF
chmod +x files/etc/uci-defaults/99-ghfu-config
echo "✓ OTA 更新插件已配置"

echo "DIY Part2 完成！"
