# Vorbereitungen
## Watchtower installieren
Mit Watchtower können images automatisch aktualisiert werden
-> Schaut dazu im Ordner Watchtower nach und installiert wie dort beschrieben

In den Einstellungen unter Labels wird dann entschiede ob aktualisiert werden soll oder nicht
```
    labels:
      - 'com.centurylinklabs.watchtower.enable=true'
```
## PUID/PGID herausfinden

