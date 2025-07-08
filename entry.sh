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

# 3. 复制一份可写的临时 vars 文件，启动后自动删除
TMP_VARS=$(mktemp /tmp/UEFI_VARS.XXXXXX)
cp "$UEFI_VARS_TEMPLATE" "$TMP_VARS"
chmod 600 "$TMP_VARS"

# 4. 启动 VM
exec qemu-system-x86_64 \
    -machine ubuntu-q35,accel=kvm \
    -m "$RAM" -mem-prealloc \
    -cpu host \
    -smp sockets=1,cores="$CORES",threads=1 \
    # 只读加载 OVMF_CODE
    -drive if=pflash,format=raw,readonly=on,file="$UEFI_CODE" \
    # 可写但临时的 vars 分区
    -drive if=pflash,format=raw,file="$TMP_VARS" \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive file="$IMG",if=virtio,format=qcow2,cache=none,discard=unmap \
    -cdrom "$ISO" -boot d \
    -vga virtio \
    -device virtio-keyboard-pci \
    -device virtio-tablet-pci \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -vnc "$VNC_ADDR"
