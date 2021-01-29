#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

osm ns-create --ns_name vcpe-1 --nsd_name vCPE --vim_account emu-vim
echo 'Esperando a la instanciacion de la NS'
sleep 30
./vcpe_start.sh vcpe-1 10.255.0.1 10.255.0.2 192.168.255.1 10.2.3.1 conf/dhcpd-1.conf
