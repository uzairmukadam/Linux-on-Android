#!/bin/bash
set -e

echo "👋 Welcome to Linux on Android Manager"

# ----------------------------
# Step 0: Update Termux
# ----------------------------
echo "🔄 Updating Termux packages..."
apt update && apt upgrade -y

# ----------------------------
# Step 1: Install proot-distro if missing
# ----------------------------
if ! command -v proot-distro &> /dev/null; then
    echo "📦 Installing proot-distro..."
    apt install proot-distro -y
fi

# ----------------------------
# Step 2: Choose Action
# ----------------------------
echo "What do you want to do?"
echo "1) Install a Linux distro"
echo "2) Uninstall a Linux distro"
read -p "Enter 1 or 2: " ACTION

# ----------------------------
# INSTALLATION FLOW
# ----------------------------
if [[ "$ACTION" == "1" ]]; then
    echo "📋 Available Linux distributions:"
    proot-distro list

    read -p "Enter the distro you want to install (e.g., debian, ubuntu): " DISTRO
    read -p "Enter the username you want to create inside Linux: " LINUX_USER
    read -p "Do you want to install a desktop environment (LXDE + VNC)? (y/N): " INSTALL_GUI

    if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
        echo "Available resolutions: 1024x768, 1280x720, 1920x1080"
        read -p "Enter desired VNC resolution (default 1920x1080): " VNC_RES
        VNC_RES=${VNC_RES:-1920x1080}
    fi

    echo "--------------------------------"
    echo "Linux Distro: $DISTRO"
    echo "Username: $LINUX_USER"
    echo "Install Desktop: $INSTALL_GUI"
    [[ -n "$VNC_RES" ]] && echo "VNC Resolution: $VNC_RES"
    echo "--------------------------------"
    read -p "Proceed with installation? (y/N): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[yY]$ ]] && echo "Aborting." && exit 0

    echo "🚀 Installing $DISTRO..."
    proot-distro install "$DISTRO"

    echo "🎉 Installation complete!"
    echo "Configuring user inside $DISTRO..."

    # Essential packages + user creation
    proot-distro login "$DISTRO" -- /bin/bash <<EOF
apt update && apt upgrade -y

# Install essential packages
apt install -y sudo passwd adduser apt-utils dialog tzdata

echo "👤 Creating user '$LINUX_USER'..."
adduser --gecos "" "$LINUX_USER"
usermod -aG sudo "$LINUX_USER"

# Add aliases to the user's .bashrc
echo "📌 Adding aliases..."
cat >> /home/$LINUX_USER/.bashrc <<EOD
alias login='proot-distro login $DISTRO'
EOD

# Add VNC aliases only if GUI is selected
if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
cat >> /home/$LINUX_USER/.bashrc <<EOD
alias startvnc='vncserver -geometry $VNC_RES :1'
alias stopvnc='vncserver -kill :1'
EOD
fi

chown $LINUX_USER:$LINUX_USER /home/$LINUX_USER/.bashrc
EOF

    # GUI Setup
    if [[ "$INSTALL_GUI" =~ ^[yY]$ ]]; then
        echo "🖥 Setting up LXDE + VNC..."

        proot-distro login "$DISTRO" -- /bin/bash <<EOF
apt update
apt install -y lxde lxterminal tightvncserver

# Run VNC setup as the new user
sudo -u $LINUX_USER bash <<EOD
vncserver :1
vncserver -kill :1

mkdir -p /home/$LINUX_USER/.vnc
cat > /home/$LINUX_USER/.vnc/xstartup <<'EOS'
#!/bin/bash
xrdb \$HOME/.Xresources
startlxde &
EOS

chmod +x /home/$LINUX_USER/.vnc/xstartup
EOD

EOF

        echo "✅ Desktop setup complete!"
    fi

    echo "🎉 Installation finished!"
    echo "Login with: proot-distro login $DISTRO"
    [[ "$INSTALL_GUI" =~ ^[yY]$ ]] && echo "Start desktop with: startvnc"

# ----------------------------
# UNINSTALL FLOW
# ----------------------------
elif [[ "$ACTION" == "2" ]]; then
    echo "📋 Installed Linux distributions:"
    proot-distro list

    read -p "Enter the distro you want to uninstall: " DISTRO_REMOVE
    read -p "⚠️ Are you sure you want to remove '$DISTRO_REMOVE'? (y/N): " CONFIRM_REMOVE
    [[ ! "$CONFIRM_REMOVE" =~ ^[yY]$ ]] && echo "Aborting." && exit 0

    echo "🗑 Removing $DISTRO_REMOVE..."
    proot-distro remove "$DISTRO_REMOVE"
    echo "✅ $DISTRO_REMOVE removed!"

    read -p "Remove proot-distro too? (y/N): " REMOVE_PROOT
    [[ "$REMOVE_PROOT" =~ ^[yY]$ ]] && apt remove proot-distro -y && echo "✅ proot-distro removed!"

else
    echo "❌ Invalid option. Exiting."
    exit 1
fi
