#!/usr/bin/env bash
set -euo pipefail

# --- 配置 ---
IMG=/data/vmdisk/disk.qcow2
SIZE=20G
RAM=4G
CORES=2
ISO=/data/anduinos.iso

# 指向正确的 Secure Boot 代码固件和 vars 模板
OVMF_CODE_SEC=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd
OVMF_VARS_TEMPLATE=/usr/share/OVMF/OVMF_VARS_4M.fd
#OVMF_VARS_TEMPLATE=/usr/share/OVMF/OVMF_VARS_4M.snakeoil.fd

VNC_ADDR=0.0.0.0:0
NOVNC_PORT=8080

# 1. 检查 ISO
[ -r "$ISO" ] || { echo "Error: ISO 不可读 → $ISO" >&2; exit 1; }

# 2. 创建磁盘（如果不存在）
[ -f "$IMG" ] || qemu-img create -f qcow2 "$IMG" "$SIZE"

# 3. 启动 noVNC
websockify --web /usr/share/novnc/ "$NOVNC_PORT" localhost:5900 &

# 4. 复制可写的临时 vars 文件
TMP_VARS=$(mktemp /tmp/UEFI_VARS.XXXXXX)
cp "$OVMF_VARS_TEMPLATE" "$TMP_VARS"
chmod 600 "$TMP_VARS"

# 5. 启动 QEMU
exec qemu-system-x86_64 \
    -machine q35,accel=kvm \
    -m "$RAM" -mem-prealloc \
    -cpu host \
    -smp sockets=1,cores="$CORES",threads=1 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE_SEC" \
    -drive if=pflash,format=raw,file="$TMP_VARS" \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive file="$IMG",if=virtio,format=qcow2,cache=none,discard=unmap \
    -drive file="$ISO",if=ide,media=cdrom,readonly=on \
    -boot order=d \
    -vga virtio \
    -device virtio-keyboard-pci \
    -device virtio-tablet-pci \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -vnc "$VNC_ADDR"
