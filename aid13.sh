#!/bin/bash

set -euo pipefail

# Validar instalación de whiptail
if ! command -v whiptail &> /dev/null; then
    echo "Error: whiptail no está instalado. Ejecuta 'sudo apt install whiptail'."
    exit 1
fi

# Solicitar credenciales sudo al inicio y mantener vivo el token en segundo plano
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

ESSENTIAL_PACKAGES=(
    # Compilación, Toolchains C/C++ y Build Systems
    build-essential gcc g++ make cmake ninja-build autoconf automake pkg-config binutils linux-headers-$(uname -r) dkms

    # Ensamblador, Depuración y LLVM
    nasm yasm gdb lldb llvm clang

    # Control de Versiones, Búsqueda y Descargas
    git git-lfs curl wget jq ripgrep fd-find rsync

    # Python: Entorno Base, Desarrollo y Web Scraping
    python3-full python3-pip python3-venv python3-dev python-is-python3 python-dev-is-python3
    python3-requests python3-bs4 python3-lxml python3-scrapy python3-httpx python3-selenium python3-urllib3
    python3-scapy

    # Cabeceras C/C++ y Criptografía para Desarrollo
    libxml2-dev libxslt1-dev libffi-dev libssl-dev zlib1g-dev libsqlite3-dev libpcap-dev

    # Java OpenJDK y Build Tools
    default-jdk openjdk-21-jdk openjdk-25-jdk maven gradle

    # Lenguajes y Ecosistemas: Node.js, Go y Rust
    nodejs npm golang rust-all cargo rustc

    # Servidores Web, PHP y Desarrollo Backend Local
    php-cli php-curl php-mbstring php-xml php-sqlite3 php-pgsql nginx

    # Navegadores y Web Drivers (Scraping Dinámico y QA)
    chromium chromium-shell chromium-driver firefox-esr

    # Bases de Datos y Motores de Almacenamiento
    postgresql-17 postgresql-client sqlite3 redis-server

    # Redes, Diagnóstico y VPN
    dnsutils ipcalc socat tcpdump wireguard openvpn conntrack

    # Sistema, Hardware, Móviles y Gestión Térmica/Energía
    firmware-linux-nonfree memtest86+ smartmontools tlp adb fastboot

    # Monitoreo, Multiplexores y Utilidades de Terminal
    htop bmon tmux screen tree minicom nano man zbar-tools lynx ascii

    # Archivos, Compresión y Sistema de Archivos
    tar zip unzip 7zip 7zip-rar rar unrar

    # Contenedores y Virtualización
    docker.io docker-compose

    # Multimedia, Fuentes y Sistema Base
    ffmpeg flac libavcodec-extra imagemagick
    ca-certificates gpg fonts-noto-color-emoji ttf-mscorefonts-installer locales-all lsb-release
)

PACKAGES=(
    flatpak vlc foliate mixxx picard geany putty strawberry
)

### FUNCIONES DE INSTALACIÓN Y CONFIGURACIÓN ###

_flatpak()
{
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
        com.vscodium.codium

    sudo ln -vsf /var/lib/flatpak/exports/bin/cc.spek.Spek /usr/local/bin/spek
    sudo ln -vsf /var/lib/flatpak/exports/bin/com.vscodium.codium /usr/local/bin/codium

    flatpak update -y
}

_google_chrome()
{
    local tmp_deb="/tmp/google-chrome-stable_current_amd64.deb"
    echo "Descargando Google Chrome..."
    if wget --quiet --show-progress --https-only --inet4-only -O "$tmp_deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
        echo "Instalando Google Chrome..."
        sudo apt install -y "$tmp_deb"
        rm -v "$tmp_deb"
    else
        echo "Error: Falló la descarga de Google Chrome." >&2
        return 1
    fi
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
}

_ia()
{
    cat <<"EOF" | sudo tee /usr/local/bin/installer-opencode > /dev/null
#!/bin/bash
curl -fsSL https://opencode.ai/v2/install | bash
EOF

    sudo chmod +x /usr/local/bin/installer-opencode
    /usr/local/bin/installer-opencode

    cat <<"EOF" | sudo tee /usr/local/bin/installer-ollama > /dev/null
#!/bin/bash
curl -fsSL https://ollama.com/install.sh | sh
EOF

    sudo chmod +x /usr/local/bin/installer-ollama
    /usr/local/bin/installer-ollama
    
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    cat <<"EOF" | sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null
[Service]
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_KEEP_ALIVE=5m"
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart ollama

    local modelos=(
        "qwen2.5-coder:7b"
        "deepseek-r1:8b"
        "gemma4:e2b"
        "gemma4:e4b"
        "granite4.2:3b"
        "granite4.2:8b"
    )

    for modelo in "${modelos[@]}"; do
        ollama pull "$modelo"
    done

    for modelo in "${modelos[@]}"; do
        cat <<EOF > /tmp/Modelfile.opt
FROM $modelo
PARAMETER num_ctx 4096
EOF
        ollama create "${modelo}-4k" -f /tmp/Modelfile.opt
    done
    rm -f /tmp/Modelfile.opt
}

_ytdlp()
{
    curl -fsSL https://deno.land/install.sh | sh
    sudo apt remove -y yt-dlp || true
    local bin_dir="${HOME}/.local/bin"
    mkdir -vp "${bin_dir}"
    wget -q --show-progress https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O "${bin_dir}/yt-dlp"
    chmod +x "${bin_dir}/yt-dlp"
    sudo ln -vsf "${bin_dir}/yt-dlp" /usr/local/bin/yt-dlp
}

_sqlmap()
{
    local target_dir="${HOME}/.local/share/sqlmap-dev"
    local bin_dir="${HOME}/.local/bin"
    local tmp_dir="/tmp/sqlmap-dev"

    rm -rf "${tmp_dir}"
    if git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git "${tmp_dir}"; then
        rm -rf "${target_dir}"
        mv "${tmp_dir}" "${target_dir}"
        mkdir -p "${bin_dir}"
        ln -sf "${target_dir}/sqlmap.py" "${bin_dir}/sqlmap"
        chmod +x "${target_dir}/sqlmap.py"
        echo "sqlmap actualizado correctamente."
    else
        echo "Error: Falló la descarga del repositorio." >&2
        return 1
    fi
}

_wired_for_war()
{
    flatpak install -y --user https://wiredforwar.github.io/flatpak/wiredforwar-machines.flatpakref
    mkdir -p ~/.var/app/io.github.wiredforwar.machines/downloads
    cd ~/.var/app/io.github.wiredforwar.machines/downloads
    wget https://download.wiredforwar.org/Game/Community-Build-1.5/machines-assets.7z
    7z x machines-assets.7z -o../data
    cd ~
    flatpak update -y io.github.wiredforwar.machines
}

_sox_ng()
{
    cat << "EOF" | sudo tee /usr/local/bin/installer-sox-ng > /dev/null
#!/bin/bash
set -e

if [ -d "$HOME/.sox_ng_compiled" ]; then
    echo "Detectada compilación previa en $HOME/.sox_ng_compiled. Desinstalando..."
    cd "$HOME/.sox_ng_compiled" || exit 1
    if [ -f "Makefile" ]; then
        sudo make uninstall
    fi
    cd "$HOME" || exit 1
    rm -rf "$HOME/.sox_ng_compiled"
fi

sudo rm -vf /usr/local/bin/sox /usr/local/bin/soxi /usr/local/bin/play /usr/local/bin/rec
sudo rm -vf /usr/local/bin/sox_ng /usr/local/bin/soxi_ng /usr/local/bin/play_ng /usr/local/bin/rec_ng

sudo apt update
sudo apt install -y build-essential autoconf automake \
    gcc make libtool ladspa-sdk libao-dev libasound2-dev libfftw3-dev \
    libgsm1-dev libid3tag0-dev libltdl-dev libmad0-dev libmagic-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev \
    libopusfile-dev libpng-dev libpulse-dev \
    libsndfile1-dev libspeex-dev libspeexdsp-dev libtwolame-dev \
    libvorbis-dev libwavpack-dev

cd "$HOME" || exit 1
rm -rf "$HOME/sox_ng"
rm -rf "$HOME/.sox_ng_compiled"
    
TAG=$(curl -s https://codeberg.org/api/v1/repos/sox_ng/sox_ng/releases/latest | jq -r .tag_name)
if [ -z "$TAG" ] || [ "$TAG" = "null" ]; then
    echo "Error crítico: No se pudo obtener la última versión de sox_ng desde Codeberg."
    exit 1
fi

git clone --branch "$TAG" --depth 1 https://codeberg.org/sox_ng/sox_ng.git
cd "$HOME/sox_ng" || exit 1
autoreconf -i
./configure
make
sudo make install
sudo ldconfig

cd "$HOME" || exit 1
mv -v sox_ng .sox_ng_compiled
echo "Instalación de sox_ng ($TAG) completada exitosamente."
EOF
    sudo chmod +x /usr/local/bin/installer-sox-ng
    /usr/local/bin/installer-sox-ng
}

_ffmpeg_master_latest()
{
    cat << "EOF" | sudo tee /usr/local/bin/installer-ffmpeg-master-latest > /dev/null
#!/bin/bash
FILE="ffmpeg-master-latest-linux64-gpl.tar.xz"
URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/$FILE"
EXTRACTED_DIR="ffmpeg-master-latest-linux64-gpl"
TMP_DIR="/tmp/ffmpeg_install"

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
sudo chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe /usr/local/bin/ffplay 2>/dev/null

cd /
rm -rf "$TMP_DIR"
hash -r
ffmpeg -version | head -n 1
EOF
    sudo chmod +x /usr/local/bin/installer-ffmpeg-master-latest
    /usr/local/bin/installer-ffmpeg-master-latest
}

_dnscryptproxy()
{
    sudo rm -vrf /etc/dnscrypt-proxy/
    sudo apt update
    sudo apt install -y -o Dpkg::Options::="--force-confmiss" --reinstall dnscrypt-proxy
    sudo systemctl stop dnscrypt-proxy.socket dnscrypt-proxy.service

    local CONF="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    sudo cp -v "$CONF" "$CONF".original
    sudo sed -i 's/^[# ]*server_names =.*/server_names = []/' "$CONF"
    
    _set_param() {
        sudo sed -i "/^[# ]*$1 =/d" "$CONF"
        sudo sed -i "/^server_names = \[\]/a $1 = $2" "$CONF"
    }

    _set_param "cache" "false"
    _set_param "block_ipv6" "true"
    _set_param "force_tcp" "true"
    _set_param "odoh_servers" "false"
    _set_param "doh_servers" "true"
    _set_param "dnscrypt_servers" "false"
    _set_param "ipv6_servers" "false"
    _set_param "ipv4_servers" "true"
    _set_param "lb_estimator" "true"
    _set_param "lb_strategy" "'wp2'"
    _set_param "keepalive" "30"
    _set_param "timeout" "5000"
    _set_param "http3" "false"
    _set_param "require_nofilter" "true"
    _set_param "require_nolog" "true"
    _set_param "require_dnssec" "true"
    
    if ! grep -q "v3/public-resolvers.md" "$CONF"; then
        sudo sed -i "s|^[# ]*url = 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md'.*|urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md', 'https://cdn.jsdelivr.net/gh/DNSCrypt/dnscrypt-resolvers@master/v3/public-resolvers.md']|" "$CONF"
    fi

    sudo systemctl restart dnscrypt-proxy.socket dnscrypt-proxy.service
    
    if command -v nmcli &> /dev/null; then
        local ACTIVE_CONN
        ACTIVE_CONN=$(nmcli -t -f NAME connection show --active | head -n 1)
        if [ -n "$ACTIVE_CONN" ]; then
            sudo nmcli connection modify "$ACTIVE_CONN" ipv4.dns "127.0.2.1"
            sudo nmcli connection modify "$ACTIVE_CONN" ipv4.ignore-auto-dns yes
            sudo nmcli connection modify "$ACTIVE_CONN" ipv6.method "disabled"
            sudo nmcli connection up "$ACTIVE_CONN"
        fi
        
        sudo mkdir -p /etc/NetworkManager/conf.d
        cat <<EOF | sudo tee /etc/NetworkManager/conf.d/dns.conf > /dev/null
[main]
dns=none
EOF
        sudo systemctl reload NetworkManager || true
    else
        echo "Aviso: NetworkManager no está instalado. Saltando configuración de nmcli."
    fi
    sudo /usr/bin/chattr -i /etc/resolv.conf
    cat <<"EOF" | sudo tee /etc/resolv.conf > /dev/null
nameserver 127.0.2.1
options edns0 single-request-reopen
EOF
    sudo /usr/bin/chattr +i /etc/resolv.conf
}

_nmap()
{
    cat <<"EOF" | sudo tee /usr/local/bin/installer-nmap > /dev/null
#!/bin/bash
set -e
INSTALL_DIR="/usr/local/nmap-suite"
SOURCE_CODE_FILE=$(curl -sL https://nmap.org/download.html | grep -oP 'nmap-\d+(\.\d+)+\.tar\.bz2' | head -n 1)

if [ -z "$SOURCE_CODE_FILE" ]; then
    echo "Error: No se pudo obtener el archivo nmap.org." >&2
    exit 1
fi

URL="https://nmap.org/dist/$SOURCE_CODE_FILE"
sudo apt purge -y nmap nmap-common zenmap ndiff || true
[ -d "$INSTALL_DIR" ] && sudo rm -rf "$INSTALL_DIR"
sudo rm -f /usr/bin/{nmap,ncat,nping,zenmap,ndiff} /usr/local/bin/{nmap,ncat,nping,zenmap,ndiff}

WORK_DIR=$(mktemp -d)
cd "$WORK_DIR" || exit 1
sudo apt update
sudo apt build-dep -y nmap
sudo mkdir -p -v "$INSTALL_DIR"

wget --inet4-only --https-only --show-progress -q "$URL" -O "$SOURCE_CODE_FILE"
tar xjf "$SOURCE_CODE_FILE"
rm -f "$SOURCE_CODE_FILE"
EXTRACTED_DIR="${SOURCE_CODE_FILE%.tar.bz2}"

cd "$EXTRACTED_DIR" || exit 1
./configure --quiet --prefix="$INSTALL_DIR" --without-zenmap --without-nping --without-ncat --without-ndiff
make -j"$(nproc)"
sudo make install

for bin_file in "$INSTALL_DIR/bin/"*; do
    if [ -f "$bin_file" ]; then
        sudo ln -vsf "$bin_file" "/usr/local/bin/$(basename "$bin_file")"
    fi
done

cd /
rm -rf "$WORK_DIR"
EOF
    sudo chmod +x /usr/local/bin/installer-nmap
    /usr/local/bin/installer-nmap
}

_go()
{
    cat <<"EOF" | sudo tee /usr/local/bin/installer-go > /dev/null
#!/bin/bash
ARCH="amd64"
OS="linux"
GO_URL_BASE="https://go.dev/dl"
LATEST_VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | head -n 1)
FILE="$LATEST_VERSION.$OS-$ARCH.tar.gz"
URL="$GO_URL_BASE/$FILE"
TMP_DIR="/tmp"

if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress "$URL" -O "$TMP_DIR/$FILE"
    sudo rm -rf /usr/local/go
    sudo apt purge -y golang-go golang-src golang-doc 2>/dev/null || true
    sudo apt autoremove -y 2>/dev/null || true
    sudo tar -C /usr/local -xzf "$TMP_DIR/$FILE"
    rm -f "$TMP_DIR/$FILE"
    
    if ! grep -q "/usr/local/go/bin" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
    fi
    echo "Go $LATEST_VERSION installed successfully!"
else
    exit 1
fi
EOF
    sudo chmod +x /usr/local/bin/installer-go
    /usr/local/bin/installer-go
}

_rust()
{
    curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh
}

_ivpn()
{
    curl -fsSL https://repo.ivpn.net/stable/debian/generic.gpg | gpg --dearmor > ~/ivpn-archive-keyring.gpg
    sudo mv ~/ivpn-archive-keyring.gpg /usr/share/keyrings/ivpn-archive-keyring.gpg
    sudo chown root:root /usr/share/keyrings/ivpn-archive-keyring.gpg
    sudo chmod 644 /usr/share/keyrings/ivpn-archive-keyring.gpg
    curl -fsSL https://repo.ivpn.net/stable/debian/generic.list | sudo tee /etc/apt/sources.list.d/ivpn.list
    sudo chown root:root /etc/apt/sources.list.d/ivpn.list
    sudo chmod 644 /etc/apt/sources.list.d/ivpn.list
    sudo apt update
    sudo apt install -y ivpn-ui
    sudo systemctl stop ivpn-service.service
    sudo systemctl disable ivpn-service.service
}

_protonvpn()
{
    local REPO_URL="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/"
    local LATEST_DEB=$(curl -sL "$REPO_URL" | grep -oE 'protonvpn-stable-release_[0-9.]+_all\.deb' | sort -V | tail -n 1)

    if [ -z "$LATEST_DEB" ]; then return 1; fi
    wget "${REPO_URL}${LATEST_DEB}"
    sudo apt install -y "./${LATEST_DEB}"
    rm -vf "./${LATEST_DEB}"
    sudo apt update
    sudo apt install -y proton-vpn-gnome-desktop gnome-shell-extension-appindicator gnome-shell-extension-prefs
}

_brave()
{
    curl -fsS https://dl.brave.com/install.sh | sh
}

_steam()
{
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y steam-installer
    sudo apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
    sudo chown -R $USER:$USER $HOME
}

_weechat()
{
    sudo mkdir -p /etc/apt/keyrings
    curl --silent https://weechat.org/dev/info/debian_repository_signing_key_asc/ | sudo tee /etc/apt/keyrings/weechat.asc
    cat <<EOF | sudo tee /etc/apt/sources.list.d/weechat.sources > /dev/null
Types: deb
URIs: https://weechat.org/debian
Suites: $(lsb_release -cs)
Components: main
Architectures: amd64 i386 arm64 armhf
Signed-By: /etc/apt/keyrings/weechat.asc
EOF
    sudo apt update
    sudo apt install -y weechat-curses weechat-plugins weechat-python weechat-perl
}

_tor_browser()
{
    cat <<"EOF" | sudo tee /usr/local/bin/installer-tor-browser > /dev/null
#!/bin/bash
BASE_URL="https://dist.torproject.org/torbrowser"
LATEST_VERSION=$(curl -s "${BASE_URL}/" | grep -Eo 'href="[0-9]+\.[0-9]+\.[0-9]+/"' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)

if [ -z "$LATEST_VERSION" ]; then exit 1; fi

FILE_NAME="tor-browser-linux-x86_64-${LATEST_VERSION}.tar.xz"
DOWNLOAD_URL="${BASE_URL}/${LATEST_VERSION}/${FILE_NAME}"

if wget --inet4-only --https-only --quiet --spider "$DOWNLOAD_URL"; then
    wget --inet4-only --https-only --show-progress -q "$DOWNLOAD_URL" -O "$FILE_NAME"
    tar xf "$FILE_NAME"
    mv -v tor-browser/ ~/.local/
    rm -vf "$FILE_NAME"
fi
EOF
    sudo chmod +x /usr/local/bin/installer-tor-browser
    /usr/local/bin/installer-tor-browser
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
    echo -e "blacklist kvm\nblacklist kvm_intel\nblacklist kvm_amd" | sudo tee /etc/modprobe.d/kvm-blacklist.conf
    sudo modprobe -r kvm_intel kvm_amd kvm
}

_tor()
{
    sudo apt update
    sudo apt install -y wget gnupg
    cat <<EOF | sudo tee /etc/apt/sources.list.d/tor.sources > /dev/null
Types: deb
URIs: https://deb.torproject.org/torproject.org/
Suites: $(lsb_release -cs)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/deb.torproject.org-keyring.gpg
EOF
    wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
    sudo apt update
    sudo apt install -y tor deb.torproject.org-keyring
    sudo systemctl stop tor
    sudo systemctl disable tor
}

_audacity()
{
    cat <<"EOF" | sudo tee /usr/local/bin/installer-audacity > /dev/null
#!/bin/bash
DEST_PATH="/usr/local/bin/audacity"
API_URL="https://api.github.com/repos/audacity/audacity/releases/latest"
DOWNLOAD_URL=$(curl -s "$API_URL" | grep -oP '"browser_download_url":\s*"\K([^"]*x86_64\.AppImage)(?=")')

if [ -z "$DOWNLOAD_URL" ]; then exit 1; fi

if sudo curl -L "$DOWNLOAD_URL" -o "$DEST_PATH"; then
    sudo chmod +x "$DEST_PATH"
else
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

_ventoy()
{
    cat <<"EOF" | sudo tee /usr/local/bin/installer-ventoy > /dev/null
#!/bin/bash
set -e
API_URL="https://api.github.com/repos/ventoy/Ventoy/releases/latest"
TARGET_DIR="$HOME/.local"
DOWNLOAD_URL=$(curl -s "$API_URL" | grep "browser_download_url.*linux\.tar\.gz" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then exit 1; fi

FILE_NAME=$(basename "$DOWNLOAD_URL")
DIR_NAME="${FILE_NAME%.tar.gz}"
FINAL_PATH="$TARGET_DIR/$DIR_NAME"
TMP_DOWNLOAD="/tmp/$FILE_NAME"

wget -q --show-progress "$DOWNLOAD_URL" -O "$TMP_DOWNLOAD"
mkdir -p "$TARGET_DIR"
find "$TARGET_DIR" -maxdepth 1 -name "ventoy-*" -type d -exec rm -rf {} +
tar -xzf "$TMP_DOWNLOAD" -C "$TARGET_DIR"
rm -f "$TMP_DOWNLOAD"
EOF
    sudo chmod +x /usr/local/bin/installer-ventoy
}

_capturas()
{
    sudo apt update
    sudo apt install -y scrot xclip
    mkdir -vp "$HOME/Imágenes/Capturas de pantalla"
    cat << "EOF" | sudo tee /usr/local/bin/capturas > /dev/null
#!/bin/bash
ARCHIVO="$HOME/Imágenes/Capturas de pantalla/$(date +'%Y-%m-%d-%H%M%S_pantalla.png')"
scrot "$ARCHIVO" -e 'xclip -selection clipboard -t image/png < "$f"'
EOF
    sudo chmod +x /usr/local/bin/capturas
}

_setup_nano()
{
    sudo cp -v /etc/nanorc /etc/nanorc.original
    echo "set linenumbers" | sudo tee -a /etc/nanorc
}

_setup_clear_apt()
{
    cat <<"EOF" | sudo tee /usr/local/bin/clear-apt > /dev/null
#!/bin/bash
sudo apt autoclean
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt clean
EOF
    sudo chmod +x /usr/local/bin/clear-apt
}

_setup_no_recommends()
{
    cat <<"EOF" | sudo tee /etc/apt/apt.conf.d/99norecommends > /dev/null
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
}

_setup_grub()
{
    ARCHIVO_GRUB="/etc/default/grub"
    ARCHIVO_RESPALDO="/etc/default/grub.original"
    sudo cp -v "$ARCHIVO_GRUB" "$ARCHIVO_RESPALDO"
    ORIGINAL_CMDLINE=$(sed -n "s/^GRUB_CMDLINE_LINUX_DEFAULT=['\"]\(.*\)['\"]$/\1/p" /etc/default/grub)
    HARDENING="ipv6.disable=1 init_on_alloc=1 init_on_free=1 slab_nomerge page_alloc.shuffle=1 randomize_kstack_offset=on intel_iommu=on iommu=pt"
    GRUB_CMDLINE_LINUX_DEFAULT="$ORIGINAL_CMDLINE $HARDENING"
    sudo tee /etc/default/grub.d/99-hardening.cfg > /dev/null <<EOF
GRUB_TIMEOUT=10
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT"
GRUB_DISABLE_OS_PROBER=true
EOF
    sudo /usr/sbin/update-grub
}

_setup_no_ipv6()
{
    cat <<EOF | sudo tee /etc/sysctl.d/99-disable-ipv6.conf > /dev/null
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
    sudo sysctl --system
}

_setup_kernel_hardering()
{
    cat <<EOF | sudo tee /etc/sysctl.d/99-security.conf > /dev/null
kernel.unprivileged_userns_clone = 1    
kernel.unprivileged_bpf_disabled = 1
net.core.bpf_jit_harden = 2
kernel.yama.ptrace_scope = 1
fs.protected_symlinks = 1
fs.protected_hardlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
EOF
    sudo sysctl --system
}

_setup_apt_sources()
{
    cat <<EOF | sudo tee /etc/apt/sources.list.d/debian.sources > /dev/null
Types: deb deb-src
URIs: https://deb.debian.org/debian/
Suites: $(lsb_release -cs) $(lsb_release -cs)-updates
Components: main contrib non-free non-free-firmware
Architectures: amd64
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp

Types: deb deb-src
URIs: https://security.debian.org/debian-security
Suites: $(lsb_release -cs)-security
Components: main contrib non-free non-free-firmware
Architectures: amd64
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp
EOF
    if [ -f /etc/apt/sources.list ]; then
        sudo mv -v /etc/apt/sources.list /etc/apt/.sources.list.original
        sudo rm -vf /etc/apt/sources.list~
    fi
    sudo apt autoclean
    sudo apt clean
    sudo rm -vrf /var/lib/apt/lists/*
    sudo apt clean
    sudo apt update
}

_setup_hora_utc()
{
    HTTP_DATE=$(curl -s --head http://google.com | grep -i '^date:' | sed 's/[Dd]ate: //g' || wget -qS --spider http://google.com 2>&1 | grep -i 'date:' | sed 's/.*[Dd]ate: //g')
    if [ -n "$HTTP_DATE" ]; then
        sudo date -u -s "$HTTP_DATE"
    else
        sudo hwclock --hctosys --utc
    fi
    sudo apt update
    sudo apt install -y systemd-timesyncd
    sudo systemctl enable --now systemd-timesyncd
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
    sudo timedatectl set-timezone UTC
    sudo systemctl restart systemd-timesyncd
}

_setup_hora_argentina()
{
    sudo timedatectl set-local-rtc 0
    sudo timedatectl set-timezone America/Argentina/Buenos_Aires
    sudo systemctl restart systemd-timesyncd
}

_setup_basic_packages()
{
    sudo apt update
    sudo apt install -y "${ESSENTIAL_PACKAGES[@]}"
    sudo systemctl disable --now docker.service docker.socket postgresql redis-server nginx || true
    sudo systemctl stop docker.service docker.socket postgresql redis-server nginx || true
}

_setup_desktop_packages()
{
    sudo apt update
    sudo apt install --install-recommends -y "${PACKAGES[@]}"
}

_liquorix_kernel()
{
    curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
}

_setup_bateria_tlp()
{
    sudo apt update
    sudo apt install -y tlp
    cat <<EOF | sudo tee /etc/tlp.conf > /dev/null
START_CHARGE_THRESH_BAT0=40
STOP_CHARGE_THRESH_BAT0=80
EOF
    sudo systemctl enable --now tlp
}

_setup_zram_and_swap()
{
    sudo apt update
    sudo apt install -y zram-tools
    cat <<EOF | sudo tee /etc/default/zramswap > /dev/null
ALGO=zstd
PERCENT=25
EOF
    cat <<EOF | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null
vm.swappiness=80
vm.page-cluster=0
EOF
}

_github_fastfetch()
{
    cat <<"EOF" | sudo tee /usr/local/bin/installer-fastfetch > /dev/null
#!/bin/bash
cd /tmp
wget -q --show-progress "https://github.com/fastfetch-cli/fastfetch/releases/download/$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | jq -r .tag_name)/fastfetch-linux-amd64.deb"
sudo apt install -y ./fastfetch-linux-amd64.deb
rm -vf ./fastfetch-linux-amd64.deb
cd - > /dev/null
EOF
    sudo chmod +x /usr/local/bin/installer-fastfetch
    /usr/local/bin/installer-fastfetch
}

_cookie_fortune()
{
    sudo apt update
    sudo apt install -y cowsay fortune-mod fortunes
    cat <<"EOF" | sudo tee /usr/local/bin/cookie-fortune > /dev/null
#!/bin/bash
COWS=(/usr/share/cowsay/cows/*.cow)
CHARACTER_PATH="${COWS[RANDOM % ${#COWS[@]}]}"
CHARACTER=$(basename "$CHARACTER_PATH" .cow)
fortune -s | cowsay -f "$CHARACTER"
EOF
    sudo rm -vf /usr/share/applications/fortune.desktop
    sudo chmod 755 /usr/local/bin/cookie-fortune
    /usr/local/bin/cookie-fortune
}

### MENÚ INTERACTIVO TUI CON WHIPTAIL ###

MENU_OPTIONS=(
    "setup_nano" "Configurar Nano (Líneas)" ON
    "setup_clear_apt" "Script clear-apt" ON
    "setup_no_recommends" "APT sin recomendados" ON
    "setup_apt_sources" "Configurar sources.list" ON
    "setup_grub" "Hardening de GRUB" OFF
    "setup_no_ipv6" "Deshabilitar IPv6 globalmente" OFF
    "setup_kernel_hardering" "Hardening Kernel y Red" OFF
    "setup_hora_utc" "Configurar NTP a UTC" ON
    "setup_hora_argentina" "Configurar NTP a hora Argentina" OFF
    "setup_basic_packages" "Instalar ESSENTIAL_PACKAGES" ON
    "setup_bateria_tlp" "Configurar batería con TLP" OFF
    "setup_zram_and_swap" "Configurar ZRAM y Swap" ON
    "github_fastfetch" "Instalar Fastfetch" ON
    "dnscryptproxy" "Instalar y configurar DNSCrypt" ON
    "ia" "Instalar IA Local y Ollama" OFF
    "go" "Instalar lenguaje Go" OFF
    "rust" "Instalar Rust" OFF
    "nmap" "Compilar e instalar Nmap" OFF
    "tor" "Instalar daemon Tor base" OFF
    "ytdlp" "Instalar yt-dlp" ON
    "sqlmap" "Instalar sqlmap" ON
    "ventoy" "Instalar Ventoy" OFF
    "capturas" "Script Scrot (Capturas)" OFF
    "setup_desktop_packages" "Instalar paquetes de Escritorio" OFF
    "google_chrome" "Instalar Google Chrome" OFF
    "audacity" "Instalar Audacity" OFF
    "visual_studio_code" "Instalar Visual Studio Code" OFF
    "wireshark" "Instalar Wireshark" OFF
    "liquorix_kernel" "Instalar Kernel Liquorix" OFF
    "ivpn" "Instalar IVPN" OFF
    "protonvpn" "Instalar ProtonVPN" OFF
    "steam" "Instalar Steam" OFF
    "weechat" "Instalar WeeChat" OFF
    "brave" "Instalar Brave Browser" OFF
    "tor_browser" "Instalar Tor Browser" OFF
    "virtual_box_7_2" "Instalar VirtualBox 7.2" OFF
    "sox_ng" "Compilar e instalar sox_ng" OFF
    "flatpak" "Instalar Flatpak y Flathubs" OFF
    "wired_for_war" "Instalar Machines: Wired for War" OFF
    "ffmpeg_master_latest" "Instalar FFmpeg Master" ON
    "wine_hq" "Instalar WineHQ" OFF
    "cookie_fortune" "Instalar y ejecutar Cookie Fortune" ON
)

# Interceptamos errores de set -e para que la cancelación del menú no rompa el script
CHOICES=$(whiptail --title "Aprovisionamiento Modular Debian 13" \
--checklist "Selecciona los componentes con ESPACIO, muévete con FLECHAS y confirma con ENTER:" \
25 85 16 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3) || true

if [ -z "$CHOICES" ]; then
    echo "Operación cancelada o sin componentes seleccionados. Saliendo del script."
    exit 0
fi

# Limpiamos las comillas que devuelve whiptail para iterar correctamente
CHOICES=$(echo "$CHOICES" | tr -d '"')

# Bucle de ejecución condicional
for choice in $CHOICES; do
    case $choice in
        setup_nano) _setup_nano ;;
        setup_clear_apt) _setup_clear_apt ;;
        setup_no_recommends) _setup_no_recommends ;;
        setup_apt_sources) _setup_apt_sources ;;
        setup_grub) _setup_grub ;;
        setup_no_ipv6) _setup_no_ipv6 ;;
        setup_kernel_hardering) _setup_kernel_hardering ;;
        setup_hora_utc) _setup_hora_utc ;;
        setup_hora_argentina) _setup_hora_argentina ;;
        setup_basic_packages) _setup_basic_packages ;;
        setup_bateria_tlp) _setup_bateria_tlp ;;
        setup_zram_and_swap) _setup_zram_and_swap ;;
        github_fastfetch) _github_fastfetch ;;
        dnscryptproxy) _dnscryptproxy ;;
        ia) _ia ;;
        go) _go ;;
        rust) _rust ;;
        nmap) _nmap ;;
        tor) _tor ;;
        ytdlp) _ytdlp ;;
        sqlmap) _sqlmap ;;
        ventoy) _ventoy ;;
        capturas) _capturas ;;
        setup_desktop_packages) _setup_desktop_packages ;;
        google_chrome) _google_chrome ;;
        audacity) _audacity ;;
        visual_studio_code) _visual_studio_code ;;
        wireshark) _wireshark ;;
        liquorix_kernel) _liquorix_kernel ;;
        ivpn) _ivpn ;;
        protonvpn) _protonvpn ;;
        steam) _steam ;;
        weechat) _weechat ;;
        brave) _brave ;;
        tor_browser) _tor_browser ;;
        virtual_box_7_2) _virtual_box_7.2 ;;
        sox_ng) _sox_ng ;;
        flatpak) _flatpak ;;
        wired_for_war) _wired_for_war ;;
        ffmpeg_master_latest) _ffmpeg_master_latest ;;
        wine_hq) _wine_hq ;;
        cookie_fortune) _cookie_fortune ;;
    esac
done

echo "=== Configuración finalizada con éxito ==="
