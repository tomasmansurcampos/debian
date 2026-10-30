# Debian 13 GNU/Linux Post-Install Automation (`aid13`)

Script en Bash para la automatización de la configuración posinstalación de **Debian 13 (Trixie) GNU/Linux** en arquitectura `amd64`. Optimizado para el despliegue rápido tanto en **Servidores Privados Virtuales (VPS)** como en **computadoras de escritorio y laptops (PC)**.

## Características

- **Optimización de APT:** Configuración de parámetros de descarga y limpieza de listas.
- **Ajustes de Sistema y Kernel:** Parámetros `sysctl` para hardening básico y gestión de red.
- **Configuración de Entorno CLI:** Personalización de `nano` (números de línea, tabulaciones) y perfil de terminal.
- **Sincronización de Hora:** Configuración activa de `systemd-timesyncd`.
- **Gestión de Energía:** Soporte para instalación y optimización de `TLP` en equipos portátiles.
- **Paquetes Esenciales:** Instalación en lote de herramientas de diagnóstico, administración, desarrollo, y utilidades CLI/GUI.

## Requisitos

- Debian 13 GNU/Linux (Trixie) `amd64`.
- Usuario con privilegios `sudo` o acceso directo como `root`.
- Conexión a Internet activa.

## Instalación y Ejecución

```bash
git clone [https://github.com/tomasmansurcampos/debian.git](https://github.com/tomasmansurcampos/debian.git)
cd debian
bash ./aid13.sh
```
