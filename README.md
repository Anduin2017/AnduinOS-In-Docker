```bash
sudo docker build -t anduinos-vm .

rm -rf vm_data
mkdir -p vm_data
sudo docker run -it --name aa \
  --device /dev/kvm \
  -p 8080:8080 \
  -p 5900:5900 \
  -v ./vm_data:/data/vmdisk \
  anduinos-vm
```
