# PROYECTO SHELL-SCRIPT Y AUTOMATIZACIÓN DEL SERVICIO DE PROXY

## DESCRIPCIÓN

Este proyecto tiene como objetivo automatizar la instalación y gestión de un servicio de proxy utilizando herramientas de automatización como **Ansible**, **Docker**, **Git** y **Shell scripting**. El servicio de proxy se implementa mediante el paquete `squid`, y el proyecto incluye varios métodos de implementación, desde Ansible hasta Docker.

El propósito principal es automatizar tareas repetitivas, como la instalación del servicio y la gestión de su configuración, así como mejorar la eficiencia y la fiabilidad en la administración de sistemas.

## ESTRUCTURA

Este repositorio contiene los siguientes componentes:

- **`install_proxy.yml`**: este es el archivo playbook de Ansible para instalar y configurar el servicio de proxy (`squid`).
- **`Dockerfile`**: es el archivo de configuración para crear una imagen de Docker que contenga el servicio de proxy configurado.
- **`hosts`**: es el archivo de inventario de Ansible que define las máquinas donde se ejecutarán los playbooks.
- **`scripts/`**: es la carpeta que contiene diferentes versiones de scripts para gestionar el servicio de proxy, como instalación, actualización y gestión de logs.

## REQUISITOS

Para ejecutar este proyecto, hay que asegurarse de tener instalado el siguiente software:

- **Ansible**: para automatizar la instalación y configuración del servicio de proxy.
- **Docker**: para crear y ejecutar el servicio de proxy como un contenedor.
- **Git**: para gestionar el código y colaborar en el proyecto.
- **Ubuntu (o sistema compatible)**: se recomienda usar Ubuntu para la instalación del servicio `squid`, aunque puede adaptarse a otros sistemas Linux.

## INSTALACIÓN Y USO

### 1. INSTALACIÓN CON ANSIBLE

Para instalar el servicio de proxy utilizando Ansible, sigue estos pasos:

1. Clona el repositorio:

   git clone https://github.com/thisisrober/servicio-de-proxy
   cd servicio-de-proxy

2. Ejecuta el playbook de Ansible para instalar el servicio de proxy:

   ansible-playbook -i hosts install_proxy.yml

### 2. INSTALACION CON DOCKER (próximamente...)