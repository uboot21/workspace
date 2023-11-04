[Hauptseite](/README.md)

# Portainer installieren
Portainer:
docker volume create portainer_data
```
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
```
Logge Dich ein mit https://IP:9443
Vergebe ein komplexes Passwort und logge dich ein.

# Weitere Docker zu diesem Portainer hinzufügen

Gehe auf Settings -> Enviroment
-> Docker Standalone -> Start Wizard

-> Agent -> Linux -> Kopiere Docker setup
z.B.:
```
docker run -d \
  -p 9001:9001 \
  --name portainer_agent \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  portainer/agent:2.19.1
```
(Version evtl. ändern nach Vorgabe im Portainer)

Füge die IP und den Port (9001) hinzu und vergebe einen Namen, ein weiterer Docker wird hinzugefügt

# Vermeiden von überschneidendnen IP Subnets
## Falls der Ping zb ausfällt aus dem Netzwerkbereich liegt es meist an das Geiche Subnet für einen Docker Container
```
networks:
  default:
    ipam:
      config:
        - subnet: 172.178.0.0/24  
```
-> Subnet anpassen, jeder Docker eigenes Subnet

# Automatische Updates über Watchtower aktivieren/deaktivieren
```
    labels:
      - 'com.centurylinklabs.watchtower.enable=true'
```
-> mit true oder false ein/ausschalten
-> Siehe Installation Watchtower

# Den Ordnernamen inkl. DockerStack und die Dateinamen da drin nicht ändern -> Docker Stack sind mit Portainer verbunden und der Link geht verloren
