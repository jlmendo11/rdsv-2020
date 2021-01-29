#!/bin/bash

USAGE="
Usage:
    
vcpe_start <vcpe_name> <vnf_tunnel_ip> <home_tunnel_ip> <vcpe_private_ip> <vcpe_public_ip> <dhcpd_conf_file>
    being:
        <vcpe_name>: the name of the network service instance in OSM 
        <vnf_tunnel_ip>: the ip address for the vnf side of the tunnel
        <home_tunnel_ip>: the ip address for the home side of the tunnel
        <vcpe_private_ip>: the private ip address for the vcpe
        <vcpe_public_ip>: the public ip address for the vcpe (10.2.2.0/24)
        <dhcpd_conf_file>: the dhcp file for the vcpe to give private addresses to the home network
"

if [[ $# -ne 6 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

VNF1="mn.dc1_$1-1-ubuntu-1"
VNF2="mn.dc1_$1-2-ubuntu-1"

VNFTUNIP="$2"
HOMETUNIP="$3"
VCPEPRIVIP="$4"
VCPEPUBIP="$5"
DHCPDCONF="$6"

ETH11=`sudo docker exec -it $VNF1 ifconfig | grep eth1 | awk '{print $1}'`
ETH21=`sudo docker exec -it $VNF2 ifconfig | grep eth1 | awk '{print $1}'`
IP11=`sudo docker exec -it $VNF1 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`
IP21=`sudo docker exec -it $VNF2 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`

##################### VNFs Settings #####################
## 0. Iniciar el Servicio OpenVirtualSwitch en cada VNF:
echo "--"
echo "--OVS Starting..."
sudo docker exec -it $VNF1 /usr/share/openvswitch/scripts/ovs-ctl start
# Ya no hace falta levarntar el OVS de VNF2 porque no lo vamos a usar

echo "--"
echo "--Connecting vCPE service with AccessNet and ExtNet..."

sudo ovs-docker add-port AccessNet veth0 $VNF1
# Tiene que llamarse ethX para que lo detecte VyOs
sleep 5
sudo ovs-docker add-port ExtNet eth2 $VNF2
sleep 8

echo "--"
echo "--Setting VNF..."
echo "--"
echo "--Bridge Creating..."

## 1. En VNF:vclass agregar un bridge y asociar interfaces.
sudo docker exec -it $VNF1 ovs-vsctl add-br br0 -- set bridge br0 other-config:hwaddr=\"00:00:00:00:12:34\"
sleep 1
sudo docker exec -it $VNF1 ifconfig veth0 $VNFTUNIP/24
sleep 1
# sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan1 -- set interface vxlan1 type=vxlan options:remote_ip=$HOMETUNIP
## sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan2 -- set interface vxlan2 type=vxlan options:remote_ip=$IP21
sudo docker exec -it $VNF1 ip link add vxlan1 type vxlan id 0 remote $HOMETUNIP dstport 4789 dev veth0 # tunel 
sleep 1
sudo docker exec -it $VNF1 ip link add vxlan2 type vxlan id 1 remote $IP21 dstport 4789 dev $ETH11     # vyos
sleep 1
sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan1
sleep 1
sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan2
sleep 1
sudo docker exec -it $VNF1 ifconfig vxlan1 up
sleep 1
sudo docker exec -it $VNF1 ifconfig vxlan2 up
sleep 8

## 2. En VNF:vcpe agregar un bridge y asociar interfaces.
# sudo docker exec -it $VNF2 ovs-vsctl add-br br1
# sudo docker exec -it $VNF2 /sbin/ifconfig br1 $VCPEPRIVIP/24
## el comando ovs-vsctl add-port vxlan tiene como puerto por defecto el 4789
# sudo docker exec -it $VNF2 ovs-vsctl add-port br1 vxlan1 -- set interface vxlan1 type=vxlan options:remote_ip=$IP11
# sudo docker exec -it $VNF2 ifconfig br1 mtu 1400

## 3. En VNF:vcpe asignar dirección IP a interfaz de salida.
# sudo docker exec -it $VNF2 /sbin/ifconfig veth0 $VCPEPUBIP/24
# sudo docker exec -it $VNF2 ip route del 0.0.0.0/0 via 172.17.0.1
# sudo docker exec -it $VNF2 ip route add 0.0.0.0/0 via 10.2.3.254

## 4. Iniciar Servidor DHCP 
# echo "--"
# echo "--DHCP Server Starting..."
# if [ -f "$DHCPDCONF" ]; then
#     echo "--Using $DHCPDCONF for DHCP"
#     docker cp $DHCPDCONF $VNF2:/etc/dhcp/dhcpd.conf
# else
#     echo "--$DHCPCONF not found for DHCP, the container will use the default"
# fi
# sudo docker exec -it $VNF2 service isc-dhcp-server restart
# sleep 10

## 5. En VNF:vcpe activar NAT para dar salida a Internet 
# docker cp /usr/bin/vnx_config_nat  $VNF2:/usr/bin
# sudo docker exec -it $VNF2 /usr/bin/vnx_config_nat br1 veth0

# VNF:vcpe 
sudo docker exec -it $VNF2 bash -c "
source /opt/vyatta/etc/functions/script-template

# Quita de eth0 la ruta 172.17.0.1 la que va a internet DESDE LINUX (config secuestrada por kernel)
sudo ip route del 0.0.0.0/0 via 172.17.0.1

configure

# Conectividad entre VyOS y ExtNet veth0
# Ya creamos la interfaz en la linea 48: sudo ovs-docker add-port ExtNet veth0 $VNF2
# Asignamos IP a $VCPEPUBIP/24
set interfaces ethernet eth2 address $VCPEPUBIP/24

# Crear tunel
set interfaces vxlan vxlan2 address $VCPEPRIVIP/24
set interfaces vxlan vxlan2 remote $IP11
set interfaces vxlan vxlan2 mtu 1400
set interfaces vxlan vxlan2 vni 1
# VyOS por defecto pone el puerto 8472 en este script se estaba usando el 4789
set interfaces vxlan vxlan2 port 4789

# Configurar de eth2 la ruta 10.2.3.254 (al server de internet)
set protocols static route 0.0.0.0/0 next-hop 10.2.3.254 distance 1
commit
save

# DHCP
set service dhcp-server shared-network-name 'RESIDENCIAL' authoritative
set service dhcp-server shared-network-name 'RESIDENCIAL' subnet '192.168.255.0/24' range 0 start '192.168.255.20'
set service dhcp-server shared-network-name 'RESIDENCIAL' subnet '192.168.255.0/24' range 0 stop '192.168.255.30'
set service dhcp-server shared-network-name 'RESIDENCIAL' subnet '192.168.255.0/24' default-router '192.168.255.1'
set service dhcp-server shared-network-name 'RESIDENCIAL' subnet '192.168.255.0/24' lease 86400                   
set service dhcp-server shared-network-name 'RESIDENCIAL' subnet '192.168.255.0/24' dns-server '8.8.8.8'   
set service dhcp-server shared-network-name 'RESIDENCIAL' subnet '192.168.255.0/24' domain-name 'example.org'
commit
save

# NAT
set nat source rule 50 outbound-interface eth2
set nat source rule 50 source address 192.168.255.0/24
set nat source rule 50 translation address masquerade
commit
save

exit
"

sleep 5

# Comandos RYU
sudo docker exec -d $VNF1 bash -c "ryu-manager ryu.app.rest_qos ryu.app.rest_conf_switch ./qos_simple_switch_13.py"

sleep 10

sudo docker exec -it $VNF1 bash -c "
# Como el dpid es un stringify de la MAC address del bridge OVS, tenemos que asegurarnos de que en la creacion
# lo cambiamos a a 00:00:00:00:12:34. Si no estuviera cambiado:
## ovs-vsctl set bridge br0 other-config:hwaddr=\"00:00:00:00:12:34\"

# Unimos al br0 como qos switch
ovs-vsctl set bridge br0 protocols=OpenFlow13
sleep 1
ovs-vsctl set-manager ptcp:6632
sleep 1
ovs-vsctl set-controller br0 tcp:127.0.0.1:6633
sleep 10

# Le decimos a la API rest que identifique nuestro switch
# curl -X PUT -d 'tcp:127.0.0.1:6632' http://127.0.0.1:8080/v1.0/conf/switches/0000000000001234/ovsdb_addr
curl -X PUT -d '\"tcp:127.0.0.1:6632\"' http://127.0.0.1:8080/v1.0/conf/switches/0000000000001234/ovsdb_addr
sleep 8

# Ponemos una cola nueva en la interfaz 'vxlan1' (izquierda)
# curl -X POST -d '{'port_name': 'vxlan1', 'type': 'linux-htb', 'max_rate': '12000000', 'queues': [{'min_rate': '8000000'}, {'max_rate': '4000000'}]}' http://127.0.0.1:8080/qos/queue/0000000000001234
curl -X POST -d '{\"port_name\": \"vxlan1\", \"type\": \"linux-htb\", \"max_rate\": \"12000000\", \"queues\": [{\"min_rate\": \"8000000\"}, {\"max_rate\": \"4000000\"}]}' http://127.0.0.1:8080/qos/queue/0000000000001234
sleep 7
echo ''

# Configurar los flujos que matchean con estas colas
# 192.168.255.20 --> h11
# 192.168.255.21 --> h12 (siempre que dhclient se haga en orden)
#curl -X POST -d '{'match': {'nw_dst': '192.168.255.20'}, 'actions':{'queue': '0'}}' http://127.0.0.1:8080/qos/rules/0000000000001234
#curl -X POST -d '{'match': {'nw_dst': '192.168.255.21'}, 'actions':{'queue': '1'}}' http://127.0.0.1:8080/qos/rules/0000000000001234
curl -X POST -d '{\"match\": {\"nw_dst\": \"192.168.255.20\"}, \"actions\":{\"queue\": \"0\"}}' http://127.0.0.1:8080/qos/rules/0000000000001234
sleep 5
echo ''
curl -X POST -d '{\"match\": {\"nw_dst\": \"192.168.255.21\"}, \"actions\":{\"queue\": \"1\"}}' http://127.0.0.1:8080/qos/rules/0000000000001234
sleep 3
echo ''
"