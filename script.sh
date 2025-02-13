#!/bin/bash

function mostrarAyuda() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo ">>  --install    Instala el servicio Squid."
    echo ">>  --help       Muestra esta ayuda y las opciones disponibles."
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

function menuPrincipal() {
    while true; do
        clear
        echo "========================================="
        echo "==== MENÚ DE ADMINISTRACIÓN DE SQUID ===="
        echo "========================================="
        echo ">> 1) Instalar servicio"
        echo ">> 4) Ayuda de comandos"
        echo ">> 5) Salir"
        echo ""
        read -p "Seleccione una opción: " option
        case $option in
            1)
                install_service
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            2)
                echo "Funcionalidad de configuración pendiente..."
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            3)
                echo "Información del servicio pendiente..."
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            4)
                show_help
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            5)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "Opción no válida. Intente de nuevo."
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
        --help)
            mostrarAyuda
            ;;
        *)
            echo "ERROR: la opción $1 no es válida."
            mostrarAyuda
            exit 1
            ;;
    esac
else
    main_menu
fi
