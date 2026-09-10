#!/bin/sh

set -euo pipefail

ESSENTIAL_PACKAGES=(
    build-essential ca-certificates gpg rsync fonts-noto-color-emoji ttf-mscorefonts-installer 
    firmware-linux-nonfree memtest86+ smartmontools adb fastboot zbar-tools screen minicom 
    nano man gcc make cmake nasm gdb rust-all golang python3-full python-is-python3 
    python-dev-is-python3 curl wget socat dnsutils wireguard openvpn git binutils tcpdump lynx lsb-release 
    htop bmon locales-all ascii ipcalc 7zip 7zip-rar rar unrar zip unzip ffmpeg flac libavcodec-extra imagemagick
    postgresql-17 tlp 
)

PACKAGES=(
    flatpak vlc foliate audacity mixxx picard geany putty
)

### instala todo lo que necesito de flatpak.
_flatpak()
{
    #sudo apt remove -y flatpak
    #sudo rm -rf /var/lib/flatpak/ && rm -rf /home/*/.cache/flatpak/ && rm -rf /home/*/.local/share/flatpak/ && rm -rf /home/*/.var/app/* && rm -rf /root/.local/share/flatpak/

	sudo apt update
    sudo apt install --reinstall -y flatpak

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    flatpak --user update -y
    flatpak update -y

    flatpak install -y flathub com.github.tchx84.Flatseal \
    		org.keepassxc.KeePassXC \
    		org.libreoffice.LibreOffice \
		io.github.ungoogled_software.ungoogled_chromium \
        us.zoom.Zoom \
        com.discordapp.Discord \
        org.telegram.desktop \
        cc.spek.Spek \
        org.nicotine_plus.Nicotine \
        org.qbittorrent.qBittorrent \
        com.spotify.Client \
        com.github.Flacon \
        com.vscodium.codium #\
        #com.play0ad.zeroad \
        #net.supertuxkart.SuperTuxKart \
        #org.xonotic.Xonotic

    sudo ln -vsf /var/lib/flatpak/exports/bin/cc.spek.Spek /usr/local/bin/spek
    sudo ln -vsf /var/lib/flatpak/exports/bin/com.vscodium.codium /usr/local/bin/codium

    flatpak update -y
}

_visual_studio_code()
{
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
	cat <<"EOF" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

	sudo apt update
	sudo apt install -y code
}

_wireshark()
{
	sudo apt install -y wireshark tshark
	sudo usermod -aG wireshark $USER
	sudo chgrp wireshark /usr/bin/dumpcap
	sudo chmod 750 /usr/bin/dumpcap
	sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
	newgrp wireshark
}

### --- instala yt-dlp ---
_ytdlp()
{
	sudo apt remove -y yt-dlp
    local bin_dir="${HOME}/.local/bin"
    mkdir -vp "${bin_dir}"
    wget -q --show-progress https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O "${bin_dir}/yt-dlp"
    chmod +x "${bin_dir}/yt-dlp"
    sudo ln -vsf "${bin_dir}/yt-dlp" /usr/local/bin/yt-dlp
}

### --- instala el mejor fork del videojuego clasico "Machines: Wired for War" de Acclaim ---
_wired_for_war()
{
    flatpak install -y --user https://wiredforwar.github.io/flatpak/wiredforwar-machines.flatpakref
    mkdir -p ~/.var/app/io.github.wiredforwar.machines/downloads
    cd ~/.var/app/io.github.wiredforwar.machines/downloads
    wget https://download.wiredforwar.org/Game/Community-Build-1.5/machines-assets.7z
    7z x machines-assets.7z -o../data
    cd ~
    flatpak update -y io.github.wiredforwar.machines
    #flatpak run io.github.wiredforwar.machines
}

### como en Debian 13 GNU/Linux Trixie (stable) tiene la version vieja de sox 14.4.x del año 2014 todavia...
### Se descarga el fork moderno de sox llamado sox_ng y se lo compila e instala.
_sox_ng()
{
    cat << "EOF" | sudo tee /usr/local/bin/installer-sox-ng > /dev/null
#!/bin/sh

set -e

# --- 1. Verificación y Limpieza de instalación previa ---
if [ -d "$HOME/.sox_ng_compiled" ]; then
    echo "Detectada compilación previa en $HOME/.sox_ng_compiled. Desinstalando..."
    cd "$HOME/.sox_ng_compiled" || exit 1
    if [ -f "Makefile" ]; then
        sudo make uninstall
    fi
    cd "$HOME" || exit 1
    rm -rf "$HOME/.sox_ng_compiled"
fi

# Limpieza forzada de binarios y enlaces residuales
sudo rm -vf /usr/local/bin/sox /usr/local/bin/soxi /usr/local/bin/play /usr/local/bin/rec
sudo rm -vf /usr/local/bin/sox_ng /usr/local/bin/soxi_ng /usr/local/bin/play_ng /usr/local/bin/rec_ng

# --- 2. Instalación de dependencias ---
sudo apt update
sudo apt install -y build-essential autoconf automake \
	gcc make libtool ladspa-sdk libao-dev libasound2-dev libfftw3-dev \
	libgsm1-dev libid3tag0-dev libltdl-dev libmad0-dev libmagic-dev \
	libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev \
	libopusfile-dev libpng-dev libpulse-dev \
	libsndfile1-dev libspeex-dev libspeexdsp-dev libtwolame-dev \
	libvorbis-dev libwavpack-dev

# --- 3. Descarga ---
cd "$HOME" || exit 1
# Asegurar que no exista un directorio residual que bloquee el git clone
rm -rf "$HOME/sox_ng"
rm -rf "$HOME/.sox_ng_compiled"
    
# Extracción de versión con validación
TAG=$(curl -s https://codeberg.org/api/v1/repos/sox_ng/sox_ng/releases/latest | jq -r .tag_name)
if [ -z "$TAG" ] || [ "$TAG" = "null" ]; then
    echo "Error crítico: No se pudo obtener la última versión de sox_ng desde Codeberg."
    exit 1
fi

git clone --branch "$TAG" --depth 1 https://codeberg.org/sox_ng/sox_ng.git

# --- 4. Compilación e Instalación ---
cd "$HOME/sox_ng" || exit 1
autoreconf -i
./configure
make
sudo make install
sudo ldconfig

# --- 5. Post-instalación y organización ---
cd "$HOME" || exit 1
mv -v sox_ng .sox_ng_compiled
    
# Creación de enlaces simbólicos (Opcional)
#sudo ln -vfs /usr/local/bin/sox_ng /usr/local/bin/sox
#sudo ln -vfs /usr/local/bin/soxi_ng /usr/local/bin/soxi
#sudo ln -vfs /usr/local/bin/play_ng /usr/local/bin/play
#sudo ln -vfs /usr/local/bin/rec_ng /usr/local/bin/rec
    
echo "Instalación de sox_ng ($TAG) completada exitosamente."
EOF

    sudo chmod +x /usr/local/bin/installer-sox-ng
    /usr/local/bin/installer-sox-ng
}

_ffmpeg_master_latest()
{
	cat << "EOF" | sudo tee /usr/local/bin/installer-ffmpeg-master-latest > /dev/null
#!/bin/sh

# Variables
FILE="ffmpeg-master-latest-linux64-gpl.tar.xz"
URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/$FILE"
EXTRACTED_DIR="ffmpeg-master-latest-linux64-gpl"
TMP_DIR="/tmp/ffmpeg_install"

# Preparar directorio temporal
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

echo "Descargando el binario master GPL desde GitHub..."
wget -q --show-progress -O "$FILE" "$URL"

if [ ! -f "$FILE" ]; then
	echo "Error: Falló la descarga."
	exit 1
fi

echo "Extrayendo el archivo..."
tar -xf "$FILE"

echo "Instalando los binarios en /usr/local/bin..."
sudo cp -f "$EXTRACTED_DIR/bin/"* /usr/local/bin/

# Asegurar permisos de ejecución
sudo chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe /usr/local/bin/ffplay 2>/dev/null

echo "Limpiando archivos temporales..."
cd /
rm -rf "$TMP_DIR"

# Limpiar caché de rutas de bash
hash -r

echo "Configuración completada. Verificando prioridad de ejecución:"
# Mostrará /usr/local/bin/ffmpeg si la precedencia es correcta
UBICACION=$(which ffmpeg)
echo "El sistema está usando el binario en: $UBICACION"

if [ "$UBICACION" == "/usr/local/bin/ffmpeg" ]; then
	echo "Prioridad correcta."
else
	echo "Advertencia: El sistema no está priorizando /usr/local/bin."
fi

ffmpeg -version | head -n 1
EOF
	sudo chmod +x /usr/local/bin/installer-ffmpeg-master-latest
	/usr/local/bin/installer-ffmpeg-master-latest
}

### esto instala stubby, le configura el DoT de dns.sb,
### y configura el network manager del usuario en la configuracion local.
_stubby()
{
	sudo apt update
	sudo apt install -y stubby

	### Google Public DNS
	cat <<"EOF" | sudo tee /etc/stubby/stubby.yml.google > /dev/null
### DNS.SB
### openssl s_client -connect 8.8.8.8:853 </dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
round_robin_upstreams: 0
idle_timeout: 10000
tls_connection_retries: 5 #2
tls_backoff_time: 3600 #3600
timeout: 6000 #5000
tls_min_version: GETDNS_TLS1_3
tls_max_version: GETDNS_TLS1_3
listen_addresses:
  - 127.0.0.3
#  - 0::1
#dnssec: GETDNS_EXTENSION_TRUE
upstream_recursive_servers:
  - address_data: 8.8.8.8
    tls_auth_name: "dns.google"
  - address_data: 8.8.4.4
    tls_auth_name: "dns.google"
EOF

    sudo cp -v /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
    
	sudo systemctl enable --now stubby.service
	sudo systemctl restart stubby.service

    # Detección dinámica de la conexión activa en NetworkManager
    ACTIVE_CONN=$(nmcli -t -f NAME connection show --active | head -n 1)
    if [ -n "$ACTIVE_CONN" ]; then
        nmcli connection modify "$ACTIVE_CONN" ipv4.dns "127.0.0.3"
        nmcli connection modify "$ACTIVE_CONN" ipv4.ignore-auto-dns yes
        nmcli connection modify "$ACTIVE_CONN" ipv6.method "disabled"
        nmcli connection up "$ACTIVE_CONN"
    else
        echo "No se detectó ninguna conexión activa en NetworkManager para configurar Stubby."
    fi

    cat <<"EOF" | sudo tee /etc/resolv.conf > /dev/null
nameserver 127.0.0.3
EOF

    #sudo /usr/bin/chattr +i /etc/resolv.conf
}

_nmap()
{
	cat <<"EOF" | sudo tee /usr/local/bin/installer-nmap > /dev/null
#!/bin/bash
set -e

INSTALL_DIR="/usr/local/nmap-suite"

# --- Extracción robusta mediante expresiones regulares ---
SOURCE_CODE_FILE=$(curl -sL https://nmap.org/download.html | grep -oP 'nmap-\d+(\.\d+)+\.tar\.bz2' | head -n 1)

if [ -z "$SOURCE_CODE_FILE" ]; then
    echo "Error: No se pudo obtener el nombre del archivo de nmap.org." >&2
    exit 1
fi

URL="https://nmap.org/dist/$SOURCE_CODE_FILE"

if ! wget --inet4-only --https-only --quiet --spider "$URL"; then
    echo "Error: La URL objetivo $URL no existe o es inaccesible." >&2
    exit 1
fi

echo "===> Eliminando versiones previas de nmap."
sudo apt purge -y nmap nmap-common zenmap ndiff || true

if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf "$INSTALL_DIR"
fi

sudo rm -f /usr/bin/{nmap,ncat,nping,zenmap,ndiff}
sudo rm -f /usr/local/bin/{nmap,ncat,nping,zenmap,ndiff}

# --- Uso de directorio temporal seguro para la compilación ---
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR" || exit 1

echo "===> Instalando dependencias (Requiere deb-src habilitado)"
sudo apt update
sudo apt build-dep -y nmap

sudo mkdir -p -v "$INSTALL_DIR"

echo "===> Descargando el código fuente de nmap."
wget --inet4-only --https-only --show-progress -q "$URL" -O "$SOURCE_CODE_FILE"
tar xjf "$SOURCE_CODE_FILE"
rm -f "$SOURCE_CODE_FILE"

# --- Inferencia directa del directorio extraído ---
EXTRACTED_DIR="${SOURCE_CODE_FILE%.tar.bz2}"

if [[ ! -d "$EXTRACTED_DIR" ]]; then
    echo "Error: El directorio extraído $EXTRACTED_DIR no se encontró." >&2
    cd /
    rm -rf "$WORK_DIR"
    exit 1
fi

cd "$EXTRACTED_DIR" || exit 1

echo "===> Iniciando la configuración"
./configure --quiet --prefix="$INSTALL_DIR" --without-zenmap --without-nping --without-ncat --without-ndiff

echo "===> Compilando..."
make -j"$(nproc)"

echo "===> Instalando nmap en el sistema."
sudo make install

echo "===> Creando enlaces simbólicos"
for bin_file in "$INSTALL_DIR/bin/"*; do
    if [ -f "$bin_file" ]; then
        sudo ln -vsf "$bin_file" "/usr/local/bin/$(basename "$bin_file")"
    fi
done

# --- Limpieza total del entorno de trabajo ---
cd /
rm -rf "$WORK_DIR"

echo "===> $SOURCE_CODE_FILE compilado e instalado con éxito."
EOF

	sudo chmod +x /usr/local/bin/installer-nmap
	/usr/local/bin/installer-nmap
}

### Brave Web Browser
_brave()
{
    curl -fsS https://dl.brave.com/install.sh | sh
}

### STEAM
_steam()
{
	sudo dpkg --add-architecture i386
	sudo apt update
	sudo apt install -y steam-installer
	sudo apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
}

_wine_hq()
{
	sudo mkdir -pm755 /etc/apt/keyrings
	wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
	sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/resolute/winehq-resolute.sources
	sudo dpkg --add-architecture i386
	sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$(lsb_release -sc)/winehq-$(lsb_release -sc).sources
	sudo apt update
	sudo apt install --install-recommends -y winehq-devel
	sudo apt install winetricks -y
	
	export WINEPREFIX="$HOME/.wine_autocad2008"
	export WINEARCH=win32
	winecfg /v winxp
	WINEPREFIX="$HOME/.wine_autocad2008" WINEARCH=win32 winetricks -q dotnet20 gdiplus msxml3 msxml6 vcrun2005 d3dx9 corefonts ie8
	
	#WINEPREFIX="$HOME/.wine_autocad2008" WINEARCH=win32 wine "/home/tomas/Documentos/AutoCAD2008/AutoCAD2008/AutoCAD2008InstallationFolderISO/x86/Setup.exe"
	
	#
}

_virtual_box_7.2()
{
	wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
	cat <<EOF | sudo tee /etc/apt/sources.list.d/vbox.sources > /dev/null
Types: deb
URIs: https://download.virtualbox.org/virtualbox/debian
Suites: $(lsb_release -cs)
Components: contrib
Architectures: amd64
Signed-By: /usr/share/keyrings/oracle-virtualbox-2016.gpg
EOF
	sudo apt update
	sudo apt install --install-recommends -y virtualbox-7.2 linux-headers-amd64 linux-headers-$(uname -r)
}

_audacity()
{
	cat <<"EOF" | sudo tee /usr/local/bin/installer-audacity > /dev/null
#!/bin/bash

DEST_PATH="/usr/local/bin/audacity"
API_URL="https://api.github.com/repos/audacity/audacity/releases/latest"

# Extraer específicamente la URL del archivo x86_64.AppImage
DOWNLOAD_URL=$(curl -s "$API_URL" | grep -oP '"browser_download_url":\s*"\K([^"]*x86_64\.AppImage)(?=")')

if [ -z "$DOWNLOAD_URL" ]; then
	echo "Error: No se localizó el archivo x86_64.AppImage en la última versión estable." >&2
	exit 1
fi

echo "Descargando: $DOWNLOAD_URL"

if sudo curl -L "$DOWNLOAD_URL" -o "$DEST_PATH"; then
	sudo chmod +x "$DEST_PATH"
	echo "Éxito: Instalado en $DEST_PATH"
else
	echo "Error: Falló la descarga." >&2
	exit 1
fi
	
cat <<"EOF_DESKTOP" | sudo tee /usr/share/applications/audacity.desktop > /dev/null
[Desktop Entry]
Name=Audacity
Exec=/usr/local/bin/audacity %F
Icon=audacity
Type=Application
Categories=AudioVideo;Audio;AudioVideoEditing;
Terminal=false
EOF_DESKTOP

sudo curl -L "https://github.com/audacity.png" -o /usr/share/pixmaps/audacity.png
EOF

	sudo chmod +x /usr/local/bin/installer-audacity
	/usr/local/bin/installer-audacity
}

### configuracion basica inicial para Debian 13 GNU/Linux.
_basic_setup()
{
	### ponemos numero de lineas para nano.
	sudo cp -v /etc/nanorc /etc/nanorc.original
 	echo "set linenumbers" | sudo tee -a /etc/nanorc

	### este alias permite borrar completamente todo lo que hay descargado en listas APT.
	cat <<"EOF" | sudo tee /usr/local/bin/clear-apt > /dev/null
#!/bin/bash
sudo apt autoclean
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt clean
EOF

    sudo chmod +x /usr/local/bin/clear-apt
    
    ### evitamos la instalacion de paquetes recomendados o no esenciales.
    cat <<"EOF" | sudo tee /etc/apt/apt.conf.d/99norecommends > /dev/null
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

	### instalamos stubby y lo usamos.
    _stubby

    ### BEST SOURCES LIST FILES EVER, REALLY. $(lsb_release -cs)
	cat <<EOF | sudo tee /etc/apt/sources.list.d/debian.sources > /dev/null
Types: deb deb-src
URIs: https://deb.debian.org/debian/
Suites: $(lsb_release -cs) $(lsb_release -cs)-updates
Components: main contrib non-free non-free-firmware
#Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: https://security.debian.org/debian-security
Suites: $(lsb_release -cs)-security
Components: main contrib non-free non-free-firmware
#Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

    if [ -f /etc/apt/sources.list ]; then
        sudo mv -v /etc/apt/sources.list /etc/apt/.sources.list.original
        sudo rm -vf /etc/apt/sources.list~
    fi

    ### actualizamos APT con los nuevos repositorios oficiales de Debian.
    sudo apt autoclean
    sudo apt clean
    sudo rm -vrf /var/lib/apt/lists/*
    sudo apt clean
	
	### instalamos y activamos el cliente NTP de systemd.
	sudo apt update
    sudo apt install -y systemd-timesyncd
    sudo systemctl enable --now systemd-timesyncd

	### configuramos una buena fuente para consultar la hora via NTP del systemd.
    sudo cp -v /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.original
	cat <<"EOF" | sudo tee /etc/systemd/timesyncd.conf > /dev/null
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
FallbackNTP=time.cloudflare.com
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
ConnectionRetrySec=30
SaveIntervalSec=60
EOF

	sudo timedatectl set-local-rtc 0
	sudo timedatectl set-timezone America/Argentina/Buenos_Aires
	sudo systemctl restart systemd-timesyncd

    ### BASIC PACKAGES TO GET LETS START.
	sudo apt update
	sudo apt install -y "${ESSENTIAL_PACKAGES[@]}"

    cat <<"EOF" | sudo tee /usr/local/bin/installer-fastfetch > /dev/null
#!/bin/sh
wget "https://github.com/fastfetch-cli/fastfetch/releases/download/$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | jq -r .tag_name)/fastfetch-linux-amd64.deb"
sudo apt install -y ./fastfetch-linux-amd64.deb
rm -vf ./fastfetch-linux-amd64.deb
EOF
	sudo chmod +x /usr/local/bin/installer-fastfetch
	/usr/local/bin/installer-fastfetch
	
	#sudo apt update
	#sudo apt install --no-install-recommends gnome-core
    
    _nmap
    
    _ytdlp

}

### instala paquetes y software para el escritorio de Debian GNOME.
_debian_desktop()
{
	### OFFICIAL DEBIAN PACKAGES
	sudo apt update
    sudo apt install --install-recommends -y "${PACKAGES[@]}"
    
    _audacity
    
    _visual_studio_code
    
    _wireshark

    ### Liquorix kernel, ideal for gaming, a/v live production.
    #curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

    #_steam

    _brave

    #_virtual_box_7.2
    
    _sox_ng
    
    _flatpak
    
    #_wired_for_war
    
    _ffmpeg_master_latest

    #_wine_hq
}

_cookie_fortune()
{
	## https://stackoverflow.com/questions/414164/how-can-i-select-random-files-from-a-directory-in-bash
	sudo apt update
    sudo apt install -y cowsay fortunes
	cat <<"EOF" | sudo tee /usr/local/bin/cookie-fortune > /dev/null
#!/bin/sh
COWS=(/usr/share/cowsay/cows/*.cow)
CHARACTER_PATH="${COWS[RANDOM % ${#COWS[@]}]}"
CHARACTER=$(basename "$CHARACTER_PATH" .cow)
fortune -s | cowsay -f "$CHARACTER"
EOF

	sudo rm -vf /usr/share/applications/fortune.desktop
    sudo chmod 755 /usr/local/bin/cookie-fortune
    /usr/local/bin/cookie-fortune
}

_basic_setup
_debian_desktop
_cookie_fortune
