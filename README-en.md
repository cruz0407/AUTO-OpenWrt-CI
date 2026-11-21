[中文](README.md)

# AUTO-OpenWrt-CI

Build x86_64 firmware for LEDE and ImmortalWrt with GitHub Actions.

## Download firmware

On the [Releases page](https://github.com/cruz0407/AUTO-OpenWrt-CI/releases), choose a tag ending in `-lede` or `-immortalwrt`. Download the `combined` image for your boot mode and verify it against `sha256sums` from the same release. Use a `combined-efi.img.gz` image for UEFI.

## Run a build

1. Fork this repository and enable workflows under **Actions**.
2. Open **Build Multi-Platform OpenWrt** and select **Run workflow**. The workflow builds both platforms as separate jobs.
3. Check the logs for each platform under **Actions**. When a platform builds successfully and passes the firmware check, its job creates a separate release in the current repository.

Pushes to `master` trigger a build when they change the active workflow, `configs/`, `diy_part/`, or `compile_script/`.

## Customize the build

| Platform | Upstream branch | Firmware config | Customization scripts |
| --- | --- | --- | --- |
| LEDE | `master` in `coolsnowwolf/lede` | [`configs/x86_64-lede.config`](configs/x86_64-lede.config) | [`diy_part/lede_diy/`](diy_part/lede_diy/) |
| ImmortalWrt | `openwrt-25.12` in `immortalwrt/immortalwrt` | [`configs/x86_64-immortalwrt.config`](configs/x86_64-immortalwrt.config) | [`diy_part/immortalwrt_diy/`](diy_part/immortalwrt_diy/) |

[`compile_script/platforms.sh`](compile_script/platforms.sh) defines the platforms and upstream branches. CI appends the corresponding config from [`configs/seed/`](configs/seed/) before running `make defconfig`. The workflow stores its build cache in GHCR.

Thanks to [P3TERX](https://github.com/P3TERX/Actions-OpenWrt) and [KFERMercer](https://github.com/KFERMercer/OpenWrt-CI) for their earlier work.
