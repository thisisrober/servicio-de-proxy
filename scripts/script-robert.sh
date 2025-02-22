#!/bin/bash

function mostrarAyuda() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo ">>  --network       Muestra los datos de red de tu equipo."
    echo ">>  --info         Muestra información del servicio Squid."
    echo ">>  --install      Instala el servicio Squid."
    echo ">>  --uninstall    Desinstala el servicio Squid."
    echo ">>  --logs         Muestra los logs del servicio Squid."
    echo ">>  --start        Inicia el servicio Squid."
    echo ">>  --stop         Detiene el servicio Squid."
    echo ">>  --config       Edita la configuración de Squid."
    echo ">>  --help         Muestra esta ayuda y las opciones disponibles."
    echo ""
    echo "Si se ejecuta sin argumentos, se mostrará un menú interactivo."
}

function datosRed() {
    echo "Información de la red:"
    IP=$(hostname -I | grep -oP '\d+\.\d+\.\d+\.\d+' | head -n 1)
    GATEWAY=$(ip route | grep default | grep -oP 'default via \K\S+')
    MASK=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | cut -d/ -f2)

    echo "IP: $IP"
    echo "Máscara de Red: $MASK"
    echo "Puerta de enlace: $GATEWAY"
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
    if [ -f /etc/squid/squid.conf ]; then
        echo "Squid ya está instalado. No es necesario realizar la instalación."
        return 
    fi
    
    echo "Instalando Squid..."
    sudo apt update
    sudo apt install -y squid
    echo "Instalación completada."
}

function eliminarServicio() {
    if systemctl is-active --quiet squid; then
        echo "Deteniendo el servicio Squid antes de eliminarlo..."
        sudo systemctl stop squid
    fi

    echo "Eliminando el servicio Squid..."
    sudo apt remove --purge -y squid

    sudo apt autoremove -y
    sudo apt clean

    sudo rm -rf /etc/squid /var/log/squid

    echo "Servicio Squid eliminado correctamente."
}

function iniciarServicio() {
    if systemctl is-active --quiet squid; then
        echo "El servicio Squid ya está en ejecución."
    else
        echo "Iniciando el servicio Squid..."
        sudo systemctl start squid
        echo "Servicio iniciado."
    fi
}

function detenerServicio() {
    if systemctl is-active --quiet squid; then
        echo "Deteniendo el servicio Squid..."
        sudo systemctl stop squid
        echo "Servicio detenido."
    else
        echo "El servicio Squid ya está detenido."
    fi
}

function logsServicio() {
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
                    echo "ERROR: opción no válida. Inténtalo de nuevo."
                    ;;
            esac
            ;;
        3)
            sudo journalctl -u squid
            ;;
        *)
            echo "ERROR: opción no válida. Inténtalo de nuevo."
            ;;
    esac
}

function editarConfiguracion() {
    echo "Editando la configuración de Squid..."
    echo "Se abrirá el archivo squid.conf en el editor de texto."
    
    sudo nano /etc/squid/squid.conf
    
    echo "¿Quieres aplicar los cambios y reiniciar el servicio Squid? (s/n) o (y/n)"
    read -p "Respuesta: " respuesta
    
    if [[ "$respuesta" =~ ^[sSyY](i|I|e|E|es|ES|si|SI|yes|YES)?$ ]]; then
        sudo systemctl restart squid
        echo "Servicio Squid reiniciado con los nuevos cambios."
    elif [[ "$respuesta" =~ ^[nN](o|O)?$ ]]; then
        echo "Los cambios se han guardado pero no se han aplicado. No se reiniciará el servicio."
    else
        echo "ERROR: Respuesta no válida. No se aplicaron los cambios."
    fi
}

function menuPrincipal() {
    while true; do
        echo "========================================="
        echo "==== MENÚ DE ADMINISTRACIÓN DE SQUID ===="
        echo "========================================="
        echo ">> 1) Instalar servicio"
        echo ">> 2) Eliminar servicio"
        echo ">> 3) Iniciar servicio"
        echo ">> 4) Detener servicio"
        echo ">> 5) Consultar logs del servicio"
        echo ">> 6) Editar configuración del servicio"
        echo ">> 9) Salir"
        echo ""
        read -p "Seleccione una opción: " opcion
        case $opcion in
            1)
                echo "Seleccione cómo instalar el servicio:"
                echo "1) Con Ansible"
                echo "2) Con Docker"
                echo "3) Con comandos"
                read -p "Seleccione una opción: " subopcion
                case $subopcion in
                    1) instalarConAnsible ;;
                    2) instalarConDocker ;;
                    3) instalarConComandos ;;
                    *) echo "Opción no válida." ;;
                esac
                read -p "Presione la tecla [ENTER] para continuar..."
                ;;
            2) eliminarServicio ;;
            3) iniciarServicio ;;
            4) detenerServicio ;;
            5) logsServicio ;;
            6) editarConfiguracion ;;
            9)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "ERROR: opción no válida. Inténtalo de nuevo."
                sleep 2
                ;;
        esac
    done
}

datosRed
informacionServicio

if [ $# -gt 0 ]; then
    case "$1" in
        --network)
            datosRed
            ;;
        --info)
            informacionServicio
            ;;
        --install)
            instalarConComandos
            ;;
        --uninstall)
            eliminarServicio
            ;;
        --start)
            iniciarServicio
            ;;
        --stop)
            detenerServicio
            ;;
        --logs)
            logsServicio
            ;;
        --config)
            editarConfiguracion
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