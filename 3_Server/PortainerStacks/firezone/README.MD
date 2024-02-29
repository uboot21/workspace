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
### Das Docker compose File befindet sich lokal im Usser Folder (/home/$USER oder /root) im Unterordner verstecktem Unterverzeichnid .firezone
Zugang zum Verzeichnis für User:

```
cd /home/$USER/.firezone

```
Zugang zum Verzeichnis für Root:
```
cd /root/.firezone

```
#### hier im Verzeichnis eine Besipiel Datei "docker-compose.yml" mit den Variablen ".env", man findet diese im Verzeichnis .firezone und kann sie selber abändern -> In der Datei findet man auch das Passwort für den login


## Konfiguration Firezone
### Aufruf mit der Hostname DNS und Eingabe der EMail mit dem Passwort aus der ".env" Datei

### Menü Defaults
#### Allowed IPs
```
0.0.0.0/0, ::/0, 192.168.0.0/16
```
Erklärung:
0.0.0.0/0, ::/0   -> Zugang zum Internet
192.168.0.0/16 -> Zugang zum privatem Netzwerk falls man mit dem Heimnetz in ein VPS nernetzt ist, den IP Bereich kann man individuell anpassen, zb. 192.168.178.0/24

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




