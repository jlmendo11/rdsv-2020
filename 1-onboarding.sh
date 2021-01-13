#!/bin/bash

# Download upm files and unzip
wget http://idefix.dit.upm.es/download/rdsv/nfv/NFV-LAB-2020.tgz
tar -xvf NFV-LAB-2020.tgz

# Move them to Desktop
mv NFV-LAB-2020 ~/Desktop
sudo chmod 777 -R automatizacion
cd automatizacion

mv vnf-ryu  ~/Desktop/NFV-LAB-2020/img
mv vnf-vyos ~/Desktop/NFV-LAB-2020/img

mv vnf-ryu.tar.gz  ~/Desktop/NFV-LAB-2020/pck
mv vnf-vyos.tar.gz ~/Desktop/NFV-LAB-2020/pck

mkdir -p ~/Desktop/NFV-LAB-2020/scripts
mv apagar_completo.sh ~/Desktop/NFV-LAB-2020/scripts
mv levantar_completo.sh ~/Desktop/NFV-LAB-2020/scripts
mv reiniciar_completo.sh ~/Desktop/NFV-LAB-2020/scripts

mkdir -p ~/Desktop/NFV-LAB-2020/scripts/vnx
mv vnx/apagar_vnx.sh ~/Desktop/NFV-LAB-2020/scripts/vnx
mv vnx/levantar_vnx.sh ~/Desktop/NFV-LAB-2020/scripts/vnx
mv vnx/reiniciar_vnx.sh ~/Desktop/NFV-LAB-2020/scripts/vnx

mkdir -p ~/Desktop/NFV-LAB-2020/scripts/vcpe-1
mv vcpe-1/apagar_vcpe-1.sh ~/Desktop/NFV-LAB-2020/scripts/vcpe-1
mv vcpe-1/levantar_vcpe-1.sh ~/Desktop/NFV-LAB-2020/scripts/vcpe-1
mv vcpe-1/reiniciar_vcpe-1.sh ~/Desktop/NFV-LAB-2020/scripts/vcpe-1

mkdir -p ~/Desktop/NFV-LAB-2020/scripts/vcpe-2
mv vcpe-2/apagar_vcpe-2.sh ~/Desktop/NFV-LAB-2020/scripts/vcpe-2
mv vcpe-2/levantar_vcpe-2.sh ~/Desktop/NFV-LAB-2020/scripts/vcpe-2
mv vcpe-2/reiniciar_vcpe-2.sh ~/Desktop/NFV-LAB-2020/scripts/vcpe-2

mv vcpe_start.sh ~/Desktop/NFV-LAB-2020 # TODO: falta

# Onboard to OSM
cd ~/Desktop/NFV-LAB-2020
osm vnfd-create pck/vnf-ryu.tar.gz 
osm vnfd-create pck/vnf-vyos.tar.gz 
osm nsd-create pck/ns-vcpe.tar.gz

docker pull jlmendo11/vnf-ryu
docker image tag jlmendo11/vnf-ryu:latest vnf-ryu:latest

docker pull jlmendo11/vnf-vyos
docker image tag jlmendo11/vnf-vyos:latest vnf-vyos:latest

## Si no tuvieramos acceso a dockerHUB
# cd img/vnf-ryu
# sudo docker build -t vnf-ryu .
# cd ../vnf-vyos
# sudo docker build -t vnf-vyos .