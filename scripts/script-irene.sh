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
echo "Configurando Squid"
echo "acl red_local src 172.16.111.0/24" | sudo tee -a $SQUID_CONF
echo "http_access allow red_local" | sudo tee -a $SQUID_CONF
echo "http_port 3128" | sudo tee -a $SQUID_CONF

#reiniciamos el archivo y comprobamos que el squid funcione correctamente.
sudo systemctl restart squid.service
squid -k parse

#BLOQUEO DE PAGINAS
BLOCKLIST="/etc/squid/blocklist.txt"
echo "Bloqueo de paginas no deseadas"
echo -e "youtube.com" | sudo tee $BLOCKLIST

echo "acl sitios_prohibidos dstdomain "/etc/squid/blocklist.txt"" | sudo tee -a $SQUID_CONF
echo "http_access deny sitios_prohibidos" | sudo tee -a $SQUID_CONF

#reiniciamos el servicio nuevamente
sudo systemctl restart squid

#AMPLIACION-SQUIDGUARD
SQUIDGUARD_CONF="/etc/squidguard/squidGuard.conf"

echo "Configurando SquidGuard"
echo "dest blacklist {" | sudo tee $SQUIDGUARD_CONF
echo "   domainlist /etc/squid/blocklist.txt" | sudo tee -a $SQUIDGUARD_CONF
echo "}" | sudo tee -a $SQUIDGUARD_CONF

echo "acl {" | sudo tee -a $SQUIDGUARD_CONF
echo "   default {" | sudo tee -a $SQUIDGUARD_CONF
echo "      pass !blacklist all" | sudo tee -a $SQUIDGUARD_CONF
echo "   }" | sudo tee -a $SQUIDGUARD_CONF
echo "}" | sudo tee -a $SQUIDGUARD_CONF

#aplicamos la configuracion y reiniciamos el servicio
sudo squidGuard -C all
sudo systemctl restart squid