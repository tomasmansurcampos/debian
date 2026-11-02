# AID13 — Debian 13 Post-Installation & System Provisioning

**AID13** es un script de automatización desarrollado en Bash para facilitar la configuración, personalización y aprovisionamiento de una instalación nueva de **Debian 13 (Trixie)**.

Mediante una interfaz interactiva de terminal (TUI) basada en Whiptail, permite seleccionar individualmente diferentes componentes, herramientas, entornos de desarrollo, aplicaciones y configuraciones del sistema operativo.

Su enfoque modular permite adaptar la instalación a distintos escenarios de uso: desarrollo de software, administración de sistemas, infraestructura de redes, ciberseguridad, inteligencia artificial local, multimedia y uso general de escritorio.

El objetivo es reducir el trabajo manual posterior a una instalación de Debian y disponer de un entorno de trabajo completo, configurable y reproducible.

---

## Características principales

- **Aprovisionamiento modular:** selección individual de componentes mediante un menú interactivo.
- **Automatización con Bash:** instalación y configuración de paquetes, servicios, repositorios y herramientas.
- **Gestión de paquetes:** integración con APT, Flatpak y repositorios oficiales de terceros.
- **Entorno de desarrollo:** múltiples lenguajes de programación, compiladores, toolchains y sistemas de construcción.
- **Administración de sistemas y redes:** herramientas de diagnóstico, monitoreo, análisis y administración.
- **Seguridad y privacidad:** configuración de parámetros del kernel, DNS cifrado, Tor y herramientas de auditoría.
- **Inteligencia artificial local:** instalación de Ollama, OpenCode y modelos de lenguaje ejecutados localmente.
- **Optimización del sistema:** configuración de ZRAM, Swap, TLP y parámetros de arranque.
- **Instalación de versiones recientes:** descarga y compilación de determinadas herramientas directamente desde sus repositorios oficiales.

## Interfaz interactiva

AID13 utiliza **Whiptail** para presentar un menú de selección múltiple desde la terminal.

El usuario puede elegir qué instalar o configurar sin necesidad de modificar el código fuente ni ejecutar manualmente cada función.

- `Flechas`: desplazarse por las opciones.
- `Espacio`: seleccionar o deseleccionar componentes.
- `Enter`: confirmar la selección.
- `Esc`: cancelar la operación.

Las opciones aparecen con valores predeterminados que pueden modificarse antes de confirmar.

## Módulos y funcionalidades

### 1. Sistema base y configuración de APT

- Configuración de repositorios oficiales de Debian.
- Habilitación de los componentes `contrib`, `non-free` y `non-free-firmware`.
- Configuración de repositorios `deb` y `deb-src`.
- Deshabilitación de la instalación automática de paquetes recomendados y sugeridos.
- Limpieza de caché y listas de paquetes de APT.
- Creación de un script independiente para mantenimiento de APT.
- Configuración de Nano con numeración de líneas.

### 2. Seguridad y hardening del sistema

Configuraciones orientadas a reforzar determinados parámetros de seguridad del kernel y del sistema operativo.

**Hardening de GRUB:**
- Configuración de parámetros de protección del kernel.
- Inicialización y liberación de memoria.
- Aleatorización de estructuras de memoria.
- Configuración de Intel IOMMU.
- Habilitación de OS Prober.

**Hardening del kernel y la red mediante sysctl:**
- Restricciones sobre BPF no privilegiado.
- Protección de enlaces simbólicos y duros.
- Restricciones de acceso a información del kernel.
- Protección de FIFOs y archivos regulares.
- Protección frente a determinados ataques de red.
- Configuración de filtros y parámetros TCP/IP.

También incorpora una opción para deshabilitar IPv6 globalmente.

### 3. DNS y privacidad de las comunicaciones

Instalación y configuración automatizada de **DNSCrypt-Proxy**.

Incluye:
- Resolución DNS mediante DNS-over-HTTPS (DoH).
- Validación DNSSEC.
- Selección de resolvers sin filtrado y sin registro de consultas.
- Configuración de DNS sobre TCP.
- Configuración de NetworkManager.
- Configuración de `/etc/resolv.conf`.
- Deshabilitación de IPv6 en la configuración DNS.

### 4. Desarrollo de software y programación

Instalación de un entorno de desarrollo multipropósito.

**Lenguajes y toolchains:**
- C / C++: GCC, G++, Clang y LLVM.
- Python 3: pip, venv, headers y bibliotecas de desarrollo.
- Java: OpenJDK y herramientas Maven y Gradle.
- JavaScript: Node.js y npm.
- Go: instalación de la versión más reciente desde go.dev.
- Rust: instalación mediante Rustup, Cargo y Rustc.

**Compilación y construcción:**
- Build Essential.
- GNU Make.
- CMake.
- Ninja.
- Autoconf y Automake.
- Binutils.
- DKMS.
- Cabeceras del kernel.

**Depuración y desarrollo de bajo nivel:**
- GDB.
- LLDB.
- NASM.
- YASM.

**Control de versiones y utilidades:**
- Git y Git LFS.
- cURL y Wget.
- jq.
- ripgrep.
- fd-find.
- rsync.

### 5. Python, automatización y Web Scraping

Instalación de herramientas y dependencias para desarrollo Python, automatización, análisis de redes y extracción de información web.

Incluye:
- Requests.
- BeautifulSoup.
- lxml.
- Scrapy.
- HTTPX.
- Selenium.
- urllib3.
- Scapy.
- Python venv y herramientas de desarrollo.

También incorpora dependencias de desarrollo para XML, XSLT, criptografía, SSL, SQLite y captura de paquetes.

### 6. Infraestructura, servidores y bases de datos

**Servidores y backend:**
- Nginx.
- PHP CLI y extensiones para PostgreSQL, SQLite, XML, cURL y mbstring.

**Bases de datos:**
- PostgreSQL 17.
- SQLite 3.
- Redis Server.

**Contenedores:**
- Docker.
- Docker Compose.

Los servicios Docker, PostgreSQL, Redis y Nginx se instalan inicialmente deshabilitados y detenidos mediante el módulo de paquetes esenciales.

### 7. Redes, administración y ciberseguridad

Herramientas orientadas a administración de infraestructura, diagnóstico, análisis de tráfico y auditoría de redes.

**Diagnóstico y monitoreo:**
- DNS Utils.
- IPCalc.
- Socat.
- TCPDump.
- Conntrack.
- htop.
- bmon.

**Análisis y auditoría:**
- Nmap: descarga, compilación e instalación desde el código fuente oficial.
- Wireshark.
- TShark.
- sqlmap: descarga y actualización desde el repositorio oficial de GitHub.

**VPN y privacidad:**
- WireGuard.
- OpenVPN.
- IVPN.
- ProtonVPN.

### 8. Inteligencia artificial local

Módulo para configurar un entorno de inteligencia artificial ejecutado localmente, sin depender de servicios de inferencia en la nube.

**Componentes:**
- Ollama: motor de ejecución de modelos de lenguaje.
- OpenCode: asistente de programación con soporte para modelos locales.

**Modelos incluidos:**
- Qwen 2.5 Coder 7B.
- DeepSeek R1 8B.
- Gemma 4 E2B.
- Gemma 4 E4B.
- Granite 4.2 3B.
- Granite 4.2 8B.

**Optimización de Ollama:**

Se configura el servicio mediante un override de systemd:

- Un modelo cargado simultáneamente como máximo.
- Una solicitud paralela como máximo.
- Flash Attention habilitado.
- Tiempo de permanencia de modelos en memoria de cinco minutos.

Además, el script genera versiones adicionales de cada modelo con un contexto limitado a 4096 tokens, utilizando Modelfiles personalizados.

### 9. Optimización de memoria y energía

**ZRAM y Swap:**
- Instalación de zram-tools.
- Compresión ZRAM mediante Zstandard (zstd).
- Configuración de ZRAM al 25 % de la memoria RAM.
- Ajuste de `vm.swappiness` a 80.
- Configuración de `vm.page-cluster` en 0.

**Gestión energética:**
- Instalación de TLP.
- Configuración de umbral de inicio de carga al 40 %.
- Configuración de umbral de finalización de carga al 80 %.

**Kernel alternativo:**
- Instalación del kernel Liquorix.

### 10. Gestión horaria y sincronización NTP

Permite seleccionar entre dos configuraciones:

- **UTC:** configura la zona horaria UTC y systemd-timesyncd, con servidores NTP de pool.ntp.org y Cloudflare como alternativa.
- **Argentina:** configura `America/Argentina/Buenos_Aires` y reinicia el servicio de sincronización horaria.

También contempla una sincronización inicial utilizando la fecha obtenida mediante HTTP o el reloj de hardware.

### 11. Navegadores y aplicaciones de escritorio

**Navegadores:**
- Google Chrome.
- Brave.
- Tor Browser.
- Ungoogled Chromium (Flatpak).
- Firefox ESR.
- Chromium.

**Aplicaciones:**
- LibreOffice.
- KeePassXC.
- Flatseal.
- VLC.
- Foliate.
- Audacity.
- Mixxx.
- Picard.
- Strawberry.
- Spek.
- Flacon.
- qBittorrent.
- Nicotine+.
- Zoom.
- Discord.
- Telegram.

**Herramientas de desarrollo:**
- Visual Studio Code.
- VSCodium.
- Geany.
- PuTTY.

### 12. Virtualización y compatibilidad

- VirtualBox 7.2.
- WineHQ Development.
- Winetricks.
- Steam.
- Controladores y bibliotecas Mesa Vulkan de 32 y 64 bits.
- Soporte para aplicaciones y juegos que requieren bibliotecas de 32 bits.

El módulo de VirtualBox también contempla la desactivación de módulos KVM para evitar conflictos con esa configuración.

### 13. Multimedia y procesamiento de audio y video

**FFmpeg:**
- Descarga de la compilación Master GPL de BtbN.
- Instalación de FFmpeg, FFprobe y FFplay.
- Instalación de binarios directamente en `/usr/local/bin`.

**SoX NG:**
- Descarga de la última versión publicada en Codeberg.
- Instalación de dependencias de compilación.
- Configuración mediante Autotools.
- Compilación e instalación desde el código fuente.
- Gestión de compilaciones anteriores.

También incluye herramientas de procesamiento multimedia como FLAC, ImageMagick y bibliotecas adicionales de audio y video.

### 14. Herramientas adicionales

- **Ventoy:** descarga y extracción de la última versión disponible.
- **yt-dlp:** instalación de la última versión desde GitHub y Deno como runtime JavaScript.
- **WeeChat:** cliente IRC con soporte para plugins.
- **Tor:** instalación y configuración del servicio con scripts independientes para iniciarlo y detenerlo.
- **Scrot:** herramienta personalizada para capturas de pantalla, guardado automático y copia de imagen al portapapeles.
- **Fastfetch:** instalación de la última versión publicada en GitHub.
- **Cookie Fortune:** integración de Fortune y Cowsay con personajes aleatorios.
- **Machines: Wired for War:** instalación mediante Flatpak y descarga de sus recursos.

---

## Requisitos

- Debian 13 (Trixie).
- Arquitectura AMD64 / x86_64 para los módulos que utilizan binarios específicos de esa arquitectura.
- Bash.
- Acceso a una cuenta con privilegios `sudo`.
- Conexión a Internet.
- Whiptail.
- Systemd y APT.

El script requiere acceso a Internet para descargar paquetes, repositorios, binarios y código fuente.

## Instalación y ejecución

Clonar el repositorio:

```bash
git clone https://github.com/tomasmansurcampos/debian.git
```

Ingresar al directorio:

```bash
cd debian
```

Dar permisos de ejecución:

```bash
chmod +x aid13.sh
```

Ejecutar:

```bash
./aid13.sh
```

El script solicitará las credenciales de `sudo` al inicio y mantendrá activa la autenticación durante la ejecución.

**Importante:** ejecutar el script desde el usuario habitual, sin anteponer `sudo`, ya que algunas operaciones utilizan rutas y configuraciones del directorio personal del usuario.

## Consideraciones importantes

AID13 realiza modificaciones reales sobre el sistema operativo. Algunas funciones:

- Modifican archivos de configuración en `/etc`.
- Instalan y habilitan servicios systemd.
- Incorporan repositorios externos.
- Modifican parámetros de red, DNS, kernel y GRUB.
- Descargan y ejecutan instaladores de terceros.
- Compilan e instalan software en `/usr/local`.

Se recomienda utilizarlo sobre una instalación nueva de Debian 13 y revisar las opciones seleccionadas antes de confirmar.

No todas las configuraciones son apropiadas para cualquier equipo o entorno. Algunas opciones, como deshabilitar IPv6, modificar GRUB o bloquear `/etc/resolv.conf`, pueden afectar la conectividad y el funcionamiento de determinados servicios.

Las instalaciones de terceros y las versiones descargadas desde repositorios externos están sujetas a los cambios de sus respectivos proveedores.

## Filosofía del proyecto

AID13 nace como una solución personal para automatizar el trabajo posterior a una instalación de Debian 13.

En lugar de mantener múltiples scripts independientes o ejecutar decenas de comandos manualmente, concentra las tareas de instalación y configuración en una única herramienta modular.

Su diseño permite seleccionar solamente los componentes necesarios, combinar diferentes perfiles de trabajo y construir un entorno Linux adaptado a las necesidades de cada usuario.

**Un único script, múltiples posibilidades de aprovisionamiento.**

---

## Repositorio

**GitHub:** [tomasmansurcampos/debian](https://github.com/tomasmansurcampos/debian)

**Script principal:** [aid13.sh](https://github.com/tomasmansurcampos/debian/blob/main/aid13.sh)

