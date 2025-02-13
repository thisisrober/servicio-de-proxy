#!/bin/bash

function mostrarAyuda() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo ">>  --install      Instala el servicio Squid."
    echo ">>  --backup       Realiza una copia de seguridad de la configuración del servicio Squid."
    echo ">>  --info         Muestra información del servicio Squid."
    echo ">>  --help         Muestra esta ayuda y las opciones disponibles."
    echo ""
    echo "Si se ejecuta sin argumentos, se mostrará un menú interactivo."
}

function instalarServicio() {
    echo "Actualizando repositorios..."
    sudo apt update
    echo "Instalando Squid..."
    sudo apt install -y squid
    echo "Instalación completada."
}

function copiaSeg() {
    echo "Realizando copia de seguridad..."
    if [ -f /etc/squid/squid.conf ]; then
        echo "Realizando copia de seguridad del archivo /etc/squid/squid.conf..."
        sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
        echo "# Copia de seguridad realizada el día $(date)" | sudo tee -a /etc/squid/squid.conf > /dev/null
        echo "Copia de seguridad realizada. El archivo original se ha guardado como /etc/squid/squid.conf.bak"
    else
        echo "No se encontró el archivo de configuración de Squid en /etc/squid/squid.conf."
    fi
}

function informacionServicio() {
    echo "==========================================="
    echo "==== INFORMACIÓN DEL SERVICIO DE SQUID ===="
    echo "==========================================="
    if command -v squid &> /dev/null; then
        squid -v 2>&1 | head -n 1
    else
        echo "Squid no está instalado."
    fi
    echo ""
    echo "Estado del servicio Squid:"
    if command -v systemctl &> /dev/null; then
        systemctl status squid --no-pager
    else
        sudo service squid status
    fi
}

function menuPrincipal() {
    while true; do
        clear
        echo "========================================="
        echo "==== MENÚ DE ADMINISTRACIÓN DE SQUID ===="
        echo "========================================="
        echo ">> 1) Instalar servicio"
        echo ">> 2) Realizar copia de seguridad"
        echo ">> 3) Información del servicio"
        echo ">> 4) Ayuda de comandos"
        echo ">> 5) Salir"
        echo ""
        read -p "Seleccione una opción: " option
        case $option in
            1)
                instalarServicio
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            2)
                copiaSeg
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            3)
                informacionServicio
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            4)
                mostrarAyuda
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            5)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "ERROR: la opción no válida. Inténtalo de nuevo."
                sleep 2
                ;;
        esac
    done
}

if [ $# -gt 0 ]; then
    case "$1" in
        --install)
            instalarServicio
            ;;
        --configure)
            copiaSeg
            ;;
        --info)
            informacionServicio
            ;;
        --help)
            mostrarAyuda
            ;;
        *)
            echo "ERROR: la opción '$1' no es válida."
            mostrarAyuda
            exit 1
            ;;
    esac
else
    menuPrincipal
fi
# Esto es un comentario de la opción