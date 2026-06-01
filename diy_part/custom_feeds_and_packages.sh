#!/bin/bash
#=================================================
# Description: 统一 Feeds 和自定义包管理
# 供 diy-part1.sh 调用
#=================================================

# 第三方 feeds 列表（格式: "src-git <name> <url>;<branch>"）
export repos=(
  "src-git small https://github.com/kenzok8/small"
  "src-git kenzo https://github.com/kenzok8/openwrt-packages"
  "src-git ghfu https://github.com/smallprogram/luci-app-ghfu.git;main"
)

# 克隆自定义软件包到 package/custom_packages/
clone_custom_packages() {
  mkdir -p package/custom_packages

  # 在这里添加需要 clone 的自定义包
  # git clone https://github.com/xxx/yyy package/custom_packages/yyy
}
