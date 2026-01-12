# Linux on Android

![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Linux](https://img.shields.io/badge/Userspace-GNU%2FLinux-FCC624?logo=linux&logoColor=black)
![No Root](https://img.shields.io/badge/Privilege-No%20Root%20Required-success)

---

## 📌 Overview

**Linux on Android** is a powerful, beginner‑friendly automation script that installs, configures, and manages full Linux distributions on Android devices using **Termux** and **proot-distro**, all **without requiring root access**.

This tool revives older Android phones and tablets by turning them into lightweight Linux machines. It provides a reversible, customizable, and user‑friendly environment that runs entirely in userspace. Whether you're learning Linux, coding on the go, or building a portable dev machine, this script handles everything for you.

👉 **[Manual Installation Guide](docs/MANUAL-INSTALL.md)** For users who prefer to install everything manually.

---

## ✨ Key Features

### 🐧 Multi‑Distro Support
Install and manage **multiple Linux distributions simultaneously**, each with its own configuration:

- **Debian** (recommended)
- **Ubuntu**
- **Arch Linux**
- **Alpine**
- **Fedora**
- And any other distro supported by `proot-distro`

### 👤 User Creation
- Automatically creates a secure non‑root user  
- Grants `sudo` privileges  
- Ensures all essential packages (`sudo`, `adduser`, `passwd`, etc.) are installed  

### 🖥️ Optional Desktop Environment
- Install **LXDE** for a lightweight graphical desktop  
- Access via **VNC**  
- Auto‑generated aliases:
  - `startvnc` — launch desktop  
  - `stopvnc` — stop desktop  

### 🧩 Per‑Distro Configuration
Each installation generates a config file stored in:

```
$PREFIX/etc/linux-on-android/<distro>.conf
```

This enables:

- Clean uninstall per distro  
- Accurate tracking of usernames, GUI settings, and VNC resolution  
- Support for multiple simultaneous installations  

### 🗑️ Robust Uninstallation
- Uninstall a **specific distro**  
- Or uninstall **all distros at once**  
- Optional removal of `proot-distro`  
- Automatic cleanup of config files  

### ⚡ Optimized for Low‑End Devices
- Works on older phones/tablets  
- Lightweight desktop  
- Minimal resource usage  

---

## ⚠️ Disclaimer

- No root access is required; your Android system remains untouched.
- Performance varies by device hardware.
- Desktop environments via VNC may consume additional battery.
- Use responsibly and at your own discretion.

---

## 📦 Requirements

- Android **8.0+** (ARM64 strongly recommended)
- **Termux** (from F-Droid)
- **4–6 GB** free storage
- Stable internet connection
- Optional: VNC client (RealVNC, bVNC, etc.)

---

## 🚀 Installation

1. Install **Termux** from F-Droid:  
   https://f-droid.org/packages/com.termux/

2. Update Termux packages and install Git:

   ```bash
   apt update && apt upgrade -y
   apt install git -y
   ```

3. Clone the repository:

   ```bash
   git clone https://github.com/uzairmukadam/linux-on-android.git
   cd linux-on-android
   ```

4. Make the script executable:

   ```bash
   chmod +x linux-on-android.sh
   ```

5. Run the script:

   ```bash
   ./linux-on-android.sh
   ```

6. Follow the interactive prompts to:
   - Select a Linux distribution  
   - Create a username  
   - Choose whether to install LXDE + VNC  
   - Pick a VNC resolution  
   - Complete the guided setup  

---

## 🖥️ Using the Desktop (VNC)

If you installed LXDE, start the desktop with:

```bash
startvnc
```

Stop it with:

```bash
stopvnc
```

Connect using any VNC viewer to:

```
localhost:5901
```

---

## 🗑️ Uninstalling Linux Distros

### Remove a specific distro
1. Run the script:

   ```bash
   ./linux-on-android.sh
   ```

2. Select **Uninstall a specific distro**  
3. Choose the distro  
4. Confirm removal  

### Remove ALL distros
1. Run:

   ```bash
   ./linux-on-android.sh
   ```

2. Select **Uninstall ALL distros**  
3. Confirm  
4. Optionally remove `proot-distro`  

All associated config files are removed automatically.

---

## 🐧 Supported Distributions

- **Debian** (recommended for stability)
- **Ubuntu**
- **Arch Linux**
- **Alpine Linux**
- **Fedora**
- And many others supported by `proot-distro`

---

## ⚠️ Known Limitations

- No **systemd** support (proot limitation)
- No hardware GPU acceleration
- GUI sessions may drain battery faster
- Some packages may require manual configuration

---

## ❤️ Why This Project Exists

Android devices often outlive their intended purpose, yet their hardware remains surprisingly capable.  
This project aims to:

- Extend the life of older phones/tablets  
- Provide a portable Linux development environment  
- Offer a safe, beginner-friendly way to explore Linux  
- Enable experimentation without modifying the Android system  

If you enjoy tinkering, learning, or building on the go, this tool gives you a clean, flexible Linux environment right in your pocket.

---

## 📬 Contributions

Contributions, improvements, and suggestions are always welcome.  
Feel free to open an issue or submit a pull request.

