#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

# El orden aqui importa, primero VNX y luego los vcpe-1 y 2 (por el ./init.sh)
./scripts/vnx/levantar_vnx.sh
sleep 5
./scripts/vcpe-1/levantar_vcpe-1.sh
sleep 5
./scripts/vcpe-2/levantar_vcpe-2.sh
