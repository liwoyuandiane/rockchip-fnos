# FnOS Custom Image Builder

[English](#english) | [中文](#中文)

---

## English

### Overview

This project automatically builds and releases customized FnNAS images for various ARM-based devices using GitHub Actions. It downloads the base Rockchip FnNAS image and repackages it with device-specific U-Boot configurations.

### Supported Devices

- **NanoPi R2C**
- **NanoPi R2S**
- **OrangePi R1 Plus**
- **OrangePi R1 Plus LTS**

### Features

- 🚀 Automated builds using GitHub Actions
- 📦 Device-specific U-Boot configurations
- 💾 Customizable rootfs size
- 🔧 Build single device or all devices at once
- 📤 Automatic release with compressed images

### Usage

#### Trigger a Build

1. Go to the **Actions** tab in your GitHub repository
2. Select **Build and Release FnNAS** workflow
3. Click **Run workflow**
4. Configure options:
   - **DEVICE**: Leave empty to build all devices, or specify one device name (e.g., `Nanopi-r2c`)
   - **ROOT_SIZE**: Root filesystem size in GiB (default: 6)

#### Build All Devices

Leave the `DEVICE` field empty when triggering the workflow.

#### Build Specific Device

Enter the device folder name exactly as it appears in the `uboot/` directory:
- `Nanopi-r2c`
- `Nanopi-r2s`
- `Orangepi-r1plus`
- `Orangepi-r1plus-lts`

### Directory Structure

```
fnos/
├── uboot/                    # Device-specific U-Boot configurations
│   ├── Nanopi-r2c/
│   │   └── fnEnv.txt
│   ├── Nanopi-r2s/
│   │   └── fnEnv.txt
│   ├── Orangepi-r1plus/
│   │   └── fnEnv.txt
│   └── Orangepi-r1plus-lts/
│       └── fnEnv.txt
└── workflows/
    └── build-fnos.yml        # GitHub Actions workflow
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

- **NanoPi R2C**
- **NanoPi R2S**
- **OrangePi R1 Plus**
- **OrangePi R1 Plus LTS**

### 功能特性

- 🚀 使用 GitHub Actions 自动构建
- 📦 设备特定的 U-Boot 配置
- 💾 可自定义的根文件系统大小
- 🔧 可构建单个设备或所有设备
- 📤 自动发布压缩镜像

### 使用方法

#### 触发构建

1. 进入 GitHub 仓库的 **Actions** 标签页
2. 选择 **Build and Release FnNAS** 工作流
3. 点击 **Run workflow**
4. 配置选项：
   - **DEVICE**：留空构建所有设备，或指定单个设备名称（例如：`Nanopi-r2c`）
   - **ROOT_SIZE**：根文件系统大小，单位 GiB（默认：6）

#### 构建所有设备

触发工作流时将 `DEVICE` 字段留空即可。

#### 构建特定设备

输入 `uboot/` 目录中显示的确切设备文件夹名称：
- `Nanopi-r2c`
- `Nanopi-r2s`
- `Orangepi-r1plus`
- `Orangepi-r1plus-lts`

### 目录结构

```
fnos/
├── uboot/                    # 设备特定的 U-Boot 配置
│   ├── Nanopi-r2c/
│   │   └── fnEnv.txt
│   ├── Nanopi-r2s/
│   │   └── fnEnv.txt
│   ├── Orangepi-r1plus/
│   │   └── fnEnv.txt
│   └── Orangepi-r1plus-lts/
│       └── fnEnv.txt
└── workflows/
    └── build-fnos.yml        # GitHub Actions 工作流
```

### 发布版本

构建的镜像会自动上传到 GitHub Releases，标签格式为：`fnos_YYYYMMDD`

每个发布版本包含：
- 每个设备的压缩 `.img.xz` 文件
- 构建信息，包括根文件系统大小和支持的设备

