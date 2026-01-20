# FnOS Custom Image Builder

[English](#english) | [中文](#中文)

---

## English

### Overview

This project automatically builds and releases customized FnNAS images for various ARM-based devices using GitHub Actions. It downloads the base Rockchip FnNAS image and repackages it with device-specific U-Boot configurations.

### Supported Devices

**Tested devices:**
- **OrangePi R1 Plus LTS** ✅
- **NanoPi R2S** ✅ (Uses Armbian's DTB, 20th compatibility not confirmed)

**Note:** Images only support eMMC/SD storage.

### Adaptation Principle

For details on how the adaptation works, see: https://github.com/mingxiaoyu/rockchip-fnos/issues/2

**Note:** Local packaging scripts are not provided. All builds are done through GitHub Actions.

### Features

- 🚀 Automated builds using GitHub Actions
- 📦 Device-specific U-Boot configurations
- 💾 Customizable rootfs size
- 🔧 Build single device or all devices at once
- 📤 Automatic release with compressed images

### Directory Structure

```
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
- **NanoPi R2S** ✅（使用 Armbian 的 DTB，20日兼容性未确认）

**注意：** 镜像仅支持 eMMC/SD 存储。

### 适配原理

关于适配原理的详细信息，请参见：https://github.com/mingxiaoyu/rockchip-fnos/issues/2

**注意：** 本项目不提供本地打包脚本，所有构建均通过 GitHub Actions 完成。

### 功能特性

- 🚀 使用 GitHub Actions 自动构建
- 📦 设备特定的 U-Boot 配置
- 💾 可自定义的根文件系统大小
- 🔧 可构建单个设备或所有设备
- 📤 自动发布压缩镜像

### 目录结构

```
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

