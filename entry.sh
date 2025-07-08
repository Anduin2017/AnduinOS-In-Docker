#!/usr/bin/env bash
set -euo pipefail

# --- 配置 ---
IMG=/data/vmdisk/disk.qcow2
SIZE=20G
RAM=4G
CORES=2
ISO=/data/anduinos.iso
UEFI_CODE=/usr/share/ovmf/OVMF.fd
UEFI_VARS_TEMPLATE=/usr/share/OVMF/OVMF_VARS_4M.fd
VNC_ADDR=0.0.0.0:0      # 对应端口 5900
NOVNC_PORT=8080

# 1. 如果硬盘镜像不存在，则创建一个新的 qcow2 格式的虚拟硬盘
[ -f "$IMG" ] || qemu-img create -f qcow2 "$IMG" "$SIZE"

# 2. 启动 noVNC
websockify --web /usr/share/novnc/ "$NOVNC_PORT" localhost:5900 &

# 3. 启动 VM（UEFI vars 模板只读挂载，每次都用默认值）
exec qemu-system-x86_64 \
    -enable-kvm \
    -m "$RAM" \
    -cpu host \
    -smp cores="$CORES" \
    -drive if=pflash,format=raw,readonly=on,file="$UEFI_CODE" \
    -drive if=pflash,format=raw,readonly=on,file="$UEFI_VARS_TEMPLATE" \
    -drive file="$IMG",if=virtio,format=qcow2 \
    -cdrom "$ISO" -boot d \
    -vga virtio \
    -device virtio-keyboard-pci \
    -device virtio-tablet-pci \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -vnc "$VNC_ADDR"
