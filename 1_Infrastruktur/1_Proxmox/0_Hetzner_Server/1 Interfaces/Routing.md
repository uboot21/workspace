# Hetzner Proxmox Server
## Static Route Hetzner Proxmox Server zu anderen Servern (Nicht aus dem virtuellem PFSense Netzwerk heraus, sondern Zugriff vom Proxmox Server selber)
### -> Login via Root
´´´
ip route add 192.168.0.100/32 via 10.1.1.2 dev vmbr2
ip route add 192.168.0.210/32 via 10.1.1.2 dev vmbr2
´´´
