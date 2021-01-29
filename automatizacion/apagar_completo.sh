#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

./scripts/vcpe-1/apagar_vcpe-1.sh
sleep 1
./scripts/vcpe-2/apagar_vcpe-2.sh
sleep 1
./scripts/vnx/apagar_vnx.sh
./scripts/ovs/apagar_ovs.sh