# BoyJack OS on Replit

## Overview

A full graphical desktop OS environment accessible through a web browser. Features a custom boot screen, Fluxbox window manager with a styled taskbar, and pre-launched applications — all served via VNC over noVNC.

**Now with ISO support!** Build a bootable ISO image to distribute and run on physical hardware or virtual machines. See `ISO_BUILD.md` for details.

## User Flow

1. **`/`** → redirects to `/boyjack-boot.html`
2. **`/boyjack-boot.html`** → animated boot screen (starfield, progress bar, kernel log)
3. After 100% → white flash → **`/vnc.html?autoconnect=true`**
4. VNC auto-connects → **Fluxbox desktop** with taskbar and apps ready

## Architecture

| Component | Role |
|-----------|------|
| `Xvnc` (TigerVNC) | Headless X11 display server, port 5901 |
| `Fluxbox` | Window manager with themed taskbar |
| `websockify` | WebSocket proxy, serves `www/` on port 5000 |
| `boyjack-boot.html` | Custom animated boot screen |
| `www/` | Web root: noVNC files + custom pages |

## Desktop Applications

- **Terminal** — `xterm` with cyan-on-navy BoyJack theme
- **Browser** — Firefox
- **File Manager** — PCManFM
- **Text Editor** — Gedit

Right-click on the desktop to open the app launcher menu.

## Workspaces

4 workspaces: `Main`, `Work`, `Media`, `Files`  
Switch with `Ctrl+F1–F4`

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Alt+F2` | Open Terminal |
| `Alt+F3` | Open File Manager |
| `Super+D` | Open Desktop Menu |
| `Alt+Tab` | Switch Windows |
| `Alt+F4` | Close Window |
| `Ctrl+F1–F4` | Switch Workspace |

## System Dependencies (Nix)

`novnc`, `tigervnc`, `xterm`, `twm`, `fluxbox`, `firefox`, `gedit`, `pcmanfm`, `feh`, `xorg.xinit`, `xorg.xauth`, `xorg.xsetroot`

## start.sh Sequence

1. Clean VNC locks
2. Build `www/` from noVNC files + inject custom pages
3. Write Fluxbox config (`~/.fluxbox/init`, `menu`, `keys`, `style`)
4. Start `Xvnc :1` at 1280×800 on port 5901
5. Set wallpaper via `xsetroot`
6. Start `fluxbox`
7. Launch `xterm` (BoyJack Terminal)
8. Start `websockify` on `0.0.0.0:5000`

## Building an ISO

Create a bootable ISO image for distribution:

```bash
bash build-iso.sh
```

This produces `boyjack-os.iso` that can be:
- Written to USB and booted on physical machines
- Used in virtual machines (VirtualBox, KVM, QEMU)
- Shared for download/distribution

See `ISO_BUILD.md` for full documentation on building, customizing, and using the ISO.

## Production Release v1.0 (March 13, 2026)

### System Features ✅
- VNC server (port 5901) + WebSocket proxy (port 5000)
- Animated boot screen with HTML5 starfield
- Fluxbox window manager with dark cyberpunk theme
- 4 virtual workspaces (Main, Work, Media, Files)
- Pre-launched terminal + app launcher widget
- Firefox, File Manager, Text Editor (on-demand)
- Complete keyboard shortcut support
- Network-accessible desktop (local + remote)

### Documentation 📚
- **USER_GUIDE.md** — 500+ line comprehensive user manual
  - Getting started guide
  - Desktop environment tutorial
  - Application reference
  - Keyboard shortcuts
  - Troubleshooting section
  - Quick reference card

- **DEPLOYMENT.md** — Multi-platform deployment guide
  - Replit cloud deployment (current)
  - Docker containerization
  - Virtual machine setup
  - Bare metal installation
  - Security considerations
  - Performance tuning
  - Troubleshooting checklist

- **ISO_BUILD.md** — ISO building & distribution
  - Build instructions with xorriso
  - Virtual machine setup
  - USB installation guide
  - Network access documentation

- **replit.md** — Technical architecture (this file)

### Scripts & Components
- `start.sh` — 460+ lines, fully documented startup system
- `start_button.tcl` — 380+ lines, fully documented app launcher
- `build-iso.sh` — ISO builder (requires xorriso)
- `test-iso-build.sh` — Package verification & tar.gz creation
- `boyjack-boot.html` — Animated boot screen
- `www/` — noVNC web client files (171 files)

### Distribution & Deployment
✅ **Distribution Package:**
- `boyjack-os-v1.0.tar.gz` (333KB) — Complete system
- `boyjack-os-v1.0.tar.gz.sha256` — Integrity checksum

✅ **Already Deployed:**
- Running on Replit as `vm` (always-on)
- Web access: `http://localhost:5000`
- VNC access: `localhost:5901`

✅ **Deployment Options:**
- Cloud (Replit) — Already running
- Docker container — Documented in DEPLOYMENT.md
- Virtual machine — Full ISO buildable
- Bare metal — USB bootable ISO
- Remote access — Network-enabled

## Deployment

Configured as `vm` (always-running) since it requires persistent process state. The ISO can also be deployed as a standalone bootable image on compatible hardware.
