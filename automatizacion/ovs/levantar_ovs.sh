#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

# Levantamos AccessNet y ExtNet
sudo ovs-vsctl add-br AccessNet
sudo ovs-vsctl add-br ExtNet
