#!/bin/bash
# Update System, Neustart nur durch restart.sh
dpkg --configure -a
apt-get -y update && apt-get dist-upgrade -y && apt-get autoremove -y
# Befehl für Script Update extra.sh nur auf diesem Server
# /script/extra.sh