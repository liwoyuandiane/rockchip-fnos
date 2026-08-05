# FnOS Custom Image Builder

[English](#english) | [中文](#中文)

---

## English

### Overview

This project automatically builds and releases customized FnNAS images for various ARM-based devices using GitHub Actions. It downloads the base Rockchip FnNAS image and repackages it with device-specific U-Boot configurations.

### Supported Devices

**Tested devices:**
- **OrangePi R1 Plus LTS** ✅
- **NanoPi R2S** ✅ 

**Note:** Images only support eMMC/SD storage.

### Adaptation Principle

For details on how the adaptation works, see: https://github.com/mingxiaoyu/rockchip-fnos/issues/2

### Local Build

You can also build images locally using the `buildfnos.sh` script:

```bash
# Build for a specific device
DEVICE=Orangepi-r1plus-lts ./buildfnos.sh

# Optionally specify rootfs size (default: 6 GiB)
ROOT_SIZE=8 DEVICE=Orangepi-r1plus-lts ./buildfnos.sh

# Optionally force boot group (A or B, default: auto)
BOOT_GROUP=A DEVICE=Orangepi-r1plus-lts ./buildfnos.sh
```

The script requires `sudo` for `dd` and `mount` operations. Output images are saved to the `out/` directory.

### Build via GitHub Actions

Trigger the `Build and Release FnNAS` workflow manually. Available inputs:

- **DEVICE** (optional): build a single device (e.g. `rockpi-4a`), or leave empty to build all `uboot/*/*` devices.
- **ROOT_SIZE** (optional, default `6`): rootfs expansion size in GiB.
- **BASE_IMAGE_URL** (optional): custom fnNAS base image download link. Supports `.img`, `.img.gz`, `.img.xz`. Leave empty to use the default latest Rockchip image from `ophub/fnnas`.
- **BASE_IMAGE_FILENAME** (optional): local filename to save the custom base image with (must end in `.img`, `.img.gz` or `.img.xz`). Useful when the URL has no recognizable filename or a wrong suffix. Only takes effect when `BASE_IMAGE_URL` is set.

Rules for the two base image inputs:

- **URL set, filename empty**: filename is derived from the URL. If no name can be derived, or the suffix is not recognized, the build fails with a clear error message.
- **Filename set, URL empty**: both inputs are ignored, the default `ophub/fnnas` logic is used.
- **Both empty**: default `ophub/fnnas` logic.

Example: build `rockpi-4a` with a custom NanoPC T4 base image:

```
DEVICE: rockpi-4a
BASE_IMAGE_URL: https://example.com/fnos_Mainland-PE_arm_1.2.0302_nanopc-t4_2288.img.gz
```

Example: the URL has no suffix, so name the file manually:

```
DEVICE: rockpi-4a
BASE_IMAGE_URL: https://example.com/download?id=2288
BASE_IMAGE_FILENAME: fnos_nanopc-t4_2288.img.gz
```

### Features

- 🚀 Automated builds using GitHub Actions
- 📦 Device-specific U-Boot configurations
- 💾 Customizable rootfs size
- 🔧 Build single device or all devices at once
- 📤 Automatic release with compressed images

### Directory Structure

```
buildfnos.sh                  # Local image build script
uboot/
├── rk3328/                   # RK3328 chip devices
│   ├── nanopi-r2c/
│   ├── nanopi-r2s/
│   ├── orangepi-r1plus/
│   └── orangepi-r1plus-lts/
├── rk3399/                   # RK3399 chip devices
│   ├── orangepi4-lts/
│   ├── pinebook-pro/
│   ├── rockpi-4a/
│   ├── rockpi-4b/
│   └── ...
├── rk3566/                   # RK3566 chip devices
├── rk3568/                   # RK3568 chip devices
│   ├── nanopi-r5s/
│   └── odroidm1/
├── rk3576/                   # RK3576 chip devices
├── rk3588/                   # RK3588 chip devices
└── rk3588s/                  # RK3588S chip devices

Each device folder contains:
- extlinux.conf               # Boot configuration
- fnEnv.txt                   # Environment variables
- *.dtb                       # Device tree blob
- u-boot.itb                  # U-Boot image (for some devices)
```

### Releases

Built images are automatically uploaded to GitHub Releases with the tag format: `fnos_YYYYMMDD`

Each release contains:
- Compressed `.img.xz` files for each device
- Build information including rootfs size and supported devices

---

## 中文

### 概述

本项目使用 GitHub Actions 自动构建并发布针对各种基于 ARM 的设备的定制 FnNAS 镜像。它下载 Rockchip FnNAS 基础镜像，并使用设备特定的 U-Boot 配置重新打包。

### 支持的设备

**已测试设备：**
- **OrangePi R1 Plus LTS** ✅
- **NanoPi R2S** ✅

**注意：** 镜像仅支持 eMMC/SD 存储。

### 适配原理

关于适配原理的详细信息，请参见：https://github.com/mingxiaoyu/rockchip-fnos/issues/2

### 本地构建

也可以使用 `buildfnos.sh` 脚本在本地构建镜像：

```bash
# 构建指定设备的镜像
DEVICE=Orangepi-r1plus-lts ./buildfnos.sh

# 可选：指定根文件系统大小（默认 6 GiB）
ROOT_SIZE=8 DEVICE=Orangepi-r1plus-lts ./buildfnos.sh

# 可选：指定启动格式组（A 或 B，默认自动检测）
BOOT_GROUP=A DEVICE=Orangepi-r1plus-lts ./buildfnos.sh
```

脚本需要 `sudo` 权限用于 `dd` 和 `mount` 操作。输出镜像保存在 `out/` 目录。

### 通过 GitHub Actions 构建

手动触发 `Build and Release FnNAS` 工作流，可用的输入项：

- **DEVICE**（可选）：构建指定设备（如 `rockpi-4a`），留空则构建所有 `uboot/*/*` 设备。
- **ROOT_SIZE**（可选，默认 `6`）：rootfs 扩容大小（GiB）。
- **BASE_IMAGE_URL**（可选）：自定义 fnNAS 基础包下载链接，支持 `.img`、`.img.gz`、`.img.xz` 后缀；留空则使用 `ophub/fnnas` 默认最新的 Rockchip 镜像。
- **BASE_IMAGE_FILENAME**（可选）：自定义基础包下载后的本地文件名（须以 `.img`、`.img.gz` 或 `.img.xz` 结尾），用于链接本身无文件名或后缀错误时；仅当填写了 `BASE_IMAGE_URL` 时生效。

两个基础包输入项的规则：

- **填了链接、名字留空**：从链接自动取文件名。若取不到名字，或后缀无法识别，构建将失败并给出明确错误原因。
- **填了名字、链接留空**：忽略这两个参数，使用默认 `ophub/fnnas` 逻辑。
- **两者都留空**：使用默认 `ophub/fnnas` 逻辑。

示例：使用自定义的 NanoPC T4 基础包构建 `rockpi-4a`：

```
DEVICE: rockpi-4a
BASE_IMAGE_URL: https://example.com/fnos_Mainland-PE_arm_1.2.0302_nanopc-t4_2288.img.gz
```

示例：链接本身没有后缀，手动指定文件名：

```
DEVICE: rockpi-4a
BASE_IMAGE_URL: https://example.com/download?id=2288
BASE_IMAGE_FILENAME: fnos_nanopc-t4_2288.img.gz
```

### 功能特性

- 🚀 使用 GitHub Actions 自动构建
- 📦 设备特定的 U-Boot 配置
- 💾 可自定义的根文件系统大小
- 🔧 可构建单个设备或所有设备
- 📤 自动发布压缩镜像

### 目录结构

```
buildfnos.sh                  # 本地镜像构建脚本
uboot/
├── rk3328/                   # RK3328 芯片设备
│   ├── nanopi-r2c/
│   ├── nanopi-r2s/
│   ├── orangepi-r1plus/
│   └── orangepi-r1plus-lts/
├── rk3399/                   # RK3399 芯片设备
│   ├── orangepi4-lts/
│   ├── pinebook-pro/
│   ├── rockpi-4a/
│   ├── rockpi-4b/
│   └── ...
├── rk3566/                   # RK3566 芯片设备
├── rk3568/                   # RK3568 芯片设备
│   ├── nanopi-r5s/
│   └── odroidm1/
├── rk3576/                   # RK3576 芯片设备
├── rk3588/                   # RK3588 芯片设备
└── rk3588s/                  # RK3588S 芯片设备

每个设备文件夹包含：
- extlinux.conf               # 启动配置
- fnEnv.txt                   # 环境变量
- *.dtb                       # 设备树文件
- u-boot.itb                  # U-Boot 镜像（部分设备）
```

### 发布版本

构建的镜像会自动上传到 GitHub Releases，标签格式为：`fnos_YYYYMMDD`

每个发布版本包含：
- 每个设备的压缩 `.img.xz` 文件
- 构建信息，包括根文件系统大小和支持的设备


