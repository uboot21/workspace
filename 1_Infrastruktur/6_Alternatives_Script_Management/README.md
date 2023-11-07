# Hauptseite
[Hauptseite Link](/README.md)

## Was ist ein Alternatives Script Management
Um Server aus der Ferne zu verwalten und zu steuern, bietet sich Ansible an.
Ich mag es aber auch, Server über ein zentrales Script über Crontab zu steuern, je nach Server einzelne Aufgaben speziell für diese Server ausführen zu lassen, das können Aufgaben sein welche auf dem Server per script gestartet werden, aber auch regelmäßige Updates usw. ohne das Ansible dafür auslösen zu müssen. Ein kleines "Setup & Forget System"

Dazu nutze ich 4 verschiedene Scripte, welche zentral auf einem Server liegen. 

### template.sh
Dieser Befehl wird einmalig auf jedem Client aufgerufen. Dieses Script installiert zb Programme welche überall laufen sollen, zb Firewall, Wireguard, Fail2Ban, es kopiert auch alle weiteren Scripte in ein Verzeichnis, setzt die Timezone, richtet den Cron Job ein und richtet das Email für den Root ein damit dieser Emails verschicken kann, setzt einen Link zu meine Meshcentral Server, richtet aber auch den SSH Zugang fest und kopiert den "Master Public Key" in den Server. Es richtet auch den Unattended-Upgrade ein und muss auch manuell "betreut" werden um Antworten auf Rückfragen zu geben. Danach erfolgt alles automatisch mit den Scripts.

### update.sh
Dieses Script wird jede Nacht gestartet und kopiert als erstes die script Dateien (ausser extra.sh) vom "Master Server" herunter. Dann führt es ein update aus (ohne neustart) und startet anschliessend das Script extra.sh für individuelle Arbeiten nur auf diesem Server.

### extra.sh
Dieses Script ist das einzige welches auf dem Server selber gepflegt wird, dort kann man lokale scripts ausführen die zum Server gehören.
z.b. Docker images aufräumen, bilder herunterladen, Dateien kopieren usw.

### restart.sh
Dieses script wird am Wochenende nachts gefahren und führt einen Neustart aus, aber nur wenn ein update vorher einen Neustart vonnöten macht (Kernel Update)