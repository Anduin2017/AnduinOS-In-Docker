#!/bin/bash
set -e

# --- 配置 ---
DISK_IMAGE="/data/vmdisk/disk.qcow2"
DISK_SIZE="20G"
RAM_SIZE="4G"
CPU_CORES="2"
ISO_FILE="/data/anduinos.iso"
UEFI_CODE="/usr/share/ovmf/OVMF.fd"
UEFI_VARS_TEMPLATE="/usr/share/OVMF/OVMF_VARS_4M.fd" 
UEFI_VARS="/data/vmdisk/OVMF_VARS.fd"
VNC_PORT="5900"
WEB_PORT="8080"

# --- 1. 准备虚拟机硬盘和 UEFI 环境 ---

# 如果硬盘文件不存在，则创建它
if [ ! -f "$DISK_IMAGE" ]; then
    echo "Creating virtual disk image at $DISK_IMAGE..."
    qemu-img create -f qcow2 "$DISK_IMAGE" "$DISK_SIZE"
fi

# 为了让 UEFI 设置 (包括 Secure Boot 的密钥) 能够被保存，
# 我们需要一个可写的 UEFI 变量文件。我们从模板复制一个。
if [ ! -f "$UEFI_VARS" ]; then
    echo "Copying UEFI variables template..."
    cp "$UEFI_VARS_TEMPLATE" "$UEFI_VARS"
fi


# --- 2. 启动 noVNC Web 服务器 ---

echo "Starting noVNC web server on port $WEB_PORT..."
# 这里的 --web /usr/share/novnc/ 是 noVNC 1.4.0 的路径，旧版本可能是 /usr/share/novnc
websockify --web /usr/share/novnc/ $WEB_PORT localhost:$VNC_PORT &


# --- 3. 启动虚拟机 ---

echo "Starting QEMU VM..."

# 准备 QEMU 启动参数
QEMU_ARGS=(
    -enable-kvm
    -m "$RAM_SIZE"
    -cpu host
    -smp "$CPU_CORES"
    
    # UEFI Secure Boot 设置
    # OVMF_CODE.fd 是只读的固件
    -drive "if=pflash,format=raw,readonly=on,file=$UEFI_CODE"
    # OVMF_VARS.fd 是可写的，用于保存 UEFI 设置
    -drive "if=pflash,format=raw,file=$UEFI_VARS"

    # 硬盘
    -drive "file=$DISK_IMAGE,if=virtio,format=qcow2"

    # 显卡和输入设备
    -vga virtio
    -device virtio-keyboard-pci
    # --- 修改点在这里 ---
    # 使用绝对定位的 virtio-tablet-pci 来解决 VNC 鼠标漂移问题
    -device virtio-tablet-pci

    # 网络 (用户模式网络)
    -netdev user,id=net0
    -device virtio-net-pci,netdev=net0

    # VNC 输出
    -vnc "0.0.0.0:0"
)

# 首次启动时，从 ISO 安装系统
if [ -f "$ISO_FILE" ]; then
    echo "Attaching installation ISO: $ISO_FILE"
    QEMU_ARGS+=(-drive "file=$ISO_FILE,media=cdrom")
    QEMU_ARGS+=(-boot d) # 从 CD-ROM 启动
fi

# 执行 QEMU
exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
