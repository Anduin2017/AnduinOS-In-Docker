# 使用 Ubuntu 作为基础镜像，它包含了 QEMU, KVM, and OVMF (UEFI)
FROM debian:bookworm

# 设置环境变量，避免安装过程中的交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装 QEMU/KVM, OVMF (UEFI 固件), noVNC 和其他工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    ovmf \
    novnc \
    websockify \
    tini \
    && rm -rf /var/lib/apt/lists/*

# 将你的 ISO 文件复制到容器中
COPY aos.iso /data/anduinos.iso

# 将启动脚本复制到容器中并赋予执行权限
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

# 创建一个用于存储虚拟机硬盘的目录
RUN mkdir /data/vmdisk
VOLUME /data/vmdisk

# 暴露 noVNC 的 Web 端口 (8080) 和 VNC 端口 (5900)
EXPOSE 8080 5900

# 设置容器启动命令
# 使用 tini 作为 init 系统来正确处理信号
ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/entry.sh"]