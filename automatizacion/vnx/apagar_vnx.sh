#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -v --destroy
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -v --destroy