#!/bin/bash
#=================================================
# Description: LEDE DIY Part2 — 配置修改（feeds install 之后、defconfig 之前执行）
#=================================================

echo "=========================================="
echo "  LEDE DIY Part2: 配置定制"
echo "=========================================="

# 修复 Go 版本过旧导致 go.mod ignore/tool 指令解析失败
# kenzo feed 的 AdGuardHome 等新包使用了 Go 1.24+ 特性
sed -i 's/GOTOOLCHAIN=local/GOTOOLCHAIN=auto/g' feeds/packages/lang/golang/golang-build.sh 2>/dev/null || true
echo "✓ GOTOOLCHAIN=auto"

# 自动判断内核版本：testing 版本更高则启用 CONFIG_TESTING_KERNEL
KERNEL_VER=$(grep 'KERNEL_PATCHVER:=' target/linux/x86/Makefile | awk -F':=' '{print $2}' | tr -d ' ')
TESTING_VER=$(grep 'KERNEL_TESTING_PATCHVER:=' target/linux/x86/Makefile | awk -F':=' '{print $2}' | tr -d ' ')
HIGHEST=$(printf "%s\n%s" "$KERNEL_VER" "$TESTING_VER" | sort -V | tail -1)
if [ "$HIGHEST" = "$TESTING_VER" ] && [ "$TESTING_VER" != "$KERNEL_VER" ]; then
  sed -i 's/.*CONFIG_TESTING_KERNEL.*/CONFIG_TESTING_KERNEL=y/' .config
  sed -i 's/.*CONFIG_PACKAGE_kmod-mdio-devres.*/CONFIG_PACKAGE_kmod-mdio-devres=y/' .config
  echo "✓ 使用 testing 内核: $TESTING_VER"
else
  sed -i 's/.*CONFIG_TESTING_KERNEL.*/# CONFIG_TESTING_KERNEL is not set/' .config
  echo "✓ 使用稳定内核: $KERNEL_VER"
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
