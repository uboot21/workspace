# Key erstellen Start System (Eigener Linux Rechner)

```
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_MeinKey -C "admin@MeineEmail.de"
eval "$(ssh-agent -s)"
ssh-add
ssh-add -k ~/.ssh/id_MeinKey
```

# SSH-Key Kopieren auf Zielsystem
Damit das Script auch ohne Benutzereingaben läuft, muss der Public Key vom Hauptsystem auf das Zielsystem kopiert werden. Damit ist dann auch eine Passwortlose-Anmeldung möglich. Also zunächst ein Keypärchen erstellen und dann den Public Key kopieren.

## Auf dem Hauptsystem ausführen, nicht dem Backup Ziel ##
```
ssh-keygen -t rsa
ssh-copy-id root@<IP-ZIELSYSTEM>
```
Wenn du den Passwortlosen-Login testen möchtest gebe folgendes in die CLI ein
```
ssh root@<IP-ZIELSYSTEM>
```

## SSH KEY Fest hinzufügen
Config Datei erstellen / konfigurieren
```
nano ~/.ssh/config
```
Inhalt Einfügen
```
IdentityFile ~/.ssh/id_MeinKey
```
Rechte vergeben
```
chmod 600 ~/.ssh/config
```