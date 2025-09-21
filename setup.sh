#!/bin/bash

##################################################
# DEFINING GENERAL VARIABLES
##################################################

# Output formatting variables
process_icon=" >"
error_icon="(!)"
success_icon="(√)"
section_separator="##################################################"
line_separator="--------------------------------------------------"
line_separator_small="-------------------------"

# Exit codes
e_missing_osr_file=10
e_missing_fonts_folder=11
e_missing_uninstall_list=12
e_missing_native_list=13
e_missing_flatpak_list=14

e_unknown_distro=21
e_unknown_fedora=22

##################################################
# DETECTING DISTRIBUTION
##################################################

echo -e "\n${section_separator}"
echo 'DETECTING DISTRIBUTION'
echo -e "${section_separator}\n"

# A variable to indicate which distribution is installed on the specific system the script is running on based on the "/etc/os-release" file
detected_distro=""
echo "${process_icon} Starting distribution detection..."

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "$ID" == "fedora" ]]; then
        if [[ "${VARIANT_ID:-}" == "workstation" ]]; then
            detected_distro="Fedora Workstation"
            echo "${success_icon} Distribution detected as \"${detected_distro}\"."
        else
            echo "${error_icon} Fedora distribution detected, but unknown or unsupported variant."
            echo "${error_icon} From the \"/etc/os-release\" file: \"VARIANT_ID=${VARIANT_ID:-<unspecified>}\". Exiting..."
            exit "$e_unknown_fedora"
        fi
    else
        echo "${error_icon} Unknown distribution detected. The script does not know how to handle setting up this system. Exiting..."
        exit "$e_unknown_distro"
    fi
else
    echo "${error_icon} Cannot detect distribution. The \"/etc/os-release\" file could not be found. Exiting..."
    exit "$e_missing_osr_file"
fi

##################################################
# DEFINING EXTERNAL FILES' PATH VARIABLES
##################################################

echo -e "\n${section_separator}"
echo "DEFINING EXTERNAL FILES' PATH VARIABLES"
echo -e "${section_separator}\n"

# Folder containing the fonts to be installed
fonts_folder="./fonts"
echo "${process_icon} Defining fonts location..."

if [[ -e "$fonts_folder" ]]; then
    echo "${success_icon} Fonts folder was found at \"${fonts_folder}\"."
else
    echo "${error_icon} Fonts folder was not found at the expected location."
    echo "${error_icon} Current fonts folder location is set to \"${fonts_folder}\". Exiting..."
    exit "$e_missing_fonts_folder"
fi

echo "$line_separator"

# Text file containing a list of unwanted stock applications to uninstall
uninstall_list=""
echo "${process_icon} Defining uninstallation list location..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    uninstall_list="./applications/fedora-workstation/uninstall-list.txt"
    if [[ -f "$uninstall_list" ]]; then
        echo "${success_icon} List of unwanted stock applications to uninstall was found at \"${uninstall_list}\"."
    else
        echo "${error_icon} List of unwanted stock applications to uninstall was not found at the expected location."
        echo "${error_icon} Current list of unwanted stock applications to uninstall location is set to \"${uninstall_list}\". Exiting..."
        exit "$e_missing_uninstall_list"
    fi
else
    echo "${error_icon} Unknown distribution detected. The script does not know where the list of unwanted stock applications to uninstall for this system is. Exiting..."
    exit "$e_unknown_distro"
fi

echo "$line_separator"

# Text file containing a list of wanted native applications to install for use with the native package manager
native_list=""
echo "${process_icon} Defining native installation list location..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    native_list="./applications/fedora-workstation/native-list.txt"
    if [[ -f "$native_list" ]]; then
        echo "${success_icon} List of wanted native applications to install was found at \"${native_list}\"."
    else
        echo "${error_icon} List of wanted native applications to install was not found at the expected location."
        echo "${error_icon} Current list of wanted native applications to install location is set to \"${native_list}\". Exiting..."
        exit "$e_missing_native_list"
    fi
else
    echo "${error_icon} Unknown distribution detected. The script does not know where the list of wanted native applications to install for this system is. Exiting..."
    exit "$e_unknown_distro"
fi

echo "$line_separator"

# Text file containing a list of wanted Flatpak applications to install from Flathub
flatpak_list=""
echo "${process_icon} Defining Flatpak installation list location..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    flatpak_list="./applications/fedora-workstation/flatpak-list.txt"
    if [[ -f "$flatpak_list" ]]; then
        echo "${success_icon} List of wanted Flatpak applications to install was found at \"${flatpak_list}\"."
    else
        echo "${error_icon} List of wanted Flatpak applications to install was not found at the expected location."
        echo "${error_icon} Current list of wanted Flatpak applications to install location is set to \"${flatpak_list}\". Exiting..."
        exit "$e_missing_flatpak_list"
    fi
else
    echo "${error_icon} Unknown distribution detected. The script does not know where the list of wanted Flatpak applications to install for this system is. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# INSTALLING SCRIPT DEPENDENCIES
##################################################

echo -e "\n${section_separator}"
echo 'INSTALLING SCRIPT DEPENDENCIES'
echo -e "${section_separator}\n"

echo "${process_icon} Starting installation of script dependencies..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    sudo dnf install curl distribution-gpg-keys dnf-plugins-core findutils flatpak wget -y
    echo "${success_icon} Finished installation of script dependencies."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle installing script dependencies for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# INSTALLING FONTS
##################################################

echo -e "\n${section_separator}"
echo 'INSTALLING FONTS'
echo -e "${section_separator}\n"

echo "${process_icon} Starting installation of fonts..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    sudo cp -rv "$fonts_folder"/* /usr/share/fonts
    sudo fc-cache -fv
    echo "${success_icon} Finished installation of fonts."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle installing fonts for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# UNINSTALLING STOCK APPLICATIONS
##################################################

echo -e "\n${section_separator}"
echo 'UNINSTALLING STOCK APPLICATIONS'
echo -e "${section_separator}\n"

echo "${process_icon} Starting uninstallation of unwanted stock applications..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    # External uninstallation list
    echo -e "\n${process_icon} Uninstalling the provided external list of unwanted stock applications..."
    xargs sudo dnf remove -y <"$uninstall_list"
    echo "${success_icon} Finished uninstalling the provided external list of unwanted stock applications."

    echo "$line_separator"

    # Unwanted default groups
    echo "${process_icon} Uninstalling unwanted default groups..."
    sudo dnf group remove libreoffice -y
    echo "${success_icon} Finished uninstalling unwanted default groups."

    echo -e "\n${success_icon} Finished uninstallation of unwanted stock applications."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle uninstalling unwanted stock applications for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# ADDING DISTRIBUTION-AGNOSTIC REPOSITORIES
##################################################

echo -e "\n${section_separator}"
echo 'ADDING DISTRIBUTION-AGNOSTIC REPOSITORIES'
echo -e "${section_separator}\n"

# Flathub
echo "${process_icon} Adding Flathub repository..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "${success_icon} Finished adding Flathub repository."

##################################################
# ADDING DISTRIBUTION-SPECIFIC REPOSITORIES
##################################################

echo -e "\n${section_separator}"
echo 'ADDING DISTRIBUTION-SPECIFIC REPOSITORIES'
echo -e "${section_separator}\n"

echo "${process_icon} Adding repositories..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    # Brave Browser
    echo -e "\n${process_icon} Adding Brave Browser repository..."
    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    echo "${success_icon} Finished adding Brave Browser repository."

    echo "$line_separator"

    # Visual Studio Code
    echo "${process_icon} Adding Visual Studio Code repository..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
    echo "${success_icon} Finished adding Visual Studio Code repository."

    echo "$line_separator"

    # RPM Fusion
    echo "${process_icon} Adding RPM Fusion repositories..."
    sudo rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-fedora-$(rpm -E %fedora)
    sudo rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-fedora-$(rpm -E %fedora)
    sudo dnf --setopt=localpkg_gpgcheck=1 install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
    sudo dnf update @core -y
    sudo dnf install rpmfusion-\*-appstream-data -y
    echo "${success_icon} Finished adding RPM Fusion repositories."

    echo "$line_separator"

    # Refreshing repository cache
    echo "${process_icon} Refreshing repository cache..."
    sudo dnf check-update
    echo "${success_icon} Finished refreshing repository cache."

    echo -e "\n${success_icon} Finished adding repositories."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle adding distribution-specific repositories for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# INSTALLING CODECS, FIRMWARE, AND DRIVERS
##################################################

echo -e "\n${section_separator}"
echo 'INSTALLING CODECS, FIRMWARE, AND DRIVERS'
echo -e "${section_separator}\n"

echo "${process_icon} Starting installation of codecs, firmware, and drivers..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    # RPM Fusion codecs, firmware, and drivers
    echo -e "\n${process_icon} Installing RPM Fusion codecs, firmware, and drivers..."
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
    sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
    sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y
    sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld -y
    sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 -y
    sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 -y
    sudo dnf install rpmfusion-nonfree-release-tainted -y
    sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware" -y
    echo "${success_icon} Finished installing RPM Fusion codecs, firmware, and drivers."

    echo -e "\n${success_icon} Finished installation of codecs, firmware, and drivers."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle installing codecs, firmware, and drivers for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# INSTALLING NATIVE APPLICATIONS (PACKAGE MANAGER)
##################################################

echo -e "\n${section_separator}"
echo 'INSTALLING NATIVE APPLICATIONS (PACKAGE MANAGER)'
echo -e "${section_separator}\n"

echo "${process_icon} Starting installation of native package manager applications..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    # External native applications list
    echo -e "\n${process_icon} Installing the provided external list of native applications..."
    xargs sudo dnf install -y <"$native_list"
    echo "${success_icon} Finished installing the provided external list of native applications."

    echo "$line_separator"

    # Refreshing repository cache, updating, and uninstalling unused dependencies
    echo "${process_icon} Refreshing repository cache, updating, and uninstalling unused dependencies..."
    sudo dnf clean all
    sudo dnf update -y
    sudo dnf autoremove -y
    echo "${success_icon} Finished refreshing repository cache, updating, and uninstalling unused dependencies."

    echo -e "\n${success_icon} Finished installation of native package manager applications."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle installing native package manager applications for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# INSTALLING NATIVE APPLICATIONS (DIRECT)
##################################################

echo -e "\n${section_separator}"
echo 'INSTALLING NATIVE APPLICATIONS (DIRECT)'
echo -e "${section_separator}\n"

echo "${process_icon} Starting installation of native direct download applications..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    # Yubico Authenticator
    echo -e "\n${process_icon} Installing Yubico Authenticator..."
    wget -P ~ https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz
    tar -xvf ~/yubico-authenticator-* -C ~
    rm -v ~/yubico-authenticator-*.tar.gz
    mv -v ~/yubico-authenticator-* ~/.yubico-authenticator
    ~/.yubico-authenticator/desktop_integration.sh --install
    echo "${success_icon} Finished installing Yubico Authenticator."

    echo "$line_separator"

    # Node Version Manager (NVM)
    echo "${process_icon} Installing Node Version Manager (NVM)..."
    latest_nvm_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${latest_nvm_version}/install.sh" | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm --version
    echo "${success_icon} Finished installing Node Version Manager (NVM)."

    echo "$line_separator"

    # Node.js
    echo "${process_icon} Installing desired Node.js versions..."
    nvm install 20
    echo "${success_icon} Finished installing desired Node.js versions."

    echo "$line_separator"

    # Pipenv
    echo "${process_icon} Installing Pipenv..."
    pip install pipenv --user
    echo "${success_icon} Finished installing Pipenv."

    echo "$line_separator"

    # Starship prompt
    echo "${process_icon} Installing Starship prompt..."
    sudo curl -sS https://starship.rs/install.sh | sh
    echo -e '# Starship prompt\neval "$(starship init bash)"' >>~/.bashrc
    starship preset catppuccin-powerline -o ~/.config/starship.toml
    echo "${success_icon} Finished installing Starship prompt."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle installing native direct download applications for this system. Exiting..."
    exit "$e_unknown_distro"
fi

echo -e "\n${success_icon} Finished installation of native direct download applications."

##################################################
# APPLYING SYSTEM/APPLICATION CONFIGURATIONS
##################################################

echo -e "\n${section_separator}"
echo 'APPLYING SYSTEM/APPLICATION CONFIGURATIONS'
echo -e "${section_separator}\n"

echo "${process_icon} Applying configurations..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    # Enabling Syncthing service
    echo -e "\n${process_icon} Enabling Syncthing service..."
    sudo systemctl enable --now syncthing@$USER.service
    echo "${success_icon} Finished enabling Syncthing service."

    echo "$line_separator"

    # Configuring firewalld
    echo "${process_icon} Configuring firewalld..."

    ## Enabling firewalld
    echo -e "\n${process_icon} Enabling firewalld..."
    sudo systemctl enable --now firewalld
    echo "${success_icon} Finished enabling firewalld."

    echo "$line_separator_small"

    ## Setting the default zone and blocking all inbound traffic (meant for any unknown and untrusted connections)
    default_zone="public"
    echo "${process_icon} Setting the default zone and blocking all inbound traffic..."
    sudo firewall-cmd --set-default-zone="$default_zone"
    ### Removing all default allowed inbound services on default zone
    for s in $(sudo firewall-cmd --zone="$default_zone" --list-services); do
        sudo firewall-cmd --zone="$default_zone" --remove-service="$s" --permanent
    done
    ### Removing all default allowed inbound ports on default zone
    for p in $(sudo firewall-cmd --zone="$default_zone" --list-ports); do
        sudo firewall-cmd --zone="$default_zone" --remove-port="$p" --permanent
    done
    echo "${success_icon} Finished setting the default zone and blocking all inbound traffic."

    echo "$line_separator_small"

    ## Allowing inbound Syncthing and mDNS traffic on another, trusted zone, and blocking all other traffic
    trusted_zone="home"
    echo "${process_icon} Allowing inbound Syncthing and mDNS traffic on another, trusted zone, and blocking all other traffic..."
    ### Removing all default allowed inbound services on trusted zone
    for s in $(sudo firewall-cmd --zone="$trusted_zone" --list-services); do
        sudo firewall-cmd --zone="$trusted_zone" --remove-service="$s" --permanent
    done
    ### Removing all default allowed inbound ports on trusted zone
    for p in $(sudo firewall-cmd --zone="$trusted_zone" --list-ports); do
        sudo firewall-cmd --zone="$trusted_zone" --remove-port="$p" --permanent
    done
    ### Allowing inbound Syncthing and mDNS traffic on trusted zone
    sudo firewall-cmd --zone="$trusted_zone" --add-service=syncthing --permanent
    sudo firewall-cmd --zone="$trusted_zone" --add-service=mdns --permanent
    echo "${success_icon} Finished allowing inbound Syncthing and mDNS traffic on another, trusted zone, and blocking all other traffic."

    echo "$line_separator_small"

    ## Applying the trusted zone to trusted network connections
    trusted_connections_list="./configurations/fedora-workstation/trusted-connections-list.txt"
    echo "${process_icon} Applying the trusted zone to trusted network connections..."
    if [[ ! -r "$trusted_connections_list" ]]; then
        echo "${error_icon} No trusted connections list found."
        echo "${error_icon} Current trusted connections list location is set to \"${trusted_connections_list}\". Skipping network zone assignment..."
    else
        while IFS= read -r name || [[ -n "$name" ]]; do
            name="${name%%#*}"
            name="${name#"${name%%[![:space:]]*}"}"
            name="${name%"${name##*[![:space:]]}"}"
            [[ -z "$name" ]] && continue

            if sudo nmcli connection show "$name" >/dev/null 2>&1; then
                if sudo nmcli connection modify "$name" connection.zone "$trusted_zone" >/dev/null 2>&1; then
                    echo "Applied zone \"${trusted_zone}\" to \"${name}\"."
                else
                    echo "${error_icon} Failed to apply zone for \"${name}\"."
                fi
            else
                echo "${error_icon} Profile for \"${name}\" not present. Skipping..."
            fi
        done <"$trusted_connections_list"
    fi
    echo "${success_icon} Finished applying the trusted zone to trusted network connections."

    echo "$line_separator_small"

    ## Reloading the firewall to apply the changes immediately and printing the status
    echo "${process_icon} Reloading the firewall to apply the changes immediately and printing the status..."
    sudo firewall-cmd --reload
    sudo firewall-cmd --zone="$default_zone" --list-all
    sudo firewall-cmd --zone="$trusted_zone" --list-all
    echo "${success_icon} Finished reloading the firewall to apply the changes immediately and printing the status."

    echo -e "\n${success_icon} Finished configuring firewalld."

    echo "$line_separator"

    # Configuring DNS over TLS
    echo "${process_icon} Configuring DNS over TLS..."
    sudo systemctl disable --now systemd-resolved
    sudo systemctl mask systemd-resolved
    sudo systemctl enable --now dnsconfd
    echo -e "[main]\ndns=dnsconfd\n\n[global-dns]\nresolve-mode=exclusive\n\n[global-dns-domain-*]\nservers=dns+tls://9.9.9.9#dns.quad9.net,dns+tls://149.112.112.112#dns.quad9.net" >~/global-dot.conf
    sudo mv ~/global-dot.conf /etc/NetworkManager/conf.d/global-dot.conf
    sudo chown root:root /etc/NetworkManager/conf.d/global-dot.conf
    sudo chmod 644 /etc/NetworkManager/conf.d/global-dot.conf
    sudo systemctl restart dnsconfd
    sudo systemctl restart NetworkManager
    ls -l /etc/NetworkManager/conf.d
    nmcli device show | grep IP4.DNS
    sleep 10s
    echo "${success_icon} Finished configuring DNS over TLS."

    echo "$line_separator"

    # PostgreSQL configuration
    echo "${process_icon} Configuring PostgreSQL..."
    sudo systemctl start postgresql.service
    sudo -u postgres createuser $USER
    sudo -u postgres createdb $USER
    psql -c "ALTER ROLE $USER WITH CREATEDB;"
    psql -c "ALTER ROLE $USER WITH SUPERUSER;"
    echo "${success_icon} Finished configuring PostgreSQL."

    echo "$line_separator"

    # QEMU/KVM/libvirt and VirtualBox configuration
    echo "${process_icon} Configuring QEMU/KVM/libvirt and VirtualBox..."
    sudo systemctl enable --now libvirtd
    lsmod | grep kvm
    sudo usermod -aG libvirt,vboxusers $(whoami)

    ## If Secure Boot is enabled, ask user to specify password to enroll the VirtualBox public key
    if [[ "$(mokutil --sb-state 2>/dev/null)" = "SecureBoot enabled" ]]; then
        echo "$line_separator_small"
        cert="/etc/pki/akmods/certs/public_key.der"
        echo "${process_icon} Secure Boot enabled - \"mokutil\" will prompt you now to set a password to enroll the public key for VirtualBox to work correctly..."
        if sudo mokutil --import "$cert"; then
            echo -e "${success_icon} Password assigned. Reboot and complete enrollment in the MOK manager.\n"
        else
            echo "${error_icon} \"mokutil --import\" failed or was cancelled."
        fi
    fi

    echo "${success_icon} Finished configuring QEMU/KVM/libvirt and VirtualBox."

    echo "$line_separator"

    # Wireshark configuration
    echo "${process_icon} Configuring Wireshark..."
    sudo usermod -aG wireshark "$(whoami)"
    echo "${success_icon} Finished configuring Wireshark."

    echo -e "\n${success_icon} Finished applying configurations."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle applying system/application configurations for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# INSTALLING FLATPAK APPLICATIONS (Flathub)
##################################################

echo -e "\n${section_separator}"
echo 'INSTALLING FLATPAK APPLICATIONS (Flathub)'
echo -e "${section_separator}\n"

echo "${process_icon} Starting installation of Flatpak applications..."

if [[ "$detected_distro" == "Fedora Workstation" ]]; then
    # External Flatpak applications list
    echo -e "\n${process_icon} Installing the provided external list of Flatpak applications..."
    xargs flatpak install flathub -y <"$flatpak_list"
    echo "${success_icon} Finished installing the provided external list of Flatpak applications."

    echo -e "\n${success_icon} Finished installation of Flatpak applications."
else
    echo "${error_icon} Unknown distribution detected. The script does not know how to handle installing Flatpak applications for this system. Exiting..."
    exit "$e_unknown_distro"
fi

##################################################
# HALT FOR REVIEW AND REBOOT
##################################################

echo -e "\n${section_separator}"
echo 'HALT FOR REVIEW AND REBOOT'
echo -e "${section_separator}\n"

read -p "Press [Enter] to reboot the system... "
reboot
