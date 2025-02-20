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

