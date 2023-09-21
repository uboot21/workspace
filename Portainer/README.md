# Vorbereitungen
## Watchtower installieren
Mit Watchtower können images automatisch aktualisiert werden
-> Schaut dazu im Ordner Watchtower nach und installiert wie dort beschrieben

In den Einstellungen unter Labels wird dann entschiede ob aktualisiert werden soll oder nicht
```
    labels:
      - 'com.centurylinklabs.watchtower.enable=true'

## Netzwerke anlegen
Docker legt automatisch random Netzwerke an.
Da diese Netzwerke auch in einem eigenem großem Netzwerk vorhanden sein können, gebe ich pro Container Stack eine eigene feste IP Range mit
Man kann dieses auch anders lösen, aber mit dieser Lösung bin ich bisher gut ausgekommen und die Container haben keinen direkten Zugriff auf die anderen Container.
