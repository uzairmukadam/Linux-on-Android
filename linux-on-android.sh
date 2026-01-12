#!/bin/bash
set -e

# ===== Colors =====
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RESET="\033[0m"
BOLD="\033[1m"

CONFIG_DIR="$PREFIX/etc/linux-on-android"
mkdir -p "$CONFIG_DIR"

menu() {
    echo -e "${CYAN}${BOLD}=== Linux on Android Manager ===${RESET}"
    echo -e "${YELLOW}1) Install a Linux distro${RESET}"
    echo -e "${YELLOW}2) Uninstall a specific distro${RESET}"
    echo -e "${YELLOW}3) Uninstall ALL distros${RESET}"
    echo -e "${YELLOW}4) Exit${RESET}"
    read -p "Choose an option: " CHOICE

    case "$CHOICE" in
        1) install_linux ;;
        2) uninstall_one ;;
        3) uninstall_all ;;
        4) exit 0 ;;
        *) echo -e "${RED}Invalid choice${RESET}"; menu ;;
    esac
}

install_linux() {
    echo -e "${BLUE}Updating Termux packages...${RESET}"
    echo -e "${YELLOW}If you see config pop-ups, press Enter to keep defaults.${RESET}"
    apt update && apt upgrade -y

    if ! command -v proot-distro &> /dev/null; then
        echo -e "${BLUE}Installing proot-distro...${RESET}"
        apt install -y proot-distro
    fi

    echo -e "${CYAN}Available distros:${RESET}"
    proot-distro list

    read -p "Enter distro to install (e.g., debian): " DISTRO
    read -p "Enter username to create: " USERNAME
    read -p "Install LXDE desktop? (y/N): " INSTALL_GUI
    read -p "VNC resolution (default 1920x1080): " RES
    RES=${RES:-1920x1080}

    VNC_PASSWD="1234"

    echo ""
    echo -e "${CYAN}${BOLD}=== Confirm Your Configuration ===${RESET}"
    echo -e "${YELLOW}Distro:        ${RESET}$DISTRO"
    echo -e "${YELLOW}Username:      ${RESET}$USERNAME"
    echo -e "${YELLOW}Install GUI:   ${RESET}$INSTALL_GUI"
    echo -e "${YELLOW}Resolution:    ${RESET}$RES"
    echo -e "${YELLOW}VNC Password:  ${RESET}$VNC_PASSWD"
    echo ""
    read -p "Proceed with installation? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
        echo -e "${RED}Installation cancelled.${RESET}"
        exit 0
    fi

    echo -e "${BLUE}Installing $DISTRO...${RESET}"
    proot-distro install "$DISTRO"

    echo -e "${BLUE}Configuring inside $DISTRO...${RESET}"

    proot-distro login "$DISTRO" -- bash -lc "
apt update && apt upgrade -y

apt install -y sudo passwd

useradd -m -s /bin/bash $USERNAME
passwd -d $USERNAME 2>/dev/null || true

echo \"$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL\" > /etc/sudoers.d/$USERNAME
chmod 440 /etc/sudoers.d/$USERNAME

if [[ \"$INSTALL_GUI\" =~ ^[yY]$ ]]; then
    apt install -y lxde tightvncserver
fi
"

    if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
    proot-distro login "$DISTRO" -- bash -lc "
if ! command -v vncserver >/dev/null; then
    echo -e '${RED}VNC installation failed. Skipping setup.${RESET}'
    exit 0
fi

echo -e '${BLUE}Cleaning stale VNC lock files...${RESET}'
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

sudo -u $USERNAME bash -lc '
mkdir -p /home/$USERNAME/.vnc
echo \"$VNC_PASSWD\" | vncpasswd -f > /home/$USERNAME/.vnc/passwd
chmod 600 /home/$USERNAME/.vnc/passwd

cat > /home/$USERNAME/.vnc/xstartup <<EOS
#!/bin/bash
xrdb \$HOME/.Xresources
exec startlxde &
EOS

chmod +x /home/$USERNAME/.vnc/xstartup

vncserver -geometry $RES :1 || true
vncserver -kill :1 || true
'
"
    fi

    echo -e "${BLUE}Saving config...${RESET}"
    cat > "$CONFIG_DIR/$DISTRO.conf" <<EOF
DISTRO=$DISTRO
USERNAME=$USERNAME
GUI=$INSTALL_GUI
RESOLUTION=$RES
VNC_PASSWD=$VNC_PASSWD
EOF

    echo -e "${GREEN}${BOLD}=== Installation complete! ===${RESET}"
    echo -e "${CYAN}Login with:${RESET}      proot-distro login $DISTRO --"
    echo -e "${CYAN}Switch user:${RESET}     su - $USERNAME"
    [[ "$INSTALL_GUI" =~ ^[yY]$ ]] && echo -e "${CYAN}Start VNC:${RESET}       vncserver -geometry $RES :1"
    echo -e "${CYAN}Stop VNC:${RESET}        vncserver -kill :1"
    echo -e "${CYAN}VNC password:${RESET}    $VNC_PASSWD"
}

uninstall_one() {
    if ! ls "$CONFIG_DIR"/*.conf &>/dev/null; then
        echo -e "${RED}No installed distros found.${RESET}"
        return
    fi

    echo -e "${CYAN}Installed distros:${RESET}"
    ls "$CONFIG_DIR" | sed 's/.conf$//'

    read -p "Enter distro to uninstall: " DISTRO

    CONFIG_FILE="$CONFIG_DIR/$DISTRO.conf"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${RED}No config found for $DISTRO${RESET}"
        exit 1
    fi

    read -p "Remove distro '$DISTRO'? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
        echo -e "${YELLOW}Uninstall cancelled.${RESET}"
        exit 0
    fi

    proot-distro remove "$DISTRO" || true
    rm -f "$CONFIG_FILE"

    echo -e "${GREEN}Removed $DISTRO${RESET}"
}

uninstall_all() {
    if ! ls "$CONFIG_DIR"/*.conf &>/dev/null; then
        echo -e "${RED}No installed distros found.${RESET}"
        return
    fi

    echo -e "${RED}${BOLD}This will remove ALL installed distros and configs.${RESET}"
    read -p "Are you sure? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
        echo -e "${YELLOW}Uninstall cancelled.${RESET}"
        exit 0
    fi

    for FILE in "$CONFIG_DIR"/*.conf; do
        [[ -e "$FILE" ]] || continue
        source "$FILE"
        if [[ -n "$DISTRO" ]]; then
            echo -e "${BLUE}Removing $DISTRO...${RESET}"
            proot-distro remove "$DISTRO" || true
        fi
        rm -f "$FILE"
    done

    echo -e "${GREEN}All distros removed.${RESET}"

    read -p "Remove proot-distro as well? (y/N): " REMOVE_PROOT
    if [[ "$REMOVE_PROOT" =~ ^[yY]$ ]]; then
        apt remove -y proot-distro || true
    fi

    echo -e "${GREEN}Cleanup complete.${RESET}"
}

menu
