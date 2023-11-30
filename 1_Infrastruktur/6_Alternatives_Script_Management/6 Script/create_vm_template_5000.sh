#!/bin/bash

# Parameter hier
# ID des Templates
Prox_ID=5000
# Name des Laufwerkes wo installiert wird
Local_VM=VM-1TB
# Name der Bridge mit LAN Zugang
LAN=vmbr0
# Name des VLAN (0=keines)
TAG=50
# Pfad zu authorized_keys mit den erlaubten Zugängen zur VM
FILE1=/root/.ssh/authorized_keys
# Pfad im Internet zum Cloud Init Image 
Pfad2=https://cloud-images.ubuntu.com/jammy/current/
# Name des Ubuntu Imagecim Pfad
FILE2=jammy-server-cloudimg-amd64.img
# Benutzernamen im System
User=andre


# Code
echo "ceate_vm_"$Prox_ID".sh started..."

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# example if you need to inject a key into the image
if test -f "$FILE1"; then
    echo "found "$FILE1" ssh key file..."
  else
    echo "could not find "$FILE1" file.  Please create this file. exiting."
    exit
fi

# Downloaf des Image
if test -f /root/"$FILE2"; then
     echo "found img file skipping download..."
else
     echo "downloading img file..."
     cd /root/
     wget "$Pfad2""$FILE2"
fi


virt-customize -a "$FILE2" --install qemu-guest-agent
virt-customize -a "$FILE2" --run-command "useradd -m -s /bin/bash "$User""
virt-customize -a "$FILE2" --root-password password:"$User"
virt-customize -a "$FILE2" --ssh-inject "$User":file:/root/.ssh/authorized_keys
qm create "$Prox_ID" --name "ubuntu-2204-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge="$LAN",tag="$TAG"
qm importdisk "$Prox_ID" "$FILE2" "$Local_VM"
qm set "$Prox_ID" --scsihw virtio-scsi-pci --scsi0 "$Local_VM":vm-"$Prox_ID"-disk-0
qm set "$Prox_ID" --scsi0 "$Local_VM":0,import-from=/root/"$FILE2"
qm set "$Prox_ID" --ide2 "$Local_VM":cloudinit
qm set "$Prox_ID" --boot order=scsi0
qm set "$Prox_ID" --serial0 socket --vga serial0
qm set "$Prox_ID" --agent 1
qm template "$Prox_ID"

echo "cerate_vm_"$Prox_ID" completed."