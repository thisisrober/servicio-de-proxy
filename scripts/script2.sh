!/bin/bash
mostrar_menu() {
    clear
    echo "===================================="
    echo " Instalación y Configuración de Proxy"
    echo "===================================="
    echo "1. Instalar Squid Proxy"
    echo "2. Configurar Puerto"
    echo "3. Habilitar Autenticación"
    echo "4. Reiniciar Servicio Squid"
    echo "5. Ver Estado del Servicio"
    echo "6. Realizar Copia de Seguridad"
    echo "7. Mostrar Ayuda"
    echo "8. Salir"
    echo "===================================="
}

mostrar_ayuda() {
    clear
    echo "===================================="
    echo " Ayuda: Instalación y Configuración de Proxy"
    echo "===================================="
    echo "Este script permite instalar y configurar un servidor proxy Squid."
    echo "Opciones disponibles:"
    echo ""
    echo "1. Instalar Squid Proxy: Instala el servidor proxy Squid en tu sistema."
    echo "2. Configurar Puerto: Cambia el puerto en el que escucha el proxy (por defecto 3128)."
    echo "3. Habilitar Autenticación: Configura autenticación básica con usuario y contraseña."
    echo "4. Reiniciar Servicio Squid: Reinicia el servicio Squid para aplicar cambios."
    echo "5. Ver Estado del Servicio: Muestra el estado actual del servicio Squid."
    echo "6. Realizar Copia de Seguridad: Realiza una copia de seguridad del archivo de configuración de Squid."
    echo "7. Mostrar Ayuda: Muestra esta información de ayuda."
    echo "8. Salir: Cierra el script."
    echo ""
    echo "===================================="
    read -p "Presiona Enter para volver al menú..."
}

instalar_squid() {
    echo "Instalando Squid Proxy..."
        sudo apt-get update
        sudo apt-get install -y squid
    echo "Squid instalado correctamente."
}

configurar_puerto() {
    read -p "Introduce el puerto para el proxy (por defecto 3128): " puerto
        puerto=${puerto:-3128}
        sudo sed -i "s/http_port .*/http_port $puerto/" /etc/squid/squid.conf
    echo "Puerto configurado a $puerto."
}

habilitar_autenticacion() {
    echo "Habilitando autenticación..."
        sudo apt-get install -y apache2-utils
            read -p "Introduce el nombre de usuario: " usuario
        sudo htpasswd -c /etc/squid/passwords $usuario
        sudo sed -i 's/#auth_param/auth_param/' /etc/squid/squid.conf
        sudo sed -i 's/#http_access allow authenticated/http_access allow authenticated/' /etc/squid/squid.conf
    echo "Autenticación habilitada."
}

reiniciar_squid() {
    echo "Reiniciando Squid..."
        sudo systemctl restart squid
    echo "Squid reiniciado."
}

estado_squid() {
    sudo systemctl status squid
}

copia_seguridad() {
    echo "Realizando copia de seguridad de la configuración de Squid..."
    sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.backup
    echo "Copia de seguridad realizada en /etc/squid/squid.conf.backup."
}

while true; do
    mostrar_menu
    read -p "Selecciona una opción (1-8): " opcion
    case $opcion in
        1) instalar_squid ;;
        2) configurar_puerto ;;
        3) habilitar_autenticacion ;;
        4) reiniciar_squid ;;
        5) estado_squid ;;
        6) copia_seguridad ;;
        7) mostrar_ayuda ;;
        8) echo "Saliendo..."; break ;;
        *) echo "Opción no válida. Inténtalo de nuevo." ;;
    esac
    read -p "Presiona Enter para continuar..."
done