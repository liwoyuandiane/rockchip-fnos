# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Rockchip FnNAS custom image builder. Repackages a stock Rockchip FnNAS (`ophub/fnnas`) ARM image for specific devices by injecting device U-Boot/boot files and tweaking rootfs size. Builds run in GitHub Actions CI but can run locally. Script comments and CI messages are in Chinese; the README is bilingual (EN/zh).

## Build

There is no test suite or lint step. The single build entrypoint is `buildfnos.sh` (bash, `set -euo pipefail`), run as root — `sudo` is required for `dd`/`mount`/`losetup` of a raw `.img`.

```bash
# Build for one device (outputs to out/<DEVICE>_<YYYYMMDD>.img)
DEVICE=Orangepi-r1plus-lts ./buildfnos.sh

# Override rootfs size in GiB (default 6)
ROOT_SIZE=8 DEVICE=Orangepi-r1plus-lts ./buildfnos.sh

# Force boot-group layout A or B (default: auto-detect)
BOOT_GROUP=A DEVICE=Orangepi-r1plus-lts ./buildfnos.sh
```

Prerequisites: a source image present as `fnnas-arm64/*.img` (CI downloads and xz-decompresses it to `fnnas-arm64/fnnas-arm64.img` first). System deps: `jq`, `xz-utils`, and `util-linux` (for `losetup`).

Env vars for `buildfnos.sh`:
- `DEVICE` (required) — device folder leaf name, case-insensitive; resolved against `uboot/<soc>/<device>/`. Fails if 0 or >1 dirs match.
- `ROOT_SIZE` (optional, default `6`) — GiB root partition target. Applied to the image's resize config: `resize-rootfs.sh` `target_partition_gb=` (official fnOS images) or `etc/fnnas.conf` `rootfs_limit_gib=` (ophub/fnnas images). The old `sed s/64/<n>/g` was a no-op — official `resize-rootfs.sh` has no standalone `64` (real values: `target_disk_size_gb=32`, `target_partition_gb=28`). Non-matching images produce a warning that the setting was not applied.
- `BOOT_GROUP` (`A`/`B`/`auto`, default `auto`) — bootloader layout to inject.

Build flow (order matters): resolve device → copy base image → verify boot-group files → `dd` bootloader into image at fixed block offsets → `losetup` + mount boot partition, replace `fnEnv.txt` (and `extlinux/extlinux.conf` if both sides exist), copy the first `*.dtb` into `dtb/rockchip/` only if missing → mount root partition, apply `ROOT_SIZE` to resize config (`target_partition_gb=` / `rootfs_limit_gib=`) → unmount.

## Boot-group layouts (easy to get wrong)

- **Group A** = `idbloader.img` + `u-boot.itb` — flashed with `dd` at `bs=512` seek offsets 64 and 16384. Used by newer/SPI-boot devices.
- **Group B** = `idbloader.bin` + `uboot.img` + `trust.bin` — flashed at seek offsets 64, 16384, 24576. Older SoCs.
- `rkspi_loader.img`, `u-boot-spl.bin`, `u-boot-tpl.bin`, `u-boot-rockchip*.bin`, `u-boot-metadata*.sh`, `u-boot-config-target-*`, `u-boot-defconfig-target-*` are extra artifacts present in some device dirs (SPI/lvds/dual-target variants) but are **not** flashed onto SD/eMMC — don't add new files to the flash path unless you understand the boot flow.

## Device directories

`uboot/<soc>/<device>/` holds one adapter dir per device, under the SoC dir (`rk3328`, `rk3399`, `rk3399pro`, `rk3566`, `rk3568`, `rk3576`, `rk3588`, `rk3588s`). Some chips have two SoC dirs (`rk3399pro`, `rk3588s`).

Each device dir contains:
- `fnEnv.txt` (required) — boot env (`verbosity`, `console`, `extraargs`, `fdtfile=rockchip/<soc>.dtb`). Always copied over the stock one.
- `extlinux.conf` (optional) — boot config; only replaces the stock `boot/extlinux/extlinux.conf` when that file exists on the image.
- one `*.dtb` (only the first found is copied) — copied to `dtb/rockchip/` on the boot partition only if not already present.
- Group A or B bootloader files (see above).

Adding a device = create a new directory under the correct `rk*` SoC dir. The CI matrix is derived by `find uboot -mindepth 2 -maxdepth 2 -type d`, so directory names must match the upstream kernel/DTB naming.

## CI

- `.github/workflows/validate.yml` — runs on every push (main) and PR: `scripts/check-devices.sh` + `shellcheck`. Checks: device dirs have required files, boot-group A/B are mutually exclusive, `fnEnv.txt` `fdtfile` and `extlinux.conf` `fdt` match the dir's DTB, no duplicate device names across SoCs, both scripts pass `bash -n`. Use it to self-check new device dirs before opening a PR.
- `.github/workflows/build-fnos.yml` — `workflow_dispatch` with inputs `DEVICE` (empty = build all), `ROOT_SIZE`, `BASE_IMAGE_URL`, `BASE_IMAGE_FILENAME`. A `prepare` job builds the device matrix, then a `build` job per device (matrix `continue-on-error: true`, `fail-fast: false` — one failing device doesn't block the release).
  - Base image download: default pulls the latest `ophub/fnnas` release-tag `fnnas_base_image` asset matching `rockchip` + `.img.xz` (highest via `sort -V`); or a custom `BASE_IMAGE_URL`/`BASE_IMAGE_FILENAME`. Custom filename must end in `.img`, `.img.gz`, or `.img.xz`. Filename-set-without-URL is ignored (falls back to default).
  - Publishing: images are xz-compressed and uploaded via `softprops/action-gh-release` to a tag named `fnos_YYYYMMDD`.
  - `DEVICE` input matching uses `awk` over `uboot/` paths with a leaf-name fallback and is case-insensitive — keep device folder names case-consistent with the chip.
- `.github/workflows/upload-original.yml` — manual helper to download a file by URL and drop it into release tag `original_fnos`.
- Base image workflow: URLs come in as one of `.img` / `.img.gz` / `.img.xz` and are decompressed into `fnnas-arm64/fnnas-arm64.img` (gzip/xz) or copied (`cp`) before the build step.

## Gotchas

- Local builds clobber/partition the loop device and need explicit `sudo`; a `cleanup` trap unmounts and detaches the loop device on exit. The mount dirs `/mnt/fnnas_root` and `/mnt/fnnas_boot` are shared — do not run two builds at once, and do not run a local build while CI is running.
- `ROOT_SIZE` application rewrites the whole matched config token (no backref-after-digit ambiguity, no blind `s/64/`). Verified against a real official base image: `target_disk_size_gb=32` / `target_partition_gb=28`, no standalone `64`. If no known format matches, the script warns and continues (setting won't apply silently).
- Images support eMMC/SD storage only.
- Tested devices are OrangePi R1 Plus LTS and NanoPi R2S (see README).