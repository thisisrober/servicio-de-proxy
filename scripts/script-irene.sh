#!/bin/bash

#actualizamos el sistema
sudo apt update && sudo apt upgrade

#verificamos que este todo actualizado e instalamos squid
if [ $? -eq 0 ]; then
    sudo apt install -y squid squidguard
else
    echo "Actualizacion con errores"
    exit 1 #indica un error
fi

#configuramos el archivo de configuracion del squid
SQUID_CONF="/etc/squid/squid.conf"

#configuramos el squid para que funcione como proxy para nuestra red interna
echo "Configurando Squid..."
echo "acl red_local src 172.16.111.0/24" | sudo tee -a $SQUID_CONF
echo "http_access allow red_local" | sudo tee -a $SQUID_CONF
echo "http_port 3128" | sudo tee -a $SQUID_CONF