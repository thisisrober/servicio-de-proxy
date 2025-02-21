#!/bin/bash

function mostrarAyuda() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo ">>  --install      Instala el servicio Squid."
    echo ">>  --backup       Realiza una copia de seguridad de la configuración del servicio Squid."
    echo ">>  --info         Muestra información del servicio Squid."
    echo ">>  --logs         Muestra los logs del servicio Squid."
    echo ">>  --start        Inicia el servicio Squid."
    echo ">>  --stop         Detiene el servicio Squid."
    echo ">>  --restart      Reinicia el servicio Squid."
    echo ">>  --network       Muestra los datos de red de tu equipo."
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

function datosRed() {
    echo "======================================="
    echo "======= DATOS DE RED DEL EQUIPO ======="
    echo "======================================="
    ip a
}

# Se podría mejorar la función de arriba de datosRed indicando una lista más clara, donde se vea la IP, la máscara de red, la puerta de enlace, etc.

function iniciarServicio() {
    echo "Iniciando el servicio Squid..."
    sudo systemctl start squid
    echo "El servicio de Squid se ha iniciado."
}

function detenerServicio() {
    echo "Deteniendo el servicio Squid..."
    sudo systemctl stop squid
    echo "El servicio de Squid se ha detenido."
}

function reiniciarServicio() {
    echo "Reiniciando el servicio Squid..."
    sudo systemctl restart squid
    echo "El servicio de Squid ha sido reiniciado."
}

function mostrarLogs() {
    echo "===================================="
    echo "==== CONSULTA DE LOGS DE SQUID ===="
    echo "===================================="
    echo ">> Elija el tipo de log a ver:"
    echo "1) Accesos"
    echo "2) Errores"
    echo "3) Personalizado por fecha"
    echo ""
    read -p "Seleccione una opción: " option
    case $option in
        1)
            sudo cat /var/log/squid/access.log
            ;;
        2)
            sudo cat /var/log/squid/cache.log
            ;;
        3)
            read -p "Introduzca la fecha (formato: YYYY-MM-DD): " fecha
            sudo grep "$fecha" /var/log/squid/access.log
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
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
        echo ">> 4) Consultar logs"
        echo ">> 5) Iniciar servicio"
        echo ">> 6) Detener servicio"
        echo ">> 7) Reiniciar servicio"
        echo ">> 8) Ver datos de red"
        echo ">> 9) Ayuda de comandos"
        echo ">> 10) Salir"
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
                mostrarLogs
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            5)
                iniciarServicio
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            6)
                detenerServicio
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            7)
                reiniciarServicio
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            8)
                datosRed
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            9)
                mostrarAyuda
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            10)
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
        --backup)
            copiaSeg
            ;;
        --info)
            informacionServicio
            ;;
        --logs)
            mostrarLogs
            ;;
        --start)
            iniciarServicio
            ;;
        --stop)
            detenerServicio
            ;;
        --restart)
            reiniciarServicio
            ;;
        --network)
            datosRed
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
