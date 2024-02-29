# Firezone ist ein Wireguard Zugang für einen Linux Server

## Installation Docker (folge der Anleitung)
[Docker installieren](/2_Software/2_Docker/README.md)

## Installation Docker Compose
[Docker-Compose installieren](/2_Software/3_Docker-Compose/README.md)

## Ausführen Installationscript Firezone
### Installation
```
bash <(curl -fsSL https://github.com/firezone/firezone/raw/legacy/scripts/install.sh)
```
#### Das Script fragt einige Punkte ab:

```
Enter the administrator email you'd like to use for logging into this Firezone instance: =>  Mailadresse zum Login
Enter the desired installation directory (/home/User/.firezone): => Enter eingeben
Enter the external URL that will be used to access this instance. (https://firezone): FQDN, das kann bei einer VPS auch der dort angegeben DNS-Hostname sein
Could we email you to ask for product feedback? Firezone depends heavily on input from users like you to steer development. (Y/n): => N
Firezone collects crash and performance logs to help us improve the product. Would you like to disable this? (N/y):  => Y
Press <ENTER> to install or Ctrl-C to abort.  => Enter eingeben
```
### Das Docker compose File befindet sich lokal im Usser Folder (/home/$USER oder /root) iin einem verstecktem Unterordner -> .firezone
Zugang zum Verzeichnis für User:

```
cd /home/$USER/.firezone

```
Zugang zum Verzeichnis für Root User:
```
cd /root/.firezone

```

#### hier im Github Verzeichnis ist eine Besipiel Datei "docker-compose.yml" mit den ".env" Datei für die Variablen, man findet diese im Verzeichnis .firezone und kann sie selber abändern -> In der Datei findet man auch das Passwort für den login, dies braucht nach der Erstellung aber nicht 


## Konfiguration Firezone
#### Aufruf der Webseite mit der Hostname-DNS und Login mit der EMail und mit dem Passwort aus der ".env" Datei bzw. die einem am Ende der Installationangezeigt wird.

### Menüs
### Menü Defaults
#### Allowed IPs
```
0.0.0.0/0, ::/0, 192.168.0.0/16
```
Erklärung:
0.0.0.0/0, ::/0   -> Zugang zum Internet
192.168.0.0/16 -> Zugang zum privatem Netzwerk falls man mit dem Heimnetz in ein VPS nernetzt ist, den IP Bereich kann man individuell anpassen, zb. 192.168.178.0/24
Hier wird konfiguriert was das System an sich erreichen soll, weiter unten wird beschrieben was der einzelne User mit welchem Gerät erreichen darf,

#### DNS Servers
```
1.1.1.1, 1.0.0.1
```
Erklärung:
Beliebige DNS Server hier eintragen, falls man sein Heimnetz mit diesem Server verbunden hat, kann man auch eigene DNS Server eintragen wie z.b. PiHole

#### Endpoint
```
firezone.server.de:51820
```
Erklärung:
Hier kommt der Hostname DNS mit Doppelpunkt und dem UDP Port für den Wireguard Zugang rein

#### Persistent Keepalive
```
25
```
Erklärung:
Anzahl Sekunden in dem der Server prüft ob er online ist

#### MTU
```
1280
```
Erklärung:
Braucht nicht verändert werden

### Menü Account
Hier kann der Benutzername und das Passwort geändert werden

### Menü Customization
Hier kann man das Logo ändern

### Menü Security
Require Authentication For VPN Sessions     =   Never
Local Auth                                  =   Ein
Allow unprivileged device management        =   Ein
Allow unprivileged device configuration     =   Ein
Auto disable VPN                            =   Aus

### Menü Rules
Allowlist
Denylist
-> Hier kann man individuell für verschiedene Benutzer Geräte oder Ziele freigeben oder sperren, wenn man nichts extra sperren möchte, kann man die Zugänge wie oben unter Allowed Ip´s beschrieben einstellen.

### Menü Devices
Hier sieht man später die einzelnen Devices, ob sie verbunden sind, was sie übertragen haben usw.

### Menü Users
Klicke auf den angelegten Benutzer und dann auf "Add Device"

#### Name
Eindeutiger Name, zb: "Handy-Privat-Iphone-12"

#### Description
Beschreibung, z.b. Privat Handy der Frau

#### Use Default Allowed IPs
Man kann hier Yes wählen oder den Zugang einschränken, zb nur "0.0.0.0/0, ::/0" für Zugang Internet, aber kein Netzwerk

#### Use Default DNS Servers
Hier kann man einen anderen DNS Server eingeben, Standard. wäre "Yes"

#### Use Default Endpoint
"Yes"

#### Use Default MTU
"Yes"

#### Use Default Persistent Keepalive
"Yes"

#### Use Default Endpoint
"Yes"

#### Tunnel IPv4 Address
Leer lassen

#### Tunnel IPv6 Address
Leer lassen

#### Nach klick auf "Add Device" Wird einem ein QR Code angezeigt, sowie die Wireguard Zugangskonfiguration für das zu verbindende Gerät
Es wird eine Warnmeldung angezeigt:
```
NOTE: This configuration WILL NOT be viewable again. Please ensure you've downloaded the configuration file or copied it somewhere safe before closing this window.
```
Mit Klick auf Download Configuration kann man das Setup File herunter laden

-> Das Gerät kann man mit Klick auf das Gerät und "Delete" wieder löschen
-> Man muss nicht für jeden Nutzer auch einen eigenen User einrichten, dies ist nur notwendig wenn man unterschiedliche Rechte vergeben möchte

### Softwae für die Clients
Die entsprechenden Clients kann man sich hier herunter laden 
```
https://www.wireguard.com/install/
```

