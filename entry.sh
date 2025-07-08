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

# 3. 启动 VM
exec qemu-system-x86_64 \
    # ——— 现代化机型 & 加速 ———
    -machine pc-q35,accel=kvm \
    # ——— 内存 ——（预分配，激进抢占）———
    -m "$RAM" \
    -mem-prealloc \
    # ——— CPU & SMP 拓扑 ——（显式 sockets/cores/threads）———
    -cpu host \
    -smp sockets=1,cores="$CORES",threads=1 \
    # ——— UEFI Secure Boot ——（只读挂载，每次启动都用默认）———
    -drive if=pflash,format=raw,readonly=on,file="$UEFI_CODE" \
    -drive if=pflash,format=raw,readonly=on,file="$UEFI_VARS_TEMPLATE" \
    -global driver=cfi.pflash01,property=secure,value=on \
    # ——— 虚拟硬盘 ——（virtio, 精准 cache/trim 支持）———
    -drive file="$IMG",if=virtio,format=qcow2,cache=none,discard=unmap \
    # ——— 安装 ISO ———
    -cdrom "$ISO" -boot d \
    # ——— 图形与输入 ———
    -vga virtio \
    -device virtio-keyboard-pci \
    -device virtio-tablet-pci \
    # ——— 网络 ———
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    # ——— VNC ———
    -vnc "$VNC_ADDR"
