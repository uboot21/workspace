# Storage Box
## Kostenlose Storage Box
beantragen über Dedicated Server -> Kostenlos für 0€ bestellen
## Aktivieren von Optionen
Samba-Support
externe Erreichbarkeit
## Account Jansen
Aktuelles Produkt	BX10 - inklusive (100 GB)
Server	u123456.your-storagebox.de
Host-System	FSN1-BX123
Benutzername	u123456
Samba/CIFS-Share	//u123456.your-storagebox.de/backup
## Passwort 
## Über Oberfläche kann eines erzeugt werden (wird nur einmal dort abgelegt)
MyRandomPasswort

## Anleitung
   0
```
### Eigene Storagebox einbinden
```
mkdir -p /mnt/pve/sb
```
### Passwort speichern
Die Datei /etc/backup-credentials.txt (mode 0600) sollte dabei zwei Zeilen wie folgt enthalten:
```
nano /etc/backup-credentials.txt
```
### Inhalt
```
username=u123456
password=MyRandomPasswort
```
### Rechte vergeben
```
chmod 0600 /etc/backup-credentials.txt
```
### FSTAB setzen
```
nano /etc/fstab
```
### SMB hinzufügen
```
//u123456.your-storagebox.de/backup /mnt/pve/sb cifs iocharset=utf8,rw,credentials=/etc/backup-credentials.txt,file_mode=0660,dir_mode=0770 0 0
```
### Neustart Mount
```
systemctl daemon-reload && mount -a
```
### Proxmox Verzeichnis hinzufügen
Verzeichnis hinzufügen
ID: Storage-Box
Verzeichnis: /mnt/pve/sb
Inhalt: Iso-Image, Vz-Dump, Container-Template

