# Seed 模板使用说明

## 用途

Seed 模板包含所有设备的**公共基础包配置**，在每个设备 `.config` 加载后追加，然后由 `make defconfig` 解析依赖关系。

## 工作流

```bash
# 1. 选择架构/设备
make menuconfig

# 2. 追加 seed 配置（覆盖通用包选项）
cat ../configs/seed/lede_seed.config >> .config

# 3. 解析依赖，生成最终 .config
make defconfig

# 4. 保存为新设备配置
cp -f .config ../configs/xxx.config
```

## 设计原则

- **Seed 中放什么**：所有设备都需要的通用包（luci、curl、wget、openssh 等）
- **Seed 中不放什么**：架构相关配置（CONFIG_TARGET_x86）、硬件驱动（kmod-*）、分区大小
- **make defconfig 会丢弃无效符号**：如果某个包在新版本中被移除，不会报错

## 当前 Seed 内容

| 类别 | 包含的包 |
|------|---------|
| 基础 LuCI | luci |
| 常用工具 | curl, wget, openssl-util, coreutils, tar, xz |
| SSH | openssh-server, openssh-sftp-server |
| OTA 更新 | luci-app-ghfu |
