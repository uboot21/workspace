#!/bin/bash

## Dieses Script auf github "Workspace" fügt mein Public Key für Ansible Server hinzu
## Danach kann der Rechner meinem Ansible Host hinugefügt werden, das Ansible Script macht dann den Rest
## Installieren mit
## sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get autoremove -y && sudo apt install wget -y && wget https://raw.githubusercontent.com/uboot21/workspace/master/3_Server/Playbooks/ssh_pub.sh && sudo chmod +x ssh_pub.sh && sudo ./ssh_pub.sh && sudo rm ssh_pub.sh
## User andre nur, falls auf Server der root Zugang gesperrt ist

# root
mkdir -p /root/.ssh
sudo touch /root/.ssh/authorized_keys
sudo chmod 700 /root/.ssh && sudo chmod 600 /root/.ssh/*
sudo chown root:root /root/.ssh/
sudo chown root:root /root/.ssh/*
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/9+hLVbx6nv+v8nhXYxlRvMrUnywzrfiOxuKMhxeDV ansible.ionos@andrejansen.de"  | sudo tee -a /root/.ssh/authorized_keys >/dev/null

# user andre
mkdir -p /home/andre/.ssh
sudo touch /home/andre/.ssh/authorized_keys
sudo chmod 700 /home/andre/.ssh && sudo chmod 600 /home/andre/.ssh/*
sudo chown andre:andre /home/andre/.ssh/
sudo chown andre:andre /home/andre/.ssh/*
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/9+hLVbx6nv+v8nhXYxlRvMrUnywzrfiOxuKMhxeDV ansible.ionos@andrejansen.de"  | sudo tee -a /home/andre/.ssh/authorized_keys >/dev/null

sudo service ssh restart