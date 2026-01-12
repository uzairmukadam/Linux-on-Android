#!/bin/bash
set -e

CONFIG_DIR="$PREFIX/etc/linux-on-android"
mkdir -p "$CONFIG_DIR"

menu() {
    echo "=== Linux on Android Manager ==="
    echo "1) Install a Linux distro"
    echo "2) Uninstall a specific distro"
    echo "3) Uninstall ALL distros"
    echo "4) Exit"
    read -p "Choose an option: " CHOICE

    case "$CHOICE" in
        1) install_linux ;;
        2) uninstall_one ;;
        3) uninstall_all ;;
        4) exit 0 ;;
        *) echo "Invalid choice"; menu ;;
    esac
}

install_linux() {
    echo "Updating Termux packages..."
    echo "If you see any pop-ups about configuration files, press Enter to keep the default option."
    apt update && apt upgrade -y

    if ! command -v proot-distro &> /dev/null; then
        apt install -y proot-distro
    fi

    echo "Available distros:"
    proot-distro list

    read -p "Enter distro to install (e.g., debian): " DISTRO
    read -p "Enter username to create: " USERNAME
    read -p "Install LXDE desktop? (y/N): " INSTALL_GUI
    read -p "VNC resolution (default 1920x1080): " RES
    RES=${RES:-1920x1080}

    VNC_PASSWD="1234"

    echo ""
    echo "=== Confirm Your Configuration ==="
    echo "Distro:         $DISTRO"
    echo "Username:       $USERNAME"
    echo "Install GUI:    $INSTALL_GUI"
    echo "VNC Resolution: $RES"
    echo "VNC Password:   $VNC_PASSWD"
    echo ""
    read -p "Proceed with installation? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    echo "Installing $DISTRO..."
    proot-distro install "$DISTRO"

    echo "Configuring inside $DISTRO..."

    proot-distro login "$DISTRO" -- /bin/bash <<EOF
apt update && apt upgrade -y
apt install -y sudo adduser passwd apt-utils dialog tzdata

adduser --gecos "" "$USERNAME"
passwd -d "$USERNAME"

echo "$USERNAME ALL=(ALL:ALL) ALL" >> /etc/sudoers

if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
    apt install -y lxde lxterminal tightvncserver
fi
EOF

    if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
    proot-distro login "$DISTRO" -- /bin/bash <<EOF
sudo -u "$USERNAME" bash <<EOD
mkdir -p "\$HOME/.vnc"
echo "$VNC_PASSWD" | vncpasswd -f > "\$HOME/.vnc/passwd"
chmod 600 "\$HOME/.vnc/passwd"

vncserver :1
vncserver -kill :1

cat > "\$HOME/.vnc/xstartup" <<'EOS'
#!/bin/bash
xrdb \$HOME/.Xresources
exec startlxde &
EOS

chmod +x "\$HOME/.vnc/xstartup"

echo "alias startvnc='vncserver -geometry $RES :1'" >> "\$HOME/.bashrc"
echo "alias stopvnc='vncserver -kill :1'" >> "\$HOME/.bashrc"
EOD
EOF
    fi

    echo "Saving config..."
    cat > "$CONFIG_DIR/$DISTRO.conf" <<EOF
DISTRO=$DISTRO
USERNAME=$USERNAME
GUI=$INSTALL_GUI
RESOLUTION=$RES
VNC_PASSWD=$VNC_PASSWD
EOF

    echo "Creating Termux alias for $DISTRO..."

    ALIAS_CMD="proot-distro login $DISTRO -- su - $USERNAME"
    if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
        ALIAS_CMD="$ALIAS_CMD -c 'startvnc; bash'"
    else
        ALIAS_CMD="$ALIAS_CMD -c 'bash'"
    fi

    echo "alias launch-$DISTRO=\"$ALIAS_CMD\"" >> "$HOME/.bashrc"

    echo "=== Installation complete! ==="
    echo "Login with:      proot-distro login $DISTRO --"
    echo "Switch user:     su - $USERNAME"
    [[ "$INSTALL_GUI" =~ ^[yY]$ ]] && echo "Start desktop:    startvnc"
    echo "Quick launch:    launch-$DISTRO"
    echo "VNC password:    $VNC_PASSWD"
    echo "Reload aliases:  source ~/.bashrc"
}

uninstall_one() {
    if ! ls "$CONFIG_DIR"/*.conf &>/dev/null; then
        echo "No installed distros found."
        return
    fi

    echo "Installed distros:"
    ls "$CONFIG_DIR" | sed 's/.conf$//'

    read -p "Enter distro to uninstall: " DISTRO

    CONFIG_FILE="$CONFIG_DIR/$DISTRO.conf"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "No config found for $DISTRO"
        exit 1
    fi

    read -p "Remove distro '$DISTRO'? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    proot-distro remove "$DISTRO" || true
    rm -f "$CONFIG_FILE"

    sed -i "/alias launch-$DISTRO=/d" "$HOME/.bashrc" || true

    echo "Removed $DISTRO"
}

uninstall_all() {
    if ! ls "$CONFIG_DIR"/*.conf &>/dev/null; then
        echo "No installed distros found."
        return
    fi

    echo "This will remove ALL installed distros and their configs."
    read -p "Are you sure? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    for FILE in "$CONFIG_DIR"/*.conf; do
        [[ -e "$FILE" ]] || continue
        source "$FILE"
        if [[ -n "$DISTRO" ]]; then
            echo "Removing $DISTRO..."
            proot-distro remove "$DISTRO" || true
        fi
        rm -f "$FILE"
    done

    sed -i "/alias launch-/d" "$HOME/.bashrc" || true

    echo "All distros removed."

    read -p "Remove proot-distro as well? (y/N): " REMOVE_PROOT
    if [[ "$REMOVE_PROOT" =~ ^[yY]$ ]]; then
        apt remove -y proot-distro || true
    fi

    echo "Cleanup complete."
}

menu
