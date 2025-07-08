# AnduinOS in Docker

This repository provides a Docker container to run AnduinOS. Only Linux is supported.

## Prerequisites

- Docker installed on your machine.
- A compatible CPU with virtualization support (Intel VT-x or AMD-V).

## Run

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
