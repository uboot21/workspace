#!/bin/bash
hostname=`hostname`
ip -brief address > /tmp/interfacestatus &&
awk '{ $1=$1; gsub(" ", "|"); printf "|%s|\n", $0 }' /tmp/interfacestatus > /tmp/temp && mv /tmp/temp /tmp/interfacestatus &&
sed -i '1s/^/|Interface|Status |IP-Adresse| \n/' /tmp/interfacestatus &&
sed -i '2s/^/|--|--|--| \n/' /tmp/interfacestatus &&
echo "|||" >> /tmp/interfacestatus &&
pvesh set /nodes/$hostname/config --description "$(cat /tmp/interfacestatus)" &&
rm /tmp/interfacestatus