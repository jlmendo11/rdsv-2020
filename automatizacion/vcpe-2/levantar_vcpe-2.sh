#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

osm ns-create --ns_name vcpe-2 --nsd_name vCPE --vim_account emu-vim
echo 'Esperando a la instanciacion de la NS'
sleep 15
./vcpe_start.sh vcpe-2 10.255.0.3 10.255.0.4 192.168.255.1 10.2.3.2 conf/dhcpd-1.conf
