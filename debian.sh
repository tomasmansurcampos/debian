#!/bin/bash

ESSENTIAL_PACKAGES="build-essential dnsutils kpcli man fwupd gnupg gcc gcc-doc nasm gdb python-is-python3 stubby curl wget screen minicom jq git make binutils tcpdump lynx nala lm-sensors fancontrol lsb-release htop bmon locales-all ascii ipcalc sipcalc rar unrar zip unzip p7zip p7zip-full p7zip-rar ffmpeg flac sox libsox-fmt-all"

PACKAGES="libreoffice ttf-mscorefonts-installer keepassxc keepass2 putty bleachbit gnome-disk-utility vlc audacity spek geany"

UNWANTED_PACKAGES="firefox-esr firefox* synaptic smtube qps quassel meteo-qt audacious popularity-contest evolution qbittorrent quodlibet parole exfalso yelp seahorse totem cheese" #malcontent

INTEL_THINGS="intel-microcode iucode-tool *nvidia* firmware-intel* intel-media-va-driver-non-free"

GNOME_THINGS="gnome-games* gnome-weather gnome-software-common gnome-boxes gnome-system-monitor rhythmbox transmission-common gnome-games gnome-clocks zutty gnome-characters debian-reference-common gnome-sound-recorder gnome-connections gnome-music gnome-weather gnome-calculator gnome-calendar gnome-contacts gnome-maps" #gnome-tour libreoffice*

OPENBOX="openbox menu obconf lightdm xfce4-terminal network-manager git kpcli nnn pcmanfm geany"

_flatpak()
{
	#apt purge flatpak -y && rm -vrf /var/lib/flatpak/ && rm -vrf /home/*/.cache/flatpak/ && rm -vrf /home/*/.local/share/flatpak/ && rm -vrf /home/*/.var/app/* && rm -vrf /root/.local/share/flatpak/

	apt update && apt install --reinstall -y flatpak

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

	flatpak --user update -y ## this avoid restart current session nor reboot pc.
	flatpak update -y

	flatpak install -y flathub com.github.tchx84.Flatseal
	flatpak install -y flathub io.github.dosbox-staging
	#flatpak install -y flathub org.keepassxc.KeePassXC
	#flatpak install -y flathub org.mozilla.firefox
	#rm -vrf /usr/bin/firefox
	#ln -vsf /var/lib/flatpak/exports/bin/org.mozilla.firefox /usr/bin/firefox
	#update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200 && update-alternatives --set x-www-browser /usr/bin/firefox
	flatpak install -y flathub io.github.thetumultuousunicornofdarkness.cpu-x
	#flatpak install -y flathub io.missioncenter.MrissionCenter
	#flatpak install -y flathub io.gitlab.librewolf-community
	#flatpak install -y flathub io.github.ungoogled_software.ungoogled_chromium
	#flatpak install -y flathub org.gnome.TextEditor
	#ln -vsf /var/lib/flatpak/app/org.gnome.TextEditor/current/active/export/bin/org.gnome.TextEditor /usr/bin/gedit
	#flatpak install -y flathub com.vscodium.codium
	#ln -vsf /var/lib/flatpak/app/com.vscodium.codium/current/active/export/bin/com.vscodium.codium /usr/bin/code
	#ln -vsf /var/lib/flatpak/app/com.vscodium.codium/current/active/export/bin/com.vscodium.codium /usr/bin/codium
	#ln -vsf /var/lib/flatpak/app/com.vscodium.codium/current/active/export/bin/com.vscodium.codium /usr/bin/vscodium
	#flatpak install -y flathub org.onlyoffice.desktopeditors
	#flatpak install -y flathub org.libreoffice.LibreOffice
	#flatpak install -y flathub org.gimp.GIMP
	#flatpak install -y flathub io.github.peazip.PeaZip
 	flatpak install -y flathub io.github.ungoogled_software.ungoogled_chromium
	flatpak install -y flathub network.loki.Session
	#flatpak install -y flathub io.github.Hexchat
	flatpak install -y flathub org.telegram.desktop
	flatpak install -y flathub com.discordapp.Discord
	#flatpak install -y flathub io.bassi.Amberol
	#flatpak install -y flathub io.freetubeapp.FreeTube
	#flatpak install -y flathub com.spotify.Client
	flatpak install -y flathub org.qbittorrent.qBittorrent
	#flatpak install -y flathub com.warlordsoftwares.youtube-downloader-4ktube
	flatpak install -y flathub org.nicotine_plus.Nicotine
	#flatpak install -y flathub org.mixxx.Mixxx
	#flatpak install -y flathub com.bitwig.BitwigStudio
	#flatpak install -y flathub org.shotcut.Shotcut
	#flatpak install -y flathub com.github.PintaProject.Pinta
	
	flatpak update -y

	#chmod 755 /home/*/.local/share/flatpak
}

_basic_setup()
{
	if [ "$EUID" -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi

	cp -v /root/.bashrc /root/.bashrc.bak
	cat <<"EOF" >> /root/.bashrc # this is IMPORTANT.
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
EOF
	cat <<"EOF" >> /root/.bashrc
alias apt-clean='apt autoclean && apt clean && rm -vrf /var/lib/apt/lists/* && apt clean'
EOF
	source /root/.bashrc

 	cp -v /etc/nanorc /etc/nanorc.bak
 	echo "set linenumbers" >> /etc/nanorc

	mkdir -v -p /opt/apps
	mkdir -v -p /usr/share/bg-wp

	### PURGING SHIT
	#apt purge -y $UNWANTED_PACKAGES $GNOME_THINGS $INTEL_THINGS
	#apt autopurge -y
	
	### Disable Gnome Software from Startup Apps
	#apt remove -y unattended-upgrades
	#mv -v /etc/xdg/autostart/org.gnome.Software.desktop /etc/xdg/autostart/.org.gnome.Software.desktop

	### BEST SOURCES LIST FILES EVER, REALLY. $(lsb_release -cs)
	cat <<EOF > /etc/apt/sources.list.d/debian.sources
Types: deb deb-src
URIs: http://debian.web.trex.fi/debian/
Suites: $(lsb_release -cs) $(lsb_release -cs)-updates $(lsb_release -cs)-backports
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: http://debian.web.trex.fi/debian-security
Suites: $(lsb_release -cs)-security
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
	mv -v /etc/apt/sources.list /etc/apt/.sources.list.bak
	rm -vf /etc/apt/sources.list
	rm -vf /etc/apt/sources.list~
	apt autoclean && apt clean && rm -vrf /var/lib/apt/lists/* && apt clean

	### BASIC PACKAGES TO GET LETS START.
	apt update
	apt install --install-recommends -y $ESSENTIAL_PACKAGES

	### EMACS NOX NO EXIM4 SERVER
	apt update
	apt install --no-install-recommends -y emacs-nox
	
	### CPU
	if wget --inet4-only --https-only --quiet --spider "https://dl.xanmod.org/check_x86-64_psabi.sh"; then
		wget --inet4-only --https-only https://dl.xanmod.org/check_x86-64_psabi.sh -O /usr/bin/check_x86-64_psabi
		chmod 755 /usr/bin/check_x86-64_psabi
		/usr/bin/awk -f /usr/bin/check_x86-64_psabi
	else
		echo "Error https://dl.xanmod.org/check_x86-64_psabi.sh not found." 
	fi

 	### FASTFETCH
    cat <<"EOF" > /usr/bin/installer-fastfetch-cli
#!/bin/bash
URL="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    apt install -y "./$FILE"
	rm -vf "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-fastfetch-cli
	bash /usr/bin/installer-fastfetch-cli
}

_networking()
{
	### DISABLING IPV6
 	### SYSCTL.CONF FILE
	cp -v /etc/sysctl.conf /etc/sysctl.conf.bak
	cat << "EOF" > /etc/sysctl.d/50-noipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
	sysctl -p
 	sysctl --system
	systemctl restart procps.service
	### GRUB
 	cp -v /etc/default/grub /etc/default/grub.bak
 	sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/default/grub
  	sed -i 's/^GRUB_CMDLINE_LINUX=".*"/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
  	/usr/sbin/update-grub
   	### MODULE ANTI IPV6
	echo <<"EOF" > /etc/modprobe.d/disable-ipv6.conf
blacklist ipv6
EOF

	### STUBBY DOT SERVERS CONFIGURATION
	systemctl stop stubby.service
	cp -v /etc/stubby/stubby.yml /etc/stubby/stubby.yml.bak

	### GOOGLE PUBLIC DNS
	cat <<"EOF" > /etc/stubby/stubby.yml.google
### GOOGLE PUBLIC DNS
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
round_robin_upstreams: 0
idle_timeout: 10000
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
#  - address_data: 2001:4860:4860::8888
#    tls_auth_name: "dns.google"
#  - address_data: 2001:4860:4860::8844
#    tls_auth_name: "dns.google"
EOF

	### DNS.SB
	cat <<"EOF" > /etc/stubby/stubby.yml.dns.sb
### DNS.SB
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
round_robin_upstreams: 0
idle_timeout: 10000
tls_min_version: GETDNS_TLS1_3
tls_max_version: GETDNS_TLS1_3
listen_addresses:
  - 127.0.0.3
#  - 0::1
#dnssec: GETDNS_EXTENSION_TRUE
upstream_recursive_servers:
  - address_data: 185.222.222.222
    tls_auth_name: "dot.sb"
    tls_pubkey_pinset:
      - digest: "sha256"
        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
  - address_data: 45.11.45.11
    tls_auth_name: "dot.sb"
    tls_pubkey_pinset:
      - digest: "sha256"
        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
#- address_data: 2a09:0000:0000:0000:0000:0000:0000:0000
#    tls_auth_name: "dot.sb"
#    tls_pubkey_pinset:
#      - digest: "sha256"
#        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
#  - address_data: 2a11:0000:0000:0000:0000:0000:0000:0000
#    tls_auth_name: "dot.sb"
#    tls_pubkey_pinset:
#      - digest: "sha256"
#        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
EOF

	cp -v /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
	systemctl enable --now stubby.service
	systemctl restart stubby.service

	### STATIC RESOLV CONF FILE
	cp -v /etc/resolv.conf /etc/resolv.conf.bak
	cat <<"EOF" > /etc/resolv.conf.stubby
nameserver 127.0.0.3
options trust-ad
EOF
	cp -v /etc/resolv.conf.stubby /etc/resolv.conf
	chattr +i /etc/resolv.conf

	cp -v /etc/hosts /etc/hosts.bak
 	sed -i.bak '/::/d' /etc/hosts
  	cp -v /etc/hosts /etc/hosts.noipv6
  	cp -v /etc/hosts /etc/hosts.noipv6.bak

	### GOOGLE
	cat <<"EOF" > /usr/bin/dnsgoogle
#!/bin/bash
chattr -i /etc/resolv.conf
cp -v /etc/resolv.conf.stubby /etc/resolv.conf
chattr +i /etc/resolv.conf
cp -v /etc/hosts.bak /etc/hosts
cp -v /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
systemctl restart stubby.service
EOF
	chmod +x /usr/bin/dnsgoogle
	
	### DNS.SB
	cat <<"EOF" > /usr/bin/dnssb
#!/bin/bash
chattr -i /etc/resolv.conf
cp -v /etc/resolv.conf.stubby /etc/resolv.conf
chattr +i /etc/resolv.conf
cp -v /etc/hosts.bak /etc/hosts
cp -v /etc/stubby/stubby.yml.dns.sb /etc/stubby/stubby.yml
systemctl restart stubby.service
EOF
	chmod +x /usr/bin/dnssb

	### NTP ENCRYPTED
	apt update && apt install -y ntpsec
	systemctl stop ntpsec.service
	cp -v /etc/ntpsec/ntp.conf /etc/ntpsec/ntp.conf.bak
	cat <<"EOF" > /etc/ntpsec/ntp.conf
driftfile /var/lib/ntpsec/ntp.drift
leapfile /usr/share/zoneinfo/leap-seconds.list
tos maxclock 11
tos minclock 4 minsane 3
server time.cloudflare.com nts
restrict default kod nomodify nopeer noquery limited
restrict 127.0.0.1
#restrict ::1
EOF
	systemctl restart ntpsec.service

 	### LOCAL DNS SERVER
	apt install -y dnsmasq
	systemctl stop dnsmasq.service
	cp -v /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
	cat <<"EOF" > /etc/dnsmasq.conf
port=53
#domain-needed
bogus-priv
resolv-file=/etc/resolv.conf
strict-order
interface=enp3s0
no-dhcp-interface=enp3s0
bind-interfaces
cache-size=0
EOF
	systemctl restart dnsmasq.service

	### BLOCKING ADS TRACKERS MALWARE SPYWARE TELEMETRY CRYPTOMINING BY HOSTS FILE DIRECTLY
	cat <<"EOF" > /usr/bin/make-hosts-block-ads
#!/bin/bash

URL1="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts"
URL2="https://someonewhocares.org/hosts/zero/hosts"
URL3="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/tif-compressed.txt"

rm -vrf /etc/hosts-filter*

### STEVEN BLACK
touch /etc/hosts-filter-steven-black-noipv6
wget --inet4-only --https-only --show-progress --quiet "$URL1" -O /etc/hosts-filter-steven-black-noipv6
if [ $? -eq 0 ]; then
    echo -e "\e[32m ✅ Steven Black Unified hosts = (adware + malware) Plus "fakenews + gambling" downloaded! \e[0m"
    sed -i.bak '/::/d' /etc/hosts-filter-steven-black-noipv6
else
    echo -e "\e[31m ❌ Error: Steven Black url hosts file not found. \e[0m"
    exit 1
fi
### DAN POLLOCK
touch /etc/hosts-filter-dan-pollock-noipv6
wget --inet4-only --https-only --show-progress --quiet "$URL2" -O /etc/hosts-filter-dan-pollock-noipv6
if [ $? -eq 0 ]; then
    echo -e "\e[32m ✅ Dan Pollock hosts file downloaded! \e[0m"
    sed -i.bak '/::/d' /etc/hosts-filter-dan-pollock-noipv6
else
    echo -e "\e[31m ❌ Error: Dan Pollock hosts file not found. \e[0m"
    exit 1
fi
### HAGEZI TIF
touch /etc/hosts-filter-hagezi-tif-noipv6
wget --inet4-only --https-only --show-progress --quiet "$URL3" -O /etc/hosts-filter-hagezi-tif-noipv6
if [ $? -eq 0 ]; then
    echo -e "\e[32m ✅ Hagezi TIF hosts file downloaded! \e[0m"
    sed -i.bak '/::/d' /etc/hosts-filter-hagezi-tif-noipv6
else
    echo -e "\e[31m ❌ Error: Hagezi TIF hosts file not found. \e[0m"
    exit 1
fi

cat /etc/hosts-filter-steven-black-noipv6 > /etc/hosts-filter-adblocker-noipv6
cat /etc/hosts-filter-dan-pollock-noipv6 >> /etc/hosts-filter-adblocker-noipv6
cat /etc/hosts-filter-hagezi-tif-noipv6 >> /etc/hosts-filter-adblocker-noipv6

sed -i -e 's/web.facebook.com/0.0.0.0/g' /etc/hosts-filter-adblocker-noipv6
sed -i -e 's/crash.steampowered.com/0.0.0.0/g' /etc/hosts-filter-adblocker-noipv6
sed -i -e 's/click.discord.com/0.0.0.0/g' /etc/hosts-filter-adblocker-noipv6

awk '!seen[$0]++' /etc/hosts-filter-adblocker-noipv6 > /etc/hosts-filter-definitive
chattr -i /etc/hosts
cp -v /etc/hosts.noipv6.bak /etc/hosts
cat /etc/hosts-filter-definitive >> /etc/hosts

rm -vrf /etc/hosts-filter*

echo -e "\e[32m ✅ Archivo /etc/hosts bloqueando ads malware y más con éxito !!! \e[0m"
EOF

	chmod +x /usr/bin/make-hosts-block-ads
	bash /usr/bin/make-hosts-block-ads
}

_debian_desktop()
{
	### OFFICIAL DEBIAN PACKAGES
	apt update
	apt install --install-recommends -y $PACKAGES
	
	### LIQUORIX KERNEL
 	### curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
	curl -s "https://liquorix.net/liquorix-keyring.gpg" | gpg --batch --yes --output /etc/apt/keyrings/liquorix-keyring.gpg --dearmor
	chmod 0644 /etc/apt/keyrings/liquorix-keyring.gpg
	cat <<EOF > /etc/apt/sources.list.d/liquorix.sources
Types: deb deb-src
URIs: https://liquorix.net/debian
Suites: $(lsb_release -cs)
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/liquorix-keyring.gpg
EOF
	#apt update && apt install --install-recommends -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64

	### TOR BROWSER
	cat <<"EOF" > /usr/bin/installer-tor-browser
#!/bin/bash
LINK="https://www.torproject.org"
TOR_BROWSER_LINK=$(curl -s "$LINK"/download/ | grep -oP 'href="/dist/torbrowser/[^"]*"' | grep 'linux-x86_64' | sed 's/href="\///' | sed 's/"//' | head -n 1)
URL="$LINK"/"$TOR_BROWSER_LINK"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    tar xf "$FILE"
    mv -v tor-browser/ /opt/apps
    rm -vf "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-tor-browser
	bash /usr/bin/installer-tor-browser

	### GOOGLE CHROME
	cat <<"EOF" > /usr/bin/installer-google-chrome
#!/bin/bash
URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    apt install -y "./$FILE"
	rm -vf "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-google-chrome
	bash /usr/bin/installer-google-chrome

 	### FIREFOX
	#apt update && apt install --install-recommends -y firefox-esr
	apt purge -y firefox* && rm -vrf /home/*/.mozilla && rm -vrf /home/*/.cache/mozilla
	install -d -m 0755 /etc/apt/keyrings
	wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
	gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
	cat <<"EOF" > /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
	cat <<"EOF" > /etc/apt/preferences.d/mozilla
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
	apt update && apt install --install-recommends -y firefox

 	### PACKET TRACER NO-NETWORK
	cat <<"EOF" > /usr/share/applications/packet-tracer-no-network.desktop
[Desktop Entry]
Type=Application
Exec=unshare -rn /opt/pt/packettracer
Name=PacTreiser NO-NETWORK
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
EOF

	### VIRTUAL BOX
	wget --inet4-only -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
	cat <<EOF > /etc/apt/sources.list.d/vbox.sources
Types: deb
URIs: https://download.virtualbox.org/virtualbox/debian
Suites: $(lsb_release -cs)
Components: contrib
Architectures: amd64
Signed-By: /usr/share/keyrings/oracle-virtualbox-2016.gpg
EOF
	apt update && apt install --install-recommends -y virtualbox-7.2 linux-headers-amd64 linux-headers-$(uname -r)

	### VSCODE
	wget --inet4-only -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
	install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
	rm -vf microsoft.gpg
	cat <<EOF > /etc/apt/sources.list.d/vscode.sources
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
	apt update && apt install -y code
}

_cookie_fortune()
{
	## https://stackoverflow.com/questions/414164/how-can-i-select-random-files-from-a-directory-in-bash
	apt update && apt install -y cowsay fortunes
	cat <<"EOF" > /usr/bin/cookie-fortune
#!/bin/bash
CHARACTER=$(ls /usr/share/cowsay/cows/ | shuf -n 1)
fortune -s | cowsay -f $CHARACTER
EOF
	rm -vf /usr/share/applications/fortune.desktop
	chmod 755 /usr/bin/cookie-fortune
	bash /usr/bin/cookie-fortune
}

_other_configs_()
{
	### FFMPEG
    cat <<"EOF" > /usr/bin/installer-ffmpeg-master
#!/bin/bash
URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    rm -vrf /opt/apps/ffmpeg*
    rm -vrf /usr/bin/master-ff*
    wget --inet4-only --https-only --show-progress -q "$URL"
    tar xf ffmpeg-master-latest-linux64-gpl.tar.xz
    rm -vrf ffmpeg-master-latest-linux64-gpl.tar.xz
    mv -v ffmpeg-master-latest-linux64-gpl /opt/apps
    ln -vsf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffmpeg /usr/bin/master-ffmpeg
    ln -vsf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffplay /usr/bin/master-ffplay
    ln -vsf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffprobe /usr/bin/master-ffprobe
else
    echo "Error: The URL '$URL' is not available."
fi
EOF
	chmod +x /usr/bin/installer-ffmpeg-master
	bash /usr/bin/installer-ffmpeg-master

	### OLLAMA
	curl -fsSL https://ollama.com/install.sh | sh
	systemctl disable ollama
	systemctl stop ollama

	### NFSIISE
    ### Copy fedata and gamedata directories from the Need For Speed™ II SE original CD-ROM into Need For Speed II SE directory.
    ### All files and directories copied from CD-ROM must have small letters on Unix-like systems!!!
    ###     Please use the Need For Speed II SE/convert_to_lowercase script if you have UPPERCASE names.
	### OPTIONAL: mangohud --dlsym nfs2se
    dpkg --add-architecture i386
    apt update
    apt install -y git libsdl2-dev:i386 gcc g++ gcc-multilib g++-multilib yasm clang lld lld:i386 mangohud mangohud:i386
    git clone https://github.com/zaps166/NFSIISE /opt/third-apps/NFSIISE
    cd /opt/third-apps/NFSIISE
    git submodule update --init --recursive
    ./compile_nfs cpp
    mv /opt/NFSIISE/Need\ For\ Speed\ II\ SE/ /opt/NeedForSpeedIISE
	rm -rf /opt/third-apps/NFSIISE
	cd /tmp

	### QBITTORRENT-NOX
	apt install -y qbittorrent-nox
	cat <<"EOF" > /etc/systemd/system/qbittorrent-nox.service
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
Type=forking
User=someone
Group=someone
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080 --save-path=/home/someone
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
	systemctl daemon-reload
	systemctl start qbittorrent-nox.service
	systemctl enable qbittorrent-nox.service
	
	### PACKET TRACER NO-NETWORK
	cat <<"EOF" > /usr/share/applications/packet-tracer-no-network.desktop
[Desktop Entry]
Type=Application
Exec=unshare -rn /opt/pt/packettracer
Name=PacTreiser NO-NETWORK
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
EOF

	### IVPN-UI
	curl -fsSL https://repo.ivpn.net/stable/debian/generic.gpg | gpg --dearmor > ~/ivpn-archive-keyring.gpg
	mv ~/ivpn-archive-keyring.gpg /usr/share/keyrings/ivpn-archive-keyring.gpg
	chown root:root /usr/share/keyrings/ivpn-archive-keyring.gpg && chmod 644 /usr/share/keyrings/ivpn-archive-keyring.gpg
	cat <<EOF > /etc/apt/sources.list.d/ivpn.sources
Types: deb
URIs: https://repo.ivpn.net/stable/debian
Suites: ./generic
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/ivpn-archive-keyring.gpg
EOF
	chown root:root /etc/apt/sources.list.d/ivpn.sources && chmod 644 /etc/apt/sources.list.d/ivpn.sources
	apt update && apt install -y ivpn-ui

	### TOR
	wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
	cat <<EOF > /etc/apt/sources.list.d/tor.sources
Types: deb
URIs: https://deb.torproject.org/torproject.org
Suites: $(lsb_release -cs)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/deb.torproject.org-keyring.gpg
EOF
	apt update && apt install --install-recommends -y tor deb.torproject.org-keyring
	systemctl stop tor.service
	systemctl disable tor.service

	### WASABI
	cat <<"EOF" > /usr/bin/installer-wasabi
#!/bin/bash
URL=$(curl --silent "https://api.github.com/repos/WalletWasabi/WalletWasabi/releases/latest" | grep browser_download_url | grep ".deb" | head -n 1 | cut -d '"' -f 4)
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    apt install -y "./$FILE"
	rm -f "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-wasabi
	bash /usr/bin/installer-wasabi

	### GOOGLE EARTH
	cat <<"EOF" > /usr/bin/installer-google-earth
#!/bin/bash
URL="https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	apt install -y "./$FILE"
	rm -f "$FILE"
	cp -v /opt/google/earth/pro/google-earth-pro.desktop /usr/share/applications/google-earth-pro.desktop
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-google-earth
	bash /usr/bin/installer-google-earth

	### MULLVAD
	curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
	cat <<EOF > /etc/apt/sources.list.d/mullvad.sources
Types: deb
URIs: https://repository.mullvad.net/deb/stable
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/mullvad-keyring.asc
EOF
	apt update && apt install -y mullvad-browser

	### STEAM
	dpkg --add-architecture i386
	apt update
	apt install -y steam-installer
	apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386

	### ZOOM
    cat <<"EOF" > /usr/bin/installer-zoom
#!/bin/bash
URL="https://zoom.us/client/latest/zoom_amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	apt install -y "./$FILE"
	rm -f "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-zoom
	bash /usr/bin/installer-zoom
	
	### WINE-HQ
	dpkg --add-architecture i386
	wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
	wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
	apt update && apt install --install-recommends -y winehq-devel

	### OFFICIAL OPEN JDK
	cat <<"EOF" > /usr/bin/installer-jdk
#!/bin/bash
LATEST_JDK_=$(curl --silent https://jdk.java.net/ | grep 'Ready for use' | sed -E 's/.*href="\/([0-9]+)\/.*/\1/')
URL=$(curl -s https://jdk.java.net/$LATEST_JDK_/ | grep linux-x64_bin.tar.gz | sed -E 's/.*href="([^"]+)".*/\1/' | head -n 1)
BUILD_VERSION=$(echo $URL | sed -E 's/.*\/jdk([0-9]+\.[0-9]+\.[0-9]+)\/.*/\1/')
FILE=$(basename $URL)
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    rm -rf /opt/apps/jdk*
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    tar xf "$FILE"
    mv jdk-$BUILD_VERSION /opt/apps/
    rm -rf "$FILE"
    JAVA_HOME_PATH="/opt/apps/jdk-$BUILD_VERSION"
    export JAVA_HOME="$JAVA_HOME_PATH"
    export PATH="$PATH:$JAVA_HOME/bin"
    export CLASSPATH=".:$JAVA_HOME/lib"
    echo "export JAVA_HOME=$JAVA_HOME_PATH" | tee /etc/profile.d/jdk-path.sh > /dev/null
    echo "export PATH=\$PATH:$JAVA_HOME/bin" | tee -a /etc/profile.d/jdk-path.sh > /dev/null
    echo "export CLASSPATH=.:$JAVA_HOME/lib" | tee -a /etc/profile.d/jdk-path.sh > /dev/null
    echo "Ruta de Open JDK agregada a /etc/profile.d/jdk-path.sh para todos los usuarios."
    update-alternatives --install /usr/bin/java java "$JAVA_HOME/bin/java" 10033
    update-alternatives --install /usr/bin/javac javac "$JAVA_HOME/bin/javac" 10033
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-jdk
	bash /usr/bin/installer-jdk

	### GHIDRA
    cat <<"EOF" >/usr/bin/installer-ghidra
#!/bin/bash
URL=$(curl --silent "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest" | jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' | head -n 1)
FILE=$(basename "$URL")
DIR_NAME="${FILE%.zip}"
UNZIPPED_DIR="${DIR_NAME%_*}"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    rm -rf /opt/apps/ghidra*
    rm -f /usr/bin/ghidra
    rm -rf ghidra*.zip
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    unzip -q "$FILE" -d /opt/apps
    rm -f "$FILE"
    ln -sf "/opt/apps/$UNZIPPED_DIR/ghidraRun" /usr/bin/ghidra
    bash -c "echo '[Desktop Entry]
Categories=Application;Development;
Comment=Ghidra Software Reverse Engineering Suite
Exec=/opt/apps/$UNZIPPED_DIR/ghidraRun
GenericName=Ghidra Software Reverse Engineering Suite
Icon=/opt/apps/$UNZIPPED_DIR/docs/images/GHIDRA_1.png
MimeType=
Name=Ghidra
Path=/opt/apps/$UNZIPPED_DIR
StartupNotify=false
Terminal=false
TerminalOptions=
Type=Application
Version=1.0' > /usr/share/applications/ghidra.desktop"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-ghidra
	bash /usr/bin/installer-ghidra

	### YOUTUBE DOWNLOADER
    cat <<"EOF" >/usr/bin/installer-yt-dlp
#!/bin/bash
URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    apt purge -y yt-dlp
	rm -rf /opt/apps/yt-*
	rm -rf /usr/bin/yt-*
	mkdir -v -p /opt/apps/
    wget --inet4-only --https-only --show-progress -q "$URL" -O /opt/apps/yt-dlp
	chmod 755 /opt/apps/yt-dlp
	ln -sf /opt/apps/yt-dlp /usr/bin/yt-dlp
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-yt-dlp
	bash /usr/bin/installer-yt-dlp

	### NMAP
	cat <<"EOF" > /usr/bin/installer-nmap-suite
#!/bin/bash
CURRENT_DIR=$(pwd)
SOURCE_CODE_FILE=$(curl -s https://nmap.org/download | grep tar.bz2 | head -n 1 | cut -d " " -f 3)
URL="https://nmap.org/dist/$SOURCE_CODE_FILE"
INSTALL_DIR="/opt/apps/nmap-suite"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	apt purge -y nmap*
	rm -rf "$INSTALL_DIR"
	rm -rf /usr/bin/nmap /usr/bin/ncat /usr/bin/nping /usr/bin/zenmap /usr/bin/ndiff
	apt update && apt build-dep -y nmap
	mkdir -p -v /opt/apps/nmap-suite
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$SOURCE_CODE_FILE"
	tar xjf "$SOURCE_CODE_FILE"
	rm -rf "$SOURCE_CODE_FILE"
	EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "nmap-*" -print -quit)
	cd "$EXTRACTED_DIR"
	./configure --quiet --prefix="$INSTALL_DIR"
	make -j 1
	make install
	if ! grep -q "export PATH=\"\$PATH:/opt/apps/nmap-suite/bin\"" /etc/profile; then
		export PATH="$PATH:$INSTALL_DIR/bin"
		echo "export PATH=\$PATH:$INSTALL_DIR/bin" | tee /etc/profile.d/nmap-path.sh > /dev/null
		echo "Nmap PATH added for all users."
	else
		echo "La ruta de Nmap ya está configurada en /etc/profile."
	fi
	echo "$SOURCE_CODE_FILE installed successfully!"
else
	echo "Error $URL not found."
fi
cd "$CURRENT_DIR"
rm -rf "$CURRENT_DIR"/nmap-* "$SOURCE_CODE_FILE"
EOF
	chmod +x /usr/bin/installer-nmap-suite
	bash /usr/bin/installer-nmap-suite
	
	### SQLMAP
	apt purge -y sqlmap*
	rm -rf /opt/apps/sqlmap*
	rm -rf /usr/bin/sqlmap*
	mkdir -v -p /opt/apps/
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/apps/sqlmap-dev
	ln -sf /opt/apps/sqlmap-dev/sqlmap.py /usr/bin/sqlmap
	
	### FFMPEG
    cat <<"EOF" > /usr/bin/installer-ffmpeg-master
#!/bin/bash
URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    rm -rf /opt/apps/ffmpeg*
    rm -rf /usr/bin/master-ff*
    wget --inet4-only --https-only --show-progress -q "$URL"
    tar xf ffmpeg-master-latest-linux64-gpl.tar.xz
    rm -rf ffmpeg-master-latest-linux64-gpl.tar.xz
    mv -v ffmpeg-master-latest-linux64-gpl /opt/apps
    ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffmpeg /usr/bin/master-ffmpeg
    ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffplay /usr/bin/master-ffplay
    ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffprobe /usr/bin/master-ffprobe
else
    echo "Error: The URL '$URL' is not available."
fi
EOF
	chmod +x /usr/bin/installer-ffmpeg-master
	bash /usr/bin/installer-ffmpeg-master

	### Android SDK Platform-Tools - adb and fastboot
	cat <<"EOF" >/usr/bin/installer-android-tools
#!/bin/bash
URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	rm -rf /opt/apps/platform-tools*
	rm -rf /usr/bin/adb /usr/bin/fastboot
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	unzip "$FILE"
	rm -rf "$FILE"
	mv platform-tools /opt/apps
	ln -sf /opt/apps/platform-tools/adb /usr/bin/adb
	ln -sf /opt/apps/platform-tools/fastboot /usr/bin/fastboot
else
	echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-android-tools
	bash /usr/bin/installer-android-tools

	### GO LANGUAGE
	cat <<"EOF" > /usr/bin/installer-go
#!/bin/bash
ARCH="amd64"
OS="linux"
GO_URL_BASE="https://go.dev/dl"
LATEST_VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | head -n 1)
FILE="$LATEST_VERSION.$OS-$ARCH.tar.gz"
URL="$GO_URL_BASE/$FILE"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	rm -rf /usr/local/go
	rm -rf /opt/apps/go
	tar -C /opt/apps -xzf "$FILE"
	rm -rf "$FILE"
	if ! grep -q "export PATH=\"\$PATH:/opt/apps/go/bin\"" /etc/profile; then
		echo "export PATH=\$PATH:/opt/apps/go/bin" | tee /etc/profile.d/go-path.sh > /dev/null
		echo "Ruta de Go agregada a /etc/profile.d/go-path.sh para todos los usuarios."
	else
		echo "La ruta de Go ya está configurada en /etc/profile."
	fi
	echo "Go $VERSION installed successfully!"
else
	echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-go
	bash /usr/bin/installer-go

	### LATEST PYTHON
	cat << 'EOF' | tee /usr/bin/installer-python > /dev/null
#!/bin/bash
CURRENT_DIR=$(pwd)
INSTALL_DIR="/opt/apps"
VERSION=$(curl -s https://www.python.org/ | grep Latest | head -n 1 | sed -E 's/.*Python\s([0-9.]*).*/\1/')
#VERSION=$(curl -s https://www.python.org/ | grep -oP 'Latest: <a href="/downloads/release/python-\K[0-9.]+' | head -n 1)
URL="https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	apt update && apt build-dep -y python3
	tar xf "$FILE"
	mv Python-"$VERSION"
	./configure --prefix="$INSTALL_DIR"/python --enable-optimizations --enable-ipv6
	make
	make test
	make install
else
	echo "Error $URL not found."
fi
cd "$CURRENT_DIR"
rm -rf "$FILE"
rm -rf Python-"$VERSION"
EOF
	chmod +x /usr/bin/installer-python
	#bash /usr/bin/installer-python

	### OLLAMA
	curl -fsSL https://ollama.com/install.sh | sh
	systemctl disable ollama
	systemctl stop ollama

	###
	chown -R someone:someone /opt/apps/*

	mkdir -v -p /opt/songs
	touch /opt/songs/SONG{001..102}.flac
}

_basic_setup
_networking
#_debian_desktop
#_flatpak
_cookie_fortune
#_other_configs_
