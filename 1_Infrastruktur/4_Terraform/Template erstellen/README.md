### Vorbereitungen für Template und Terraform Zugang nach Proxmox

## Automatisch über script

### Installiere Pakete auf Proxmox
```
ssh root@proxmox-server
apt update -y && apt install libguestfs-tools -y
```

### Benutze Script
```
mkdir /script
nano /script/create_vm_template.sh
```
-> kopiere Inhalt aus Datei in Script
```
chmod +x /script/create_vm_template.sh
/script/create_vm_template.sh
```
### Ändere Daten im neu erstellten Template unter CloudInit
Benutzer = andre
Kennwort -> setzen
Öffentlicher Schlüssel = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEf0jw3vskLjPylI5/HQBESSVorT5DXEBzyC/nYMQh3X admin@andrejansen.de
IP Konfiguration = DHCP & SLAAC

### Führe NACH dem Klonen vom Template folgendes in der gestarteten VM aus
```
sudo apt-get -y update && sudo apt-get -y upgrade &&  sudo apt-get autoremove -y && sudo mkdir -p /script && sudo apt install sshpass -y && sudo sshpass -p "Dukaatuboot2" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r andre@82.165.252.140:/script/*.sh /script/ && sudo cat /script/update.sh && sudo /script/template.sh
```

## Manuell installieren

1. Proxmox Server

### Quellen

1. [Debian Cloud Images](https://cloud.debian.org/images/cloud/)
1. [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img)
2. [Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)


### Install libguestfs-tools
```
ssh root@proxmox-server
apt update -y && apt install libguestfs-tools -y
```

### Download debian cloud image
debian
```
wget https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-arm64.qcow2
```
ubuntu
```
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img
```

### Install qemu-guest-agent in the cloud image
debian
```
virt-customize -a debian-11-generic-amd64.qcow2 --install qemu-guest-agent
```
ubuntu
```
virt-customize -a jammy-server-cloudimg-amd64-disk-kvm.img --install qemu-guest-agent
```


### Create VM Template
debian
```
qm create 5008 --name "debian-11-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0, tag=50
qm importdisk 5008 debian-11-generic-amd64.qcow2 VM-1TB
```
ubunut
```
qm create 5008 --name "jammy-server-cloudimg-amd64-disk-kvm.img" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0,tag=50
qm importdisk 5008 jammy-server-cloudimg-amd64-disk-kvm.img VM-1TB

```
```
qm set 5008 --scsihw virtio-scsi-pci --scsi0 VM-1TB:vm-5008-disk-0
qm set 5008 --boot c --bootdisk scsi0
qm set 5008 --ide2 VM-1TB:cloudinit
qm set 5008 --serial0 socket --vga serial0
qm set 5008 --agent enabled=1

qm template 5008
```

### Create a role and user for terraform
```
# Create Role
pveum role add terraform_role -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"

# Create User
pveum user add terraform_user@pve --password secure1234

# Map Role to User
pveum aclmod / -user terraform_user@pve -role terraform_role
```

### Export Proxmox API credentials to grant access to terraform client 
```
export PM_USER="terraform_user@pve"
export PM_PASS="secure1234"
```

### Initialize Project and Deploy Infrastructure
```
terraform init
terraform plan
terraform apply 
```