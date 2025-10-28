FROM hub.aiursoft.com/aiursoft/internalimages/ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      qemu-system-x86 \
      qemu-utils \
      ovmf \
      novnc \
      websockify \
      tini \
      curl \
      jq \
    && rm -rf /var/lib/apt/lists/*

ARG VERSIONS_JSON_URL="https://www.anduinos.com/versions.json"
RUN set -eux; \
    mkdir -p /data/vmdisk; \
    vers=$(curl -s ${VERSIONS_JSON_URL} \
           | jq -r '[.[] | select(.isVisible)] | last | .version'); \
    latest=$(curl -s ${VERSIONS_JSON_URL} \
             | jq -r '[.[] | select(.isVisible)] | last | .latest'); \
    echo "Downloading AnduinOS ${vers} → ${latest}…"; \
    curl -fsSL "https://download.anduinos.com/${vers}/${latest}/AnduinOS-${latest}-en_US.iso" \
         -o /data/anduinos.iso

COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

VOLUME /data/vmdisk
EXPOSE 8080 5900

ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/entry.sh"]
