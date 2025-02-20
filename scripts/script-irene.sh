#!/bin/bash

echo "Seleccione una opción:"
echo "1) Instalar Squid"
echo "2) Configurar páginas bloqueadas"
echo "3) Instalar y configurar SquidGuard"
echo "4) Salir"
read -p "Opción: " opcion

SQUID_CONF="/etc/squid/squid.conf"
BLOCKLIST="/etc/squid/blocklist.txt"
SQUIDGUARD_CONF="/etc/squidguard/squidGuard.conf"

case $opcion in
    1)
        echo "Instalando Squid..."
        sudo apt update && sudo apt upgrade -y
        sudo apt install squid -y
        echo "Configurando Squid..."
        echo "acl red_local src 172.16.111.0/24" | sudo tee -a $SQUID_CONF
        echo "http_access deny all" | sudo tee -a $SQUID_CONF
        echo "http_access allow localnet" | sudo tee -a $SQUID_CONF
        echo "http_access allow SSL_ports" | sudo tee -a $SQUID_CONF
        echo "http_port 3128" | sudo tee -a $SQUID_CONF
        sudo systemctl restart squid.service
        squid -k parse
        echo "Squid instalado y configurado."
        ;;
    2)
        echo "Configurando bloqueo de páginas..."
        echo -e "youtube.com" | sudo tee $BLOCKLIST
        echo -e "aula.salesianosatocha.es" | sudo tee -a $BLOCKLIST
        echo "acl sitios_prohibidos dstdomain \"/etc/squid/blocklist.txt\"" | sudo tee -a $SQUID_CONF
        echo "http_access deny sitios_prohibidos" | sudo tee -a $SQUID_CONF
        sudo systemctl restart squid
        echo "Bloqueo de páginas configurado."
        ;;
    3)
        echo "Instalando SquidGuard..."
        sudo apt update && sudo apt install squidguard -y
        echo "Configurando SquidGuard..."
        echo "url_rewrite_program /usr/bin/squidguard" | sudo tee -a $SQUID_CONF
        echo "url_rewrite_children 5" | sudo tee -a $SQUID_CONF
        echo "dest blacklist {" | sudo tee $SQUIDGUARD_CONF
        echo "   domainlist /etc/squid/blocklist.txt" | sudo tee -a $SQUIDGUARD_CONF
        echo "}" | sudo tee -a $SQUIDGUARD_CONF
        echo "acl {" | sudo tee -a $SQUIDGUARD_CONF
        echo "   default {" | sudo tee -a $SQUIDGUARD_CONF
        echo "      pass !blacklist all" | sudo tee -a $SQUIDGUARD_CONF
        echo "   }" | sudo tee -a $SQUIDGUARD_CONF
        echo "}" | sudo tee -a $SQUIDGUARD_CONF
        sudo squidGuard -C all
        sudo systemctl restart squid
        echo "SquidGuard instalado y configurado."
        ;;
    4)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción no válida."
        ;;
esac
