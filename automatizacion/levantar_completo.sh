#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

./scripts/ovs/levantar_ovs.sh
./scripts/vnx/levantar_vnx.sh
echo 'Esperando a que se estabilice VNX y los ovs'
sleep 20
./scripts/vcpe-1/levantar_vcpe-1.sh
sleep 5
./scripts/vcpe-2/levantar_vcpe-2.sh
