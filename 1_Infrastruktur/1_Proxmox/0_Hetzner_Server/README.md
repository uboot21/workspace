# Hauptseite
[Hauptseite Link](/README.md)

# Hostname Domain erstellen (Bei Bedarf)
hetzner.MeineDomain.de

# Installieren mit Rescue System (Bare Metal Server)
## Festplatten Raid erstellen
### Anzeigen mit  
Raid:
```
cat /proc/mdstat
```
Festplatten:
```
lsblk
```
### Proxmox installieren
```
installimage
```
Auswahl bei Others -> Proxmox
Auskommentieren der HD (NUR 2 NVME)
Ändern des Files, Hostname und Raidlevel (0)
### Ändern der Formatierung auf 
```
PART  /boot ext4 512M
PART  lvm   vg0  all

LV  vg0 root    /            ext4    40G
LV  vg0 swap    swap         swap    6G
LV  vg0 data    /var/lib/vz ext4    906G
```
Speichern des Files mit F10
Neustart des Servers nach Installation
# Passwort setzen Root
```
passwd
```
-> Neues Passwort für Zugang

# Festplatte hinzufügen
```
lsblk
```
```
cfdisk
```
-> GPT -> Voller Speicher -> Write -> yes -> Exit
```
mkfs.ext4 /dev/sda1
```
-> Proxmox -> Hetzner -> Disks -> dev sda1 wählen
Formatieren
-> Verzeichnis hinzufügen -> Erstelle Verzeichnis -> HDD -> ext4
-> Rechenzentrum -> Storage -> Auswählen was dort gespeichert wird
# Update System
Repository ändern, Enterprise entfernen, No Subscription hinzufügen -> Aktualisieren
# Pools  (Beispiele für Sortierung der Server)
1000 Wichtig
2000 Smarthome
3000 Standard
4000 Testen
5000 Template

# Inhalt der interfaces in "1 Interface ORG" sichern und den Inhalt aus "1 interface NEW" in interfaces eintragen
```
nano /etc/network/interfaces
```
## Port weiterleitung Netzwerk einrichten
```
nano /etc/sysctl.conf
```
## -> Unten anhängen
```
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```
```
sysctl -p && sysctl --system
```
# Nachträglich Zugang zum Proxmox (Port 8006) ausschalten
## Die Zeile mit "#" auskommentieren 
```
#       post-up iptables -t nat -A PREROUTING -i vmbr0 -p tcp -m multiport ! --dport 22,8006 -j DNAT --to-destination 10.0.0.2
        post-up iptables -t nat -A PREROUTING -i vmbr0 -p tcp -m multiport ! --dport 22 -j DNAT --to-destination 10.0.0.2
```
## Anwenden mit:
```
ifup vmbr0
```

-> Es dauert dann nach einem Neustart des Servers, da erst die PFSense neu gestartet werden muss
-> Für notfall zugriff -> Login per ssh, ändern der Zeile, neustart und login über https://IPDesServers:8006

# warnmeldung ausschalten subscription warnung
## script erstellen
```
nano remove-subscription-warning.sh
```
## Inhalt einfügen
```
#!/bin/bash
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
```
```
chmod +x remove-subscription-warning.sh
```
## script starten
```
/root/remove-subscription-warning.sh
```
## Crontab einrichten
```
crontab -e
```
## Beispiele für feste Routen einstellen und zusätzlich regelmäßig die subscription Warnung ausschalten
```
@reboot ip route add 192.168.0.100/32 via 10.1.1.2 dev vmbr2 #Route zu einem zb Synology Server
@reboot ip route add 192.168.0.210/32 via 10.1.1.2 dev vmbr2 #Route zu einem zb Proxmox Backup Server
0 14 * * *  /root/remove-subscription-warning.sh
```

# E-Mail-Einstellungen anpassen

Proxmox kommt bereits mit einer fertigen Postfix-Installation. Postfix ist ein vollwertiger Mail Transfer Agent – oder einfach gesagt ein Mail-Server. Allerdings wollen wir gar keinen Mail-Server an einem privaten Internet-Anschluss betreiben, da sich hier meistens die IP-Adresse alle 24 Stunden ändert und evtl. gar keine Mail-Domain vorhanden/gewünscht ist. Zusätzlich wäre der Aufwand für die Konfiguration recht hoch.

Daher soll die Proxmox-Postfix-Instanz nur als Relay-Server dienen, d.h. ihr nutzt einfach eine E-Mail-Adresse eines beliebigen Mail-Providers. In meinem Fall nutze ich All-Inkl.com (Affiliate Link), daher sind die folgenden Schritte darauf ausgelegt. Wenn ihr einen anderen Mail-Anbieter nutzt, müsst ihr natürlich die Daten entsprechende anpassen.

## Wir editieren hier die Postfix-Konfiguration:

```
nano /etc/postfix/main.cf 
```
## Hier findet ihr folgende Zeile

```
mydestination = $myhostname, localhost.$mydomain, localhost
relayhost = 
Diese Zeile wird auskommentiert, darunter wird ein Relay-Host (euer SMTP-Server des Mail-Anbieters) definiert. Die folgenden Zeilen dienen der Authentifizierung. Das ganze sieht dann wie folgt aus (der Rest der Konfiguration wird nicht geändert):
```
## Inhalt ändern hinzufügen
```
#mydestination = $myhostname, localhost.$mydomain, localhost
#relayhost = 
relayhost = [MAILSERVER]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
```
## Anschließend werden die Zugangsdaten des Mail-Accounts hinterlegt:

```
nano /etc/postfix/sasl_passwd 
```
## Der Inhalt sieht folgendermaßen aus (E-Mail/Benutzername und Passwort müssen hier natürlich wieder angepasst werden):

```
[MAILSERVER]:587    Benutuzername:Passwort
```
## Der erste Block muss dabei dem Relayhost entsprechen, der in der Postfix-Konfiguration angegeben wurde.
## Nun passen wir noch die Zugriffsrechte auf diese Datei an und konvertieren diese dann mittels postmap in ein Binärformat.

```
chmod 600 /etc/postfix/sasl_passwd && postmap /etc/postfix/sasl_passwd
```
## Damit die Authentifizierung funktioniert, muss noch ein zusätzliches Paket installiert werden. Abschließend starten wir Postfix noch neu:

```
apt install libsasl2-modules
service postfix restart
```
## Testen kann man den Mail-Versand nun einfach auf der Shell des Proxmox-Servers (meine@email.de muss natürlich durch eine echte Mail-Adresse ersetzt werden):

```
echo "Test" | mail -s "Test Betreff" admin@andrejansen.de
```
Die Test-Mail sollte nach wenigen Augenblicken zugestellt werden.
Unter Umständen kann es notwendig sein, die E-Mail-Adresse des Absenders noch explizit in den Optionen des Rechenzentrums anzugeben (Option Absender E-Mail-Adresse, diese steht standardmäßig auf root@$hostname).

# Einstellen der Standard-Sprache für die Weboberfläche
Die Standard-Sprache der Weboberfläche ist Englisch. Beim Login kann die Sprache zwar auf Deutsch gewechselt werden, dies ist aber etwas nervig, da die Seite beim Setzen einer neuen Sprache komplett neu lädt und ein evtl. eingegebener Benutzername nebst Passwort dann erst einmal wieder weg ist.
## Die Standard-Sprache kann in folgender Konfiguration geändert werden:
```
nano /etc/pve/datacenter.cfg
```
Mit folgender Zeile am Ende der Datei erscheint die Weboberfläche per Default dann in Deutsch:
```
language: de
```

# Absicherung von Proxmox mittels fail2ban
Nutzt mal einen zweiten Faktor zur Authentifizierung, ist man schon recht gut gegen unerwünschte Login-Versuche abgesichert. Wenn Proxmox über das Internet erreichbar sein soll, empfiehlt sich zusätzlich noch die Absicherung mit fail2ban: Werden ungültige Login-Versuche über die Weboberfläche registriert, wird die entsprechende IP-Adresse nach einer bestimmten Anzahl an Versuchen für einen konfigurierbaren Zeitraum gesperrt.
Dazu verbinden wir und mittels SSH auf den Proxmox-Server und installieren fail2ban:
```
apt update && apt install fail2ban
```
## Nun wird ein Filter für Proxmox angelegt:
```
nano /etc/fail2ban/filter.d/proxmox.conf
```
Die Datei hat dabei folgenden Inhalt:
```
[Definition]
failregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*
ignoreregex =
```
Dieser Filter wird nun noch per „Jail“ bekannt gemacht:
```
nano /etc/fail2ban/jail.local
```
## Hier werden zunächst die Parameter definiert, nach denen gebannt werden soll: Nach 3 ungültigen Logins wird die entsprechende IP für 1800 Sekunden ausgesperrt.

```
[DEFAULT]
maxretry=3
bantime=1800

[proxmox]
enabled=true
port=https,http,8006
filter=proxmox
logpath=/var/log/daemon.log
```
## Zum Schluss muss fail2ban noch einmal neu gestartet werden:

```
service fail2ban restart && systemctl status fail2ban
```
Nun sollte das ganze noch getestet werden: Lasst dazu die SSH-Session offen und loggt euch drei Mal mit falschen Anmeldedaten bei Proxmox in der Weboberfläche ein. Dass hier ein Login-Versuch vorgenommen wird, kann man an der kurzen Wartezeit nach dem Klick auf Anmelden sehen. Beim vierten Versuch wird diese Meldung sofort angezeigt. Dass hier tatsächlich ein Ban stattgefunden hat, kann man auf der Kommandozeile des Servers überprüfen:
```
fail2ban-client status proxmox
```
Hier sollte nun eine ähnliche Ausgabe erscheinen wie diese hier:
```
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 3
|  `- File list:    /var/log/daemon.log
`- Actions
   |- Currently banned: 1
   |- Total banned: 1
   `- Banned IP list:   192.168.201.18
```
Hier sieht man, dass die IP 192.168.201.18 soeben gebannt wurde.

## Um den Ban aufzuheben, ist nun folgender Befehl nützlich:
```
fail2ban-client set proxmox unbanip 192.168.201.18
```
Hier wird dann einfach „1“ zurück geliefert und die entsprechende IP ist wieder entbannt.
Somit sollte die Proxmox-Instanz nun gut abgesichert sein.

## Zweiten Faktor zur Anmeldung nutzen

Wie bei vielen anderen Diensten kann bei Proxmox zur Anmeldung an der Web-Oberfläche ein zweiter Faktor (z.B. TOTP oder WebAuthn) konfiguriert werden, damit der Login besser abgesichert ist. Wenn die Proxmox-Instanz nur im lokalen Netz erreichbar ist, ist dieser Schritt eher optional. Auf jeden Fall empfehlenswert ist ein zweiter Faktor, wenn die Weboberfläche auch über das Internet erreichbar sein soll.

Dazu klickt man bei aktiviertem Rechenzentrum einfach Zweite Faktoren unter Rechte an. Mit dem Button Hinzufügen können unterschiedliche Arten eines zweiten Faktors konfiguriert werden. Ich habe mich hier für TOTP entschieden, damit kommt der zweite Faktor von einer beliebigen TOTP-App (z.B. andOTP für Android). Nach einem Scan des QR-Codes mit der App und der Bestätigung mit einem generierten zweiten Faktor kann die Konfiguration hier abgeschlossen werden.
https://decatec.de/home-server/proxmox-ve-installation-und-grundkonfiguration/

https://decatec.de/wp-content/uploads/2021/11/Proxmox_TOTP.png
Proxmox: TOTP als zweiten Faktor konfigurieren
Zukünftig braucht man dann zur Anmeldung an die Web-Oberfläche neben dem Passwort auch immer diesen zweiten Faktor.

# Webmin
## Webmin installieren (nur falls gewünscht)
```
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
sh setup-repos.sh
```
```
apt-get install webmin
```
## Webmin Einrichten

### DOMAIN ändern webmin.MeineDomain.de = webmin
#### Beispiel: webmin.MeineDomain.de

```
nano /etc/webmin/miniserv.conf
```
Eingeben:
```
trust_real_ip=1
logouttimes=
```
Ändere Webmin Config
```
nano /etc/webmin/config
```
Eingeben:
```
referers=webmin.MeineDomain.de
relative_redir=0
```
### Neustart webmin
```
systemctl restart webmin
```

## Webmin deinstallieren
```
sudo sh /etc/webmin/uninstall.sh
```
Reste loswerden
```
sudo rm /var/webmin -R
sudo rm /usr/local/webmin -R
```

# VM wieder starten falls beendet "Beispiel 1100"
über SSH einloggen
```
qm start 1100
```

# Swap ausschalten (bei viel RAM)
swapoff -a 

# Neuer Kernel installieren 6.2
apt update
apt install pve-kernel-6.2
reboot

# ZFS Disk Ram verkleinern
https://blog.andreas-schreiner.de/2021/08/16/proxmox-ve-installation-und-grundkonfiguration/
ZFS File System Konfiguration / ZFS ARC Tuning

Wie in einem anderen Beitrag beschrieben, habe ich 2 Server, ein Produktivsystem und ein Testsystem; in beiden Systemen sind 2 Data Disks, die ich per ZFS mit RAID 1 zu einem logischen Volume zusammenschließe. Für die Nutzung von ZFS ist jedoch einiges zu beachten.

ARC (Adaptive Replacement Cache) ist eine Funktion von ZFS, die Daten, auf die am häufigsten zugegriffen wird, im RAM speichert und so extrem schnelle Lesevorgänge für diese Ressourcen ermöglicht. Das ist an sich eine sinnvolle Funktion, aber die standardmäßige maximale Größe für ARC beträgt 50% des gesamten System-RAMs. Auf einem File Server macht eine Einstellung von 50% oder sogar noch mehr durchaus Sinn, aber Proxmox VE ist ja nun mal kein File Server sondern ein Hypervisor. Da RAM einerseits teuer ist und andererseits der RAM für ein System begrenzt ist, drehe ich die Einstellung in meiner Installation daher herunter.

Es gibt viele Empfehlungen, wie viel RAM für ARC verwendet werden soll. Häufig trifft man dabei auf den Wert 1 GB pro TB ZFS Speicher, mindestens jedoch 8 GB. Meine Server haben jeweils eine 500 GB ZFS RAID 1 Disk, d.h. rein nach diesem TB Wert würde 1 GB für ARC reichen. Zudem verfügen meine Server über 32 GB, bzw. 64 GB RAM. Daher bleibe ich erst mal unter der Empfehlung und limitiere ARC erstmal auf 2 GB, bzw. 4 GB. Sollte das zu Performance Problemen führen, kann auf 8 GB erhöht werden. 1 GB RAM bzw. 2 GB RAM konfiguriere ich als Minimalwert.

Diese Werte müssen in Bytes angegeben werden und können wie folgt berechnet werden:
GB * 1024 = MB -> MB * 1024 = KB -> KB * 1024 = Bytes
Daraus ergeben sich folgende Werte:
8GB = 8589934592 Bytes
4GB = 4294967296 Bytes
2GB = 2147483648 Bytes
1GB = 1073741824 Bytes

Um ARC zu konfigurieren, ist mit dem folgenden Befehl die zfs.conf Datei zu editieren (wird neu angelegt, falls sie noch nicht existiert):

nano /etc/modprobe.d/zfs.conf
Dort trage ich folgende Werte ein:

Produktivserver

options zfs zfs_arc_min=2147483648
options zfs zfs_arc_max=4294967296
Testserver

options zfs zfs_arc_min=1073741824
options zfs zfs_arc_max=2147483648
Da ich UEFI Systeme verwende, muss die Kernel Liste aktualisiert werden, damit das aktualisierte RAM File System verwendet wird (bei BIOS nicht notwendig):

pve-efiboot-tool refresh
Für das eigentliche PVS System verwende ich eine separate EXT4 formatierte LVM Disk. Dadurch ist die Konfiguration von ZFS für meine System fertig. Wer jedoch auch das System auf einer ZFS Disk installiert, muss auch das initiale RAM Dateisystem anpassen, damit die Änderung wirksam wird vor dem Mounten des ZFS Volumes.

update-initramfs -u
Damit obige Änderungen wirksam werden, muss das System abschließend nun noch gebootet werden.

# -
