# BoyJack OS ISO Builder

## Overview

Create a bootable ISO image of BoyJack OS that can be distributed and installed on physical machines or run in virtual environments.

## Quick Start

### Build the ISO

```bash
# Simple way (if tools are installed):
bash build-iso.sh

# With Nix shell (includes required tools):
nix-shell -p xorriso --run "bash build-iso.sh"
```

The script will create `boyjack-os.iso` in the current directory.

## What's Included

The ISO includes:
- **BoyJack Boot Screen** — Custom animated startup sequence
- **VNC Server** — TigerVNC on port 5901
- **Web Interface** — noVNC on port 5000
- **Fluxbox Desktop** — Window manager with taskbar and menu
- **Pre-installed Apps** — Terminal, Firefox, File Manager, Text Editor
- **Configuration Files** — Fluxbox themes, keyboard shortcuts, app menu
- **Full Documentation** — README with system info and shortcuts

## Using the ISO

### On Physical Hardware

Write the ISO to a USB drive:
```bash
sudo dd if=boyjack-os.iso of=/dev/sdX bs=4M && sync
```

Then boot from the USB. Replace `/dev/sdX` with your USB device (check with `lsblk`).

### In a Virtual Machine

- **VirtualBox**: Create new VM → Use ISO as boot disk
- **QEMU**: `qemu-system-x86_64 -cdrom boyjack-os.iso -m 2G`
- **KVM**: Similar to QEMU

### Accessing the Desktop

Once booted:

1. **Local VNC** (on the machine running BoyJack OS):
   - Connect to `localhost:5901` with a VNC viewer
   - Or open `http://localhost:5000/vnc.html` in a browser

2. **Remote Access** (from another machine):
   - Open `http://<machine-ip>:5000/vnc.html` in a browser
   - VNC viewers can connect to `<machine-ip>:5901`

## System Requirements

### Minimum
- x86_64 processor with virtualization support
- 1GB RAM
- 500MB disk space
- Network interface (Ethernet or WiFi)

### Recommended
- 2GB RAM
- 2+ CPU cores
- 1GB disk space
- Wired network for better performance

## Boot Modes

The ISO presents two boot options:

1. **Standard Mode** — Normal graphical boot with Fluxbox desktop
2. **Debug Mode** — Kernel debug output enabled for troubleshooting

## Customization

To modify what's included in the ISO, edit `build-iso.sh`:

- Add files to `$ISO_ROOT` before ISO creation
- Modify `boyjack/` directory structure
- Edit `boot/grub/grub.cfg` for boot menu options

Then rebuild with `bash build-iso.sh`.

## Troubleshooting

### ISO creation fails with "command not found"

Install the required tools:
```bash
nix-shell -p xorriso
bash build-iso.sh
```

### Boot hangs at startup

- Check system meets minimum requirements
- Try Debug Mode from boot menu
- Ensure adequate RAM allocation (if in VM)

### Cannot connect to VNC

- Check firewall allows ports 5901 and 5000
- Verify BoyJack OS booted successfully
- Try connecting from the same machine first
- Check `systemctl status` for service status (if using systemd)

### Poor performance

- Allocate more RAM in VM settings
- Use wired network instead of WiFi
- Close unnecessary applications on desktop

## Distribution

The ISO is self-contained and can be:
- Burned to physical DVD/Blu-ray
- Written to USB drive
- Used as VM boot disk
- Hosted for download on a web server

No additional dependencies or installation is needed beyond a standard x86_64 boot environment.

## Version Info

- **BoyJack OS v1.0**
- Based on noVNC + TigerVNC + Fluxbox + NixOS
- Boot screen: Custom HTML5 animation
- Theme: Cyberpunk dark (cyan/blue/navy)

## License

Same as BoyJack OS project (see LICENSE file)
