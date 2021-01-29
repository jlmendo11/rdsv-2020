# RDSV 2020-2021
1- Ejecutar el script de /lab/rdsv/rdsv-get... para crear una nueva VirtualBox y abrirla
2- Descargar zip de dropbox
3- Unzip
4- Ejecutar "
chmod u+x ./1-onboarding.sh
./1-onboarding.sh
"
5- Irse a ~/Desktop/VNF-...
6- Ejecutar
scripts/levantar_completo.sh
7- Pruebas

# PRUEBAS
En h11, h12, h21, h22:
dhclient

Y COMPROBAR QUE TIENEN LA 192.168.255.20 Y 21!!! LA QOS VA POR IP!!!

# En h11, h12, h21, h22:
iperf -s -u -i 1 -p 5001

# En VyOS 
# sudo docker exec -it mn.vcpe-1-2-ubuntu-1 bash
# sudo docker exec -it mn.vcpe-2-2-ubuntu-1 bash
iperf -c 192.168.255.20 -p 5001 -u 5 -b 50M
iperf -c 192.168.255.21 -p 5001 -u 5 -b 50M





# SI FUERAS A LEVANTAR POR SEPARADO RECORDAR:
Para destruir el escenario, el orden da un poco igual, pero para crearlo el orden debe ser

1. VNX
2. vcpe-1 y vcpe-2

Porque es dentro de VNX donde llamamos al init.sh, que crea los switches AccessNet y ExtNet
