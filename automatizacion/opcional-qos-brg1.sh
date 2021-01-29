sudo docker exec -it mn.dc1_vcpe-1-1-ubuntu-1 bash -c "
# TENEMOS QUE HABER SEGUIDO LA 2-instrucciones-parte-opcional.txt

# Le decimos a la API rest que identifique nuestro switch
curl -X PUT -d '\"tcp:10.255.0.2:6632\"' http://127.0.0.1:8080/v1.0/conf/switches/0000000000006666/ovsdb_addr
sleep 7

# Ponemos una cola nueva en la interfaz 'vxlan1' (izquierda)
curl -X POST -d '{\"port_name\": \"vxlan1\", \"type\": \"linux-htb\", \"max_rate\": \"6000000\", \"queues\": [{\"min_rate\": \"2000000\"}, {\"max_rate\": \"2000000\"}]}' http://127.0.0.1:8080/qos/queue/0000000000006666
sleep 8
echo ''

# Configurar los flujos que matchean con estas colas
curl -X POST -d '{\"match\": {\"nw_src\": \"192.168.255.20\"}, \"actions\":{\"queue\": \"0\"}}' http://127.0.0.1:8080/qos/rules/0000000000006666
sleep 5
echo ''
curl -X POST -d '{\"match\": {\"nw_src\": \"192.168.255.21\"}, \"actions\":{\"queue\": \"1\"}}' http://127.0.0.1:8080/qos/rules/0000000000006666
sleep 3
echo ''
"