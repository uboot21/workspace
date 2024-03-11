# Hauptseite
[Hauptseite Link](/README.md)

# Legende
## VPS = Virtual Private Server, zb Ionos VPS XS
https://www.ionos.de/server/vps#tarife
## Wireguard = Sicheres und schnelles VPN Protokoll über UDP -> wesentlich schlanker und  schneller, da in vielen Linux Kernel bereits integriert

# Setup Unifi UDM Pro
## Menü
- Gehe auf -> System -> VPN -> VPN Client -> Create NEW
- Klicke auf Wireguard oben
- Vergebe einen Namen zb Wireguard VPS Server
- Klicke auf "manual"
- Private Key und Public Key werden bereits mit Pünktchen angezeigt, den Public Key kann man mit "Copy" kopieren und für den File unten auf dem VPS einfügen 
- Tunnel IP = 10.10.10.2 und Netmask 32
- Server Address = IP oder FQDN des VPS
- Port = 55120
- Public Server Key = Key der unten auf dem VPS Server erstellt wurde
- Pre-Shared Key = LEER
- Primary DNS server = DNS Server, das kann auch ein lokaler PiHole server sein oder ein  DNS Server auf einer NAS, ansonsten einen öffentlichen nehmen zb 8.8.8.8 oder 1.1.1.1
- Secondary DNS server = Hier kann ein zweiter eingegeben werden, falls der erste nicht erreichbar ist
- Mit "Apply Changes" wird der Client gestartet, falls der Server auf der VPS bereits läuft, wird die Verbindung in wenigen Sekunden aufgebaut und die Verbidung leuchtet grün

# VPS Server Ionos
## Setup VPS Client

### Installation (Ionos VPS XS)
Auf dem VPS wird ein Ubuntu installiert, in den Einstellungen der Firewall unter Netzwerk wird der Port 22 TCP geöffnet und der Wireguard Port (in unserem Beispiel 55120 UDP).
Nach Aufbau der Verbindung kann auch die Ionos Firewall Port 22 geschlossen werden (falls man Services von aussen auf dem VPS später hinzufügen möchte, dann muss der entsprechende Port geöffnet werden).
Bei späterer Einrichtung eines Firezone Servers 
[PortainerStacks Firezone Link](3_Server/PortainerStacks/firezone/README.MD)
sollte man auch Port 80/443 öffnen.

## Installieren von Wireguard (falls nicht vorhanden)
```
sudo apt update -y && sudo apt upgrade -y && sudo apt install software-properties-common wireguard wireguard-tools unzip -y
```
# Einstellen der Port forwarding (falls nicht vorhanden)
```
sudo nano /etc/sysctl.conf
```
## Inhalt unten anhängen

```
# Enable IPv4 packet forwarding
net.ipv4.ip_forward=1

# Enable Proxy ARP (https://en.wikipedia.org/wiki/Proxy_ARP)
net.ipv4.conf.all.proxy_arp=1

# Disable IPv6 packet forwarding
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```
## Neustart und anzeigen ob alles korrekt
```
sudo sysctl -p && sudo sysctl --system
```

## Keys erzeugen
```
(umask 077 && printf "PrivateKey= " | sudo tee /etc/wireguard/privatekey_unifi > /dev/null) && wg genkey | sudo tee -a /etc/wireguard/privatekey_unifi | wg pubkey | sudo tee /etc/wireguard/publickey_unifi && sudo cat /etc/wireguard/privatekey_unifi && sudo touch /etc/wireguard/unifi.conf
```
## Keys anzeigen
```
sudo cat /etc/wireguard/privatekey_unifi && sudo cat /etc/wireguard/publickey_unifi
```

## Wireguard conf erstellen
```
sudo nano /etc/wireguard/unifi.conf
```
## diesen Inhalt einfügen und die Parameter ändern
```
[Interface]
PrivateKey= !!!Private Key der oben erzeugt wurde !!!
ListenPort = 55120
Address = 10.10.10.1/32

# Standard Routing
# Die Netzwerkkarte eth0 muss ausgetauscht werden gegen die Netzwerkkarte des VPS Servers (mit ip addr heraus zu finden, zb  etho, enps192, ens6 etc...)
PostUp     = iptables -t nat -A POSTROUTING -o unifi -j MASQUERADE
PostDown   = iptables -t nat -D POSTROUTING -o unifi -j MASQUERADE
PostUp     = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown   = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = !!!PUBLIC KEY DER UDM PRO (kann in Wireguard Client kopiert werden)!!!
AllowedIPs = 10.10.10.0/24, !!!192.168.0.0/24 -> Hier die IP Netze der UDM Pro rein wodrauf zugegriffen werden darf!!!
```
# Wireguard starten
```
sudo systemctl start wg-quick@unifi && sudo systemctl enable wg-quick@unifi
```
## Stoppen
```
sudo systemctl stop wg-quick@unifi && sudo systemctl disable wg-quick@unifi
```
## Stop & Start nacheinander
```
sudo systemctl stop wg-quick@unifi && sudo systemctl disable wg-quick@unifi && sudo systemctl start wg-quick@unifi && sudo systemctl enable wg-quick@unifi
```