# AGENTS.md

Rockchip FnNAS custom image builder. Repackages a stock Rockchip FnNAS image for specific ARM devices by injecting device U-Boot/boot files and tweaking rootfs size. Script comments and CI messages are in Chinese.

## Core workflow

- `buildfnos.sh` is the single build entrypoint, run as root (`sudo` required for `dd`/`mount`/`losetup` of a raw `.img`).
- It is designed for CI but works locally. Env-driven:
  - `DEVICE` (required) — device folder leaf name, case-insensitive (e.g. `Orangepi-r1plus-lts`). Resolved against `uboot/<soc>/<device>/`.
  - `ROOT_SIZE` (default `6`) — GiB target. Applied to the image's rootfs resize config: `resize-rootfs.sh` `target_partition_gb=` (official images) or `etc/fnnas.conf` `rootfs_limit_gib=` (ophub/fnnas images). Old `sed s/64/<n>/g` did nothing — official `resize-rootfs.sh` has no standalone `64`. If no known format matches, the build warns that the setting was not applied.
  - `BOOT_GROUP` (`A`/`B`/`auto`, default `auto`) — picks the bootloader layout to inject.
- Requires a source `fnnas-arm64/*.img` to be present. CI downloads + xz-decompresses it into `fnnas-arm64/fnnas-arm64.img`.
- Outputs go to `out/<DEVICE>_<YYYYMMDD>.img`. Build depends on `jq`, `xz-utils`; needs `util-linux` for `losetup`.

## Boot-group layouts (easy to get wrong)

- Group A = `idbloader.img` + `u-boot.itb` (flash AT offset 64 and 16384 blocks).
- Group B = `idbloader.bin` + `uboot.img` + `trust.bin` (flash at offsets 64, 16384, 24576).
- Older SoCs use Group B files; newer/SPI-boot devices use Group A (`rkspi_loader.img`, `u-boot-spl.bin`, `u-boot-tpl.bin` are extra artifacts for A but not flashed on SD/eMMC). Don't add new files here unless you understand the boot flow.

## Device directories

`uboot/<soc>/<device>/` holds the adapter files, one dir per device:
- `fnEnv.txt` (required), `extlinux.conf`, `<soc>.dtb` (only the first `*.dtb` is copied), plus the group A/B bootloader files.
- DTB copy target is `dtb/rockchip/`; only copied if not already present.
- Adding a device = new directory under the correct `rk*` SoC dir (matches `DEVICE` and the find-based CI matrix). Two SoC dirs exist for some chips (`rk3399pro`, `rk3588s`).

## CI

- `.github/workflows/build-fnos.yml` builds every `uboot/*/*` dir as a matrix (or a single `DEVICE`), downloads the latest `ophub/fnnas` release asset named like `...rockchip....img.xz` (picks highest `sort -V`), publishes to tag `fnos_YYYYMMDD`. `continue-on-error: true` so per-device failures don't block the release.
- `.github/workflows/validate.yml` runs on every push/PR: `scripts/check-devices.sh` (device dir file completeness, boot-group A/B exclusivity, DTB reference consistency, no duplicate device names) plus `shellcheck` on both shell scripts. Failure blocks merge — use it to self-check new devices.
- `.github/workflows/upload-original.yml` is a manual helper to drop an upstream image into release tag `original_fnos`.
- `DEVICE` matching uses `awk` over `uboot/` paths with leaf-name fallback; keep device folder names case-inert with the chip.

## Gotchas

- Local build will clobber/partition the loop device and needs explicit `sudo`; the `cleanup` trap unmounts on exit. Don't run two builds at once (shared `/mnt/fnnas_root`, `/mnt/fnnas_boot`).
- `ROOT_SIZE` is applied by rewriting the whole matched text (`target_partition_gb=N` / `rootfs_limit_gib="N"`), not a blind `s/64/.../`. No backref-after-digit ambiguity. If nothing matches, the script warns and continues — the setting silently won't apply on unknown image formats.
- README (bilingual EN/zh) is the best reference beyond this file; it lists tested devices (OrangePi R1 Plus LTS, NanoPi R2S) and notes images support eMMC/SD only.