#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

# Levantamos primero AccessNet y ExtNet
./init.sh


sleep 3
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -t
sleep 1
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -t