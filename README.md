[English](README-en.md)

# AUTO-OpenWrt-CI

通过 GitHub Actions 构建 LEDE 和 ImmortalWrt 的 x86_64 固件。

## 下载固件

在 [Releases](https://github.com/cruz0407/AUTO-OpenWrt-CI/releases) 中按标签后缀选择 `-lede` 或 `-immortalwrt`。下载与启动方式匹配的 `combined` 镜像，并用同一 Release 中的 `sha256sums` 核对文件。`combined-efi.img.gz` 适用于 UEFI。

## 运行构建

1. Fork 本仓库并在 **Actions** 中启用工作流。
2. 打开 **Build Multi-Platform OpenWrt**，选择 **Run workflow**。工作流会分别构建两个平台。
3. 到 **Actions** 查看每个平台的日志。编译且产物检查通过后，每个平台会在当前仓库创建自己的 Release。

向 `master` 推送时，修改现用工作流、`configs/`、`diy_part/` 或 `compile_script/` 会自动触发构建。

## 自定义配置

| 平台 | 上游分支 | 固件配置 | 定制脚本 |
| --- | --- | --- | --- |
| LEDE | `coolsnowwolf/lede` 的 `master` | [`configs/x86_64-lede.config`](configs/x86_64-lede.config) | [`diy_part/lede_diy/`](diy_part/lede_diy/) |
| ImmortalWrt | `immortalwrt/immortalwrt` 的 `openwrt-25.12` | [`configs/x86_64-immortalwrt.config`](configs/x86_64-immortalwrt.config) | [`diy_part/immortalwrt_diy/`](diy_part/immortalwrt_diy/) |

平台和上游分支定义在 [`compile_script/platforms.sh`](compile_script/platforms.sh)。CI 在执行 `make defconfig` 前会追加 [`configs/seed/`](configs/seed/) 下对应平台的配置。工作流使用 GHCR 保存构建缓存。

感谢 [P3TERX](https://github.com/P3TERX/Actions-OpenWrt) 和 [KFERMercer](https://github.com/KFERMercer/OpenWrt-CI) 的早期工作。
