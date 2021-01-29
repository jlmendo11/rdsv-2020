#!/bin/bash
cd ~/Desktop/NFV-LAB-2020

sudo ovs-vsctl --if-exists del-br AccessNet
sudo ovs-vsctl --if-exists del-br ExtNet