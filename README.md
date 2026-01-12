
# Linux on Android Manager

![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Linux](https://img.shields.io/badge/Userspace-GNU%2FLinux-FCC624?logo=linux&logoColor=black)
![No Root](https://img.shields.io/badge/Privilege-No%20Root%20Required-success)

---

## Project Description

**Linux on Android Manager** is an interactive, all-in-one script for installing, configuring, and uninstalling Linux distributions on Android devices via **Termux** and **proot-distro**, without requiring root access.  

This project started as a personal experiment to **repurpose old Android devices**. Being experienced in programming and aware of the power of Linux, I realized that since Android uses the Linux kernel, it should be possible to run full Linux on it. After researching and trying multiple methods, I developed a **custom lightweight setup** optimized to run on older devices with limited CPU power and low RAM.  

Features include:

- Install multiple distributions (Debian, Ubuntu, Arch, Fedora, Alpine)  
- Create non-root users with sudo access  
- Optional lightweight desktop environment (LXDE) via **VNC**  
- Interactive prompts for username, distro, and VNC resolution  
- Built-in aliases for convenience (`startvnc`, `stopvnc`, `login`)  
- Safe uninstall functionality  

This tool provides a **beginner-friendly, reversible, and efficient Linux environment** on Android, ideal for breathing new life into older devices.

---

## ⚠️ Disclaimer

- No root is required. Android system remains untouched.  
- Performance depends on device hardware.  
- Desktop environments run via **VNC**, which may consume extra battery.  
- Use at your own risk.

---

## Requirements

- Android 8.0+ (ARM64 recommended)  
- 4–6 GB free storage  
- Stable internet connection  
- VNC client (RealVNC, bVNC, etc.)  

---

## Installation Instructions

1. Install **Termux** from [F-Droid](https://f-droid.org/packages/com.termux/).  
2. Download or clone this repository:

```bash
git clone https://github.com/uzairmukadam/linux-on-android.git
cd linux-on-android
```

3. Make the script executable:

```bash
chmod +x linux-on-android.sh
```

4. Run the script:

```bash
./linux-on-android.sh
```

5. Follow the on-screen prompts to:

- Choose a Linux distribution  
- Enter a non-root username  
- Optionally install LXDE + VNC  
- Optionally select VNC resolution  

---

## Features of the Interactive Script

- Lists available Linux distributions automatically.  
- Creates a non-root user and grants sudo privileges.  
- Automatically switches to the new user after creation.  
- Optional installation of LXDE desktop environment and TightVNC server.  
- Prompts user for VNC resolution (default 1920x1080).  
- Adds convenient aliases inside the distro:

```bash
startvnc   # Start desktop
stopvnc    # Stop desktop
login      # Login to distro
```

- Allows safe uninstallation of Linux distros and optional removal of `proot-distro`.  

---

## Using VNC

1. Start desktop environment:

```bash
startvnc
```

2. Stop desktop environment:

```bash
stopvnc
```

3. Connect via any VNC client to:

```
localhost:5901
```

---

## Uninstalling a Linux Distro

1. Run the script:

```bash
./linux-on-android.sh
```

2. Choose the **Uninstall** option.  
3. Select the distro to remove.  
4. Confirm the removal.  
5. Optionally remove `proot-distro`.

---

## Supported Distributions

- Debian (recommended)  
- Ubuntu  
- Arch Linux  
- Alpine  
- Fedora  

---

## Known Limitations

- No systemd support  
- No GPU acceleration  
- Battery drain during GUI usage  
- Some packages may require additional configuration  