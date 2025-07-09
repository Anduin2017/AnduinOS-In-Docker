# AnduinOS in Docker

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://gitlab.aiursoft.cn/anduin/AnduinOS-In-Docker/-/blob/master/LICENSE)
[![Pipeline stat](https://gitlab.aiursoft.cn/anduin/AnduinOS-In-Docker/badges/master/pipeline.svg)](https://gitlab.aiursoft.cn/anduin/AnduinOS-In-Docker/-/pipelines)
[![ManHours](https://manhours.aiursoft.cn/r/gitlab.aiursoft.cn/anduin/anduinos-in-docker.svg)](https://gitlab.aiursoft.cn/anduin/AnduinOS-In-Docker/-/commits/master?ref_type=heads)
[![Docker](https://img.shields.io/docker/pulls/anduin2019/anduinos-in-docker.svg)](https://hub.docker.com/r/anduin2019/anduinos-in-docker)

This repository provides a Docker container to run AnduinOS. Only Linux is supported.

## Prerequisites

- Must be running on a Linux host.
- Docker installed on your machine.
- A compatible CPU with virtualization support (Intel VT-x or AMD-V).

## Run

To run AnduinOS in Docker, you can use the pre-built image available on Docker Hub:

```bash
docker pull anduin2019/anduinos-home
mkdir -p vm_data
docker run -it \
  --device /dev/kvm \
  -p 8080:8080 \
  -p 5900:5900 \
  -v ./vm_data:/data/vmdisk \
  anduin2019/anduinos-home
```

## Build from source

To run AnduinOS in Docker, follow these steps:

```bash
docker build -t anduinos-vm .
mkdir -p vm_data
docker run -it \
  --device /dev/kvm \
  -p 8080:8080 \
  -p 5900:5900 \
  -v ./vm_data:/data/vmdisk \
  anduinos-vm
```

And then open your browser and visit [http://localhost:8080/vnc_auto.html](http://localhost:8080/vnc_auto.html) to access AnduinOS.

<!-- ```bash
sudo docker build -t anduinos-vm .

rm -rf vm_data
mkdir -p vm_data
sudo docker rm -f aa || true
sudo docker run -it --name aa \
  --device /dev/kvm \
  -p 8080:8080 \
  -p 5900:5900 \
  -v ./vm_data:/data/vmdisk \
  anduinos-vm
``` -->
