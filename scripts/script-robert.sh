#!/bin/bash

function mostrarAyuda() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo ">>  --install      Instala el servicio Squid."
    echo ">>  --info         Muestra información del servicio Squid."
    echo ">>  --logs         Muestra los logs del servicio Squid."
    echo ">>  --start        Inicia el servicio Squid."
    echo ">>  --stop         Detiene el servicio Squid."
    echo ">>  --network       Muestra los datos de red de tu equipo."
    echo ">>  --help         Muestra esta ayuda y las opciones disponibles."
    echo ""
    echo "Si se ejecuta sin argumentos, se mostrará un menú interactivo."
}

function datosRed() {
    echo "Información de la red:"
    IP=$(hostname -I | grep -oP '\d+\.\d+\.\d+\.\d+' | head -n 1)
    GATEWAY=$(ip route | grep default | grep -oP 'default via \K\S+')
    MASK=$(ifconfig | grep -A 1 "$IP" | grep -oP 'Mask:\K\S+')

    echo "IP: $IP"
    echo "Máscara de Red: $MASK"
    echo "Puerta de enlace: $GATEWAY"
}

function comprobarInstalacion() {
    if [ -f /etc/squid/squid.conf ]; then
        echo "Squid ya está instalado."
    else
        echo "Squid no está instalado. Procediendo con la instalación..."
    fi
}

function instalarConAnsible() {
    echo "Instalando Squid con Ansible..."
    if command -v ansible &> /dev/null; then
        if [ -f "ansible.cfg" ] && [ -f "instalarproxy.yml" ]; then
            ansible-playbook -i hosts instalarproxy.yml
            echo "Instalación con Ansible completada."
        else
            echo "Faltan archivos de configuración de Ansible."
        fi
    else
        echo "Ansible no está instalado. Instalando..."
        sudo apt install -y ansible
        ansible-playbook -i hosts instalarproxy.yml
    fi
}

function instalarConDocker() {
    echo "Instalando Squid con Docker..."
    if command -v docker &> /dev/null; then
        if [ -f "Dockerfile" ]; then
            docker build -t ubuntu-proxy -f Dockerfile .
            docker run -d --name squid_proxy ubuntu-proxy
            echo "Instalación con Docker completada."
        else
            echo "Falta el archivo Dockerfile."
        fi
    else
        echo "Docker no está instalado. Instalando..."
        sudo apt install -y docker.io
        docker build -t ubuntu-proxy -f Dockerfile .
        docker run -d --name squid_proxy ubuntu-proxy
    fi
}

function instalarConComandos() {
    comprobarInstalacion
    echo "Instalando Squid..."
    sudo apt update
    sudo apt install -y squid
    echo "Instalación completada."
}

function eliminarServicio() {
    echo "Eliminando el servicio Squid..."
    sudo apt remove --purge -y squid
    sudo apt autoremove -y
    echo "Servicio eliminado."
}

function iniciarServicio() {
    echo "Iniciando el servicio Squid..."
    sudo systemctl start squid
    echo "Servicio iniciado."
}

function detenerServicio() {
    echo "Deteniendo el servicio Squid..."
    sudo systemctl stop squid
    echo "Servicio detenido."
}

function logsServicio() {
    clear
    echo "Seleccione el tipo de log que desea consultar:"
    echo "1) Por fecha"
    echo "2) Por tipo (acceso, error, etc.)"
    echo "3) Consultar logs completos"
    echo ""
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1)
            read -p "Por fecha (ejemplo: '2025-02-17'): " fecha
            sudo journalctl -u squid --since "$fecha"
            ;;
        2)
            echo "Seleccione el tipo de log:"
            echo "1) Accesos"
            echo "2) Errores"
            echo "3) Personalizado (especificar patrón)"
            read -p "Seleccione una opción: " tipo
            case $tipo in
                1)
                    sudo cat /var/log/squid/access.log
                    ;;
                2)
                    sudo cat /var/log/squid/cache.log
                    ;;
                3)
                    read -p "Introduzca el patrón que desea buscar (por ejemplo, una IP o un término): " patron
                    sudo grep "$patron" /var/log/squid/access.log
                    sudo grep "$patron" /var/log/squid/cache.log
                    ;;
                *)
                    echo "ERROR: la opción no válida. Inténtalo de nuevo."
                    ;;
            esac
            ;;
        3)
            sudo journalctl -u squid
            ;;
        *)
            echo "ERROR: la opción no válida. Inténtalo de nuevo."
            ;;
    esac
}

function informacionServicio() {
    echo "==========================================="
    echo "==== INFORMACIÓN DEL SERVICIO DE SQUID ===="
    echo "==========================================="
    if command -v squid &> /dev/null; then
        squid -v 2>&1 | head -n 1
    else
        echo "AVISO: Squid no está instalado."
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
        echo ">> 2) Información del servicio"
        echo ">> 3) Consultar logs"
        echo ">> 4) Iniciar servicio"
        echo ">> 5) Detener servicio"
        echo ">> 6) Ver datos de red"
        echo ">> 9) Salir"
        echo ""
        read -p "Seleccione una opción: " opcion
        case $opcion in
            1)
                echo "Seleccione cómo instalar el servicio:"
                echo "1) Con comandos"
                echo "2) Con Ansible"
                echo "3) Con Docker"
                read -p "Seleccione una opción: " subopcion
                case $subopcion in
                    1) instalarConComandos ;;
                    2) instalarConAnsible ;;
                    3) instalarConDocker ;;
                    *) echo "Opción no válida." ;;
                esac
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            2) informacionServicio ;;
            3) logsServicio ;;
            4) iniciarServicio ;;
            5) detenerServicio ;;
            6) datosRed ;;
            9)
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
        --info)
            informacionServicio
            ;;
        --logs)
            logsServicio
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