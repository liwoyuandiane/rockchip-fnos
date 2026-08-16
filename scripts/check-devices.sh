#!/bin/bash
# 校验 uboot/ 设备目录完整性，本地和 CI 共用。
# 用法: bash scripts/check-devices.sh
# 任何一项失败则输出错误并返回非 0（CI 即红）。

set -u

cd "$(dirname "$0")/.." || exit 1

fail=0

# 统计函数: 累计错误数
err() { echo "❌ $1"; fail=$((fail + 1)); }
ok() { echo "✅ $1"; }

echo "=========================================="
echo "检查 1/5: buildfnos.sh bash 语法"
echo "=========================================="
if bash -n buildfnos.sh 2>/dev/null; then
  ok "buildfnos.sh 语法正确"
else
  err "buildfnos.sh 语法错误"
fi

echo
echo "=========================================="
echo "检查 2/5: 设备目录数量与命名"
echo "=========================================="
mapfile -t DEVICES < <(find uboot -mindepth 2 -maxdepth 2 -type d 2>/dev/null | sort)
total=${#DEVICES[@]}
if [[ $total -eq 0 ]]; then
  err "未找到任何 uboot/<soc>/<device> 目录"
else
  ok "共 $total 个设备目录"
fi

# 跨 SoC 重名检查（DEVICE 按叶子名匹配，重名会导致歧义）
echo
echo "=========================================="
echo "检查 3/5: 跨 SoC 设备重名"
echo "=========================================="
dups=$(printf '%s\n' "${DEVICES[@]}" | sed 's|^uboot/[^/]*/||' | sort | uniq -d)
if [[ -n "$dups" ]]; then
  for n in $dups; do
    matches=$(printf '%s\n' "${DEVICES[@]}" | grep "/$n$" | sed 's|^uboot/||' | tr '\n' ' ')
    err "设备名 '$n' 在多个 SoC 下存在（DEVICE 匹配会歧义）: $matches"
  done
else
  ok "无重名设备"
fi

echo
echo "=========================================="
echo "检查 4/5: 各设备目录必需文件"
echo "=========================================="
for d in "${DEVICES[@]}"; do
  dev="$d"
  name=$(basename "$d")
  # fnEnv.txt 必需
  if [[ ! -f "$dev/fnEnv.txt" ]]; then err "$name: 缺少 fnEnv.txt"; fi

  # DTB 至少一个
  dtb=$(find "$dev" -maxdepth 1 -name '*.dtb' 2>/dev/null | head -1)
  if [[ -z "$dtb" ]]; then
    err "$name: 缺少 *.dtb"
  else
    dtbname=$(basename "$dtb")
  fi

  # 引导文件: 必须恰好是 A 组或 B 组之一（不允许两组都全/都不全）
  has_a=0; has_b=0
  { [[ -f "$dev/idbloader.img" ]] && [[ -f "$dev/u-boot.itb" ]]; } && has_a=1
  { [[ -f "$dev/idbloader.bin" ]] && [[ -f "$dev/uboot.img" ]] && [[ -f "$dev/trust.bin" ]]; } && has_b=1
  if [[ $((has_a + has_b)) -eq 0 ]]; then
    err "$name: 缺少完整的引导文件组 A(idbloader.img+u-boot.itb) 或 B(idbloader.bin+uboot.img+trust.bin)"
  elif [[ $((has_a + has_b)) -eq 2 ]]; then
    err "$name: 同时存在 A、B 两组引导文件（buildfnos.sh 无法判定，需删除一组）"
  fi

  # extlinux.conf 可选但若存在需可读
  if [[ -f "$dev/extlinux.conf" ]] && [[ ! -r "$dev/extlinux.conf" ]]; then
    err "$name: extlinux.conf 不可读"
  fi
done
if [[ $fail -eq 0 ]]; then ok "全部设备目录必需文件齐全"; fi

echo
echo "=========================================="
echo "检查 5/5: 配置文件内部引用一致性"
echo "=========================================="
for d in "${DEVICES[@]}"; do
  name=$(basename "$d")
  dtbname=$(basename "$(find "$d" -maxdepth 1 -name '*.dtb' 2>/dev/null | head -1)")

  # fnEnv.txt 的 fdtfile=rockchip/<x>.dtb 必须与目录内 dtb 一致
  if [[ -f "$d/fnEnv.txt" ]] && [[ -n "$dtbname" ]]; then
    fdt=$(grep '^fdtfile=' "$d/fnEnv.txt" 2>/dev/null | head -1 | cut -d= -f2 | tr -d '[:space:]')
    if [[ -n "$fdt" ]] && [[ "$fdt" != "rockchip/$dtbname" ]]; then
      err "$name: fnEnv.txt 的 fdtfile='$fdt' 与目录内 dtb '$dtbname' 不一致"
    fi
  fi

  # extlinux.conf 的 fdt /dtb/rockchip/<x>.dtb 必须与目录内 dtb 一致
  if [[ -f "$d/extlinux.conf" ]] && [[ -n "$dtbname" ]]; then
    fdt_ref=$(grep -E '^\s*fdt ' "$d/extlinux.conf" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '[:space:]')
    if [[ -n "$fdt_ref" ]] && [[ "$fdt_ref" != "/dtb/rockchip/$dtbname" ]]; then
      err "$name: extlinux.conf 的 fdt='$fdt_ref' 与目录内 dtb '$dtbname' 不一致"
    fi
  fi
done
if [[ $fail -eq 0 ]]; then ok "所有配置引用一致"; fi

echo
echo "=========================================="
if [[ $fail -gt 0 ]]; then
  echo "结果: $fail 项错误"
  exit 1
else
  echo "结果: ✅ 全部通过 ($total 个设备)"
  exit 0
fi
