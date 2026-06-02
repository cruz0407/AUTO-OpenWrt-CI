#!/bin/bash
#=================================================
# Description: 生成 GitHub Actions Matrix JSON
# 当前支持 LEDE 和 ImmortalWrt 两个平台，各 x86_64 一个设备
#=================================================

source_code_platforms=(lede immortalwrt)

# LEDE 平台配置（单行 JSON，不可换行）
lede_value='{"PLATFORM":"lede","REPO_URL":"https://github.com/coolsnowwolf/lede","REPO_BRANCH":"master","CONFIG_FILE":"configs/x86_64-lede.config","CONFIG_NAME":"x86_64","DIY_P1":"diy_part/lede_diy/diy-part1.sh","DIY_P2":"diy_part/lede_diy/diy-part2.sh","DIY_P3":"diy_part/lede_diy/diy-part3.sh","DEPENDENCE":"diy_part/lede_dependence","SEED_CONFIG":"configs/seed/lede_seed.config","RELEASE_PREFIX":"LEDE"}'

# ImmortalWrt 平台配置（单行 JSON，不可换行）
immortalwrt_value='{"PLATFORM":"immortalwrt","REPO_URL":"https://github.com/immortalwrt/immortalwrt","REPO_BRANCH":"openwrt-25.12","CONFIG_FILE":"configs/x86_64-immortalwrt.config","CONFIG_NAME":"x86_64","DIY_P1":"diy_part/immortalwrt_diy/diy-part1.sh","DIY_P2":"diy_part/immortalwrt_diy/diy-part2.sh","DIY_P3":"diy_part/immortalwrt_diy/diy-part3.sh","DEPENDENCE":"diy_part/immortalwrt_dependence","SEED_CONFIG":"configs/seed/immortalwrt_seed.config","RELEASE_PREFIX":"ImmortalWrt"}'

# 生成 matrix JSON
matrix_json="["
for platform in "${source_code_platforms[@]}"; do
    value_var="${platform}_value"
    matrix_json+="{\"platform\":\"${platform}\",\"config_name\":\"x86_64\",\"value\":${!value_var}},"
done
matrix_json="${matrix_json%,}]"

# 最终输出压缩为一行
output="{\"include\":$matrix_json}"
echo "matrix=$output" >> $GITHUB_OUTPUT
echo "Generated matrix with ${#source_code_platforms[@]} platforms"
