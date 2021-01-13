#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

# Los ovs AccessNet y ExtNet que se inician con ./init.sh NO SE APAGAN
# Si se llama varias veces a ./init.sh no pasa nada 

sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -v --destroy
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -v --destroy