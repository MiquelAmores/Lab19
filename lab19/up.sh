#!/bin/bash

## en cas de voler detall de què passa realment (màgia oculta)
## docker-compose --verbose -f docker-compose.yml up -d
docker-compose -f docker-compose.yml up -d
sleep 1



#############################
###### dnserver - primari ###
#############################

#docker exec dnsserver /bin/bash -c "echo 1 | tee /proc/sys/net/ipv4/ip_forward"
docker cp bindserver01/named.conf.local  dnsserver:/etc/bind/named.conf.local
docker cp bindserver01/named.conf.options dnsserver:/etc/bind/named.conf.options
docker cp bindserver01/zones dnsserver:/etc/bind/zones
docker exec dnsserver /bin/bash -c "service bind9 restart;service bind9 status"
sleep 1 

#############################
###### dnserver - secundari #
#############################

#docker exec dnsserver2 /bin/bash -c "echo 1 | tee /proc/sys/net/ipv4/ip_forward"
docker cp bindserver02/named.conf.local  dnsserver2:/etc/bind/named.conf.local
docker cp bindserver02/named.conf.options dnsserver2:/etc/bind/named.conf.options
docker exec dnsserver2 /bin/bash -c "service bind9 restart;service bind9 status"
sleep 1 

docker cp bindserver03/named.conf.local  dnsserver3:/etc/bind/named.conf.local
docker cp bindserver03/named.conf.options dnsserver3:/etc/bind/named.conf.options
docker exec dnsserver3 /bin/bash -c "service bind9 restart;service bind9 status"
sleep 1

#############################
###### router               #
#############################

docker exec router /bin/bash -c "echo 1 | tee /proc/sys/net/ipv4/ip_forward"

#############################
###### dhcpclient      ######
#############################


## com de costum, la manera correcta de passar fitxers entre màquina física i contenidor és fer-ho en dos passes:
## 1) copiar (docker cp) el fitxer a un fitxer INEXISTENT del container
## 2) copiar (des de dins del container: docker exec container-name cp) el fitxer que hem copiat abans a la seua posició

#### com que el servidor de dhcp no actua hem de configurar "manualment" el client de dns.
docker exec dhcpclient01 /bin/bash -c "ip route del default "
docker exec dhcpclient01 /bin/bash -c "ip route add default via 72.28.1.99  dev eth0"
docker cp resolv.conf-lan01 dhcpclient01:/etc/resolv.conf.estatica
docker exec dhcpclient01 cp /etc/resolv.conf{.estatica,}

docker exec dhcpclient02 /bin/bash -c "ip route del default "
docker exec dhcpclient02 /bin/bash -c "ip route add default via 72.28.1.99  dev eth0"
docker cp resolv.conf-lan01 dhcpclient02:/etc/resolv.conf.estatica
docker exec dhcpclient02 cp /etc/resolv.conf{.estatica,}

docker exec dhcpclient03 /bin/bash -c "ip route del default "
docker exec dhcpclient03 /bin/bash -c "ip route add default via 42.28.1.99  dev eth0"
docker cp resolv.conf-lan02 dhcpclient03:/etc/resolv.conf.estatica
docker exec dhcpclient03 cp /etc/resolv.conf{.estatica,}

docker exec dhcpclient04 /bin/bash -c "ip route del default "
docker exec dhcpclient04 /bin/bash -c "ip route add default via 42.28.1.99  dev eth0"
docker cp resolv.conf-lan02 dhcpclient04:/etc/resolv.conf.estatica
docker exec dhcpclient04 cp /etc/resolv.conf{.estatica,}

docker exec dhcpclient05 /bin/bash -c "ip route del default "
docker exec dhcpclient05 /bin/bash -c "ip route add default via 30.28.1.99  dev eth0"
docker cp resolv.conf-lan03 dhcpclient06:/etc/resolv.conf.estatica
docker exec dhcpclient05 cp /etc/resolv.conf{.estatica,}

docker exec dhcpclient06 /bin/bash -c "ip route del default "
docker exec dhcpclient06 /bin/bash -c "ip route add default via 30.28.1.99  dev eth0"
docker cp resolv.conf-lan03 dhcpclient06:/etc/resolv.conf.estatica
docker exec dhcpclient06 cp /etc/resolv.conf{.estatica,}

echo "=================== PINGS ======================"

docker exec dhcpclient01 /bin/sh -c "ping -c 2 client01.jiznardo.org"
docker exec dhcpclient01 /bin/sh -c "ping -c 2 client02.jiznardo.org"
docker exec dhcpclient01 /bin/sh -c "ping -c 2 client01.demo.lab19"
docker exec dhcpclient01 /bin/sh -c "ping -c 2 client02.demo.lab19"
docker exec dhcpclient01 /bin/sh -c "ping -c 2 client01.mamores.org"
docker exec dhcpclient02 /bin/sh -c "ping -c 2 client02.mamores.org"

docker exec dhcpclient03 /bin/sh -c "ping -c 2 client01.jiznardo.org"
docker exec dhcpclient03 /bin/sh -c "ping -c 2 client02.jiznardo.org"
docker exec dhcpclient03 /bin/sh -c "ping -c 2 client01.demo.lab19"
docker exec dhcpclient03 /bin/sh -c "ping -c 2 client02.demo.lab19"
docker exec dhcpclient03 /bin/sh -c "ping -c 2 client01.mamores.org"
docker exec dhcpclient03 /bin/sh -c "ping -c 2 client02.mamores.org"

docker exec dhcpclient05 /bin/sh -c "ping -c 2 client01.jiznardo.org"
docker exec dhcpclient05 /bin/sh -c "ping -c 2 client02.jiznardo.org"
docker exec dhcpclient05 /bin/sh -c "ping -c 2 client01.demo.lab19"
docker exec dhcpclient05 /bin/sh -c "ping -c 2 client02.demo.lab19"
docker exec dhcpclient05 /bin/sh -c "ping -c 2 client01.mamores.org"
docker exec dhcpclient05 /bin/sh -c "ping -c 2 client02.mamores.org"

echo "==================== FI DELS PINGS ====================="
#
#

