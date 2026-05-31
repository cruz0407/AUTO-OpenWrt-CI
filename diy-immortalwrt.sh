#!/bin/bash
#=================================================
# Description: ImmortalWrt 编译前自定义脚本
#=================================================

# 修复 golang 版本过低导致 xray-core 等包编译失败
sed -i 's/GOTOOLCHAIN=local/GOTOOLCHAIN=auto/g' feeds/packages/lang/golang/golang-build.sh 2>/dev/null || true

# 修改默认IP为 192.168.5.3
sed -i 's/192.168.1.1/192.168.5.3/g' package/base-files/files/bin/config_generate

# 在 DISTRIB_REVISION 前插入编译日期
BUILD_DATE=$(date +%Y/%-m/%-d)
sed -i "s|DISTRIB_REVISION='|DISTRIB_REVISION='[$BUILD_DATE] |g" package/base-files/files/etc/openwrt_release 2>/dev/null || true

# ttyd 自动免密登录 root
find . -path "*/ttyd/files/ttyd.config" -exec sed -i "s|/bin/login'|/bin/login -f root'|g" {} \; 2>/dev/null || true

# 自动判断内核版本：testing 版本更高则启用 CONFIG_TESTING_KERNEL
KERNEL_VER=$(grep 'KERNEL_PATCHVER:=' target/linux/x86/Makefile | awk -F':=' '{print $2}' | tr -d ' ')
TESTING_VER=$(grep 'KERNEL_TESTING_PATCHVER:=' target/linux/x86/Makefile | awk -F':=' '{print $2}' | tr -d ' ')
HIGHEST=$(printf "%s\n%s" "$KERNEL_VER" "$TESTING_VER" | sort -V | tail -1)
if [ "$HIGHEST" = "$TESTING_VER" ] && [ "$TESTING_VER" != "$KERNEL_VER" ]; then
  sed -i 's/.*CONFIG_TESTING_KERNEL.*/CONFIG_TESTING_KERNEL=y/' .config
  echo "使用 testing 内核: $TESTING_VER"
else
  sed -i 's/.*CONFIG_TESTING_KERNEL.*/# CONFIG_TESTING_KERNEL is not set/' .config
  echo "使用稳定内核: $KERNEL_VER"
fi
