# BoyJack OS v1.0 — Complete User Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [System Access](#system-access)
3. [Desktop Environment](#desktop-environment)
4. [Applications](#applications)
5. [Keyboard Shortcuts](#keyboard-shortcuts)
6. [Workspaces](#workspaces)
7. [Network Access](#network-access)
8. [Troubleshooting](#troubleshooting)
9. [System Requirements](#system-requirements)

---

## Getting Started

### What is BoyJack OS?

BoyJack OS is a full graphical desktop operating system that runs completely in your browser via VNC (Virtual Network Computing). It features:

- Custom animated boot screen with sci-fi styling
- Lightweight Fluxbox window manager
- 4 virtual workspaces for multitasking
- Pre-configured applications (Terminal, Firefox, File Manager, Text Editor)
- Dark cyberpunk-inspired visual theme
- Network-accessible desktop via WebSocket

### First Launch

When you start BoyJack OS:

1. **Boot Screen** — You'll see an animated starfield with a progress bar
2. **Desktop Loads** — After 10 seconds, the animated boot completes
3. **Ready to Use** — Desktop appears with taskbar at the bottom

The boot sequence happens automatically. No interaction required.

---

## System Access

### Local Access (Same Machine)

**Via Web Browser:**
```
http://localhost:5000          (boot screen + redirects)
http://localhost:5000/vnc.html (VNC client)
```

**Via VNC Viewer App:**
```
localhost:5901
```

### Remote Access (From Another Machine)

Replace `localhost` with the machine's IP address or hostname:

```
http://192.168.1.100:5000/vnc.html  (from another computer on network)
192.168.1.100:5901                  (with VNC viewer app)
```

### Keyboard/Mouse Controls

- **Click to focus** windows (point-and-click interaction)
- **Drag windows** by their title bar to move them
- **Resize windows** by dragging the bottom-right corner
- **Right-click desktop** to open the application menu

---

## Desktop Environment

### The Taskbar

Located at the **bottom of the screen**, the taskbar shows:

```
[BJ Start] | Workspace Names | Active Windows | Clock
```

- **[BJ Start]** — Click to open the application menu
- **Workspace Names** — Shows which workspace is active (Main, Work, Media, Files)
- **Active Windows** — Currently open applications
- **Clock** — Current time in HH:MM format with day/date

### Window Decorations

Each window has:

```
┌─────────────────────────────────┐
│ ⊡ Window Title           _ □ ✕  │  ← Title bar with buttons
│                                 │
│         Window Content          │
│                                 │
└─────────────────────────────────┘
```

- **Minimize (\_)** — Hides window to taskbar
- **Maximize (□)** — Expands to full screen
- **Close (✕)** — Closes the window

### Color Scheme

The dark cyberpunk theme uses:

| Element | Color |
|---------|-------|
| Background | Deep Navy (#0a0e1a) |
| Accents | Cyan (#00f5ff) |
| Highlights | Electric Blue (#0066ff) |
| Text | Light Gray-Blue (#c0d8f0) |

This theme is consistent across all windows, menus, and widgets.

---

## Applications

### Pre-Launched Applications

**Terminal** — Automatically open when desktop loads

The terminal is ready for command-line work. Features:
- Cyan text on navy background
- Monospace font (11pt)
- 90 columns × 28 rows
- Located in top-left corner

Use the Terminal to:
- Run shell commands
- Edit files with text editors (nano, vi, etc.)
- Compile and run programs
- Navigate the filesystem

### Available Applications

Access these via the Start Button menu or keyboard shortcuts:

#### 1. **Firefox Browser**
- Web browsing and development
- Access via: Start Menu → "Firefox Browser" or Alt+F2 then type `firefox`
- Full HTML5 support

#### 2. **File Manager (PCManFM)**
- Browse folders and files
- Access via: Start Menu → "File Manager" or **Alt+F3**
- Features: Copy/paste, drag-drop, multiple windows

#### 3. **Text Editor (gedit)**
- Edit text files
- Access via: Start Menu → "Text Editor"
- Features: Syntax highlighting, search/replace

#### 4. **Terminal (xterm)**
- Open additional terminals
- Access via: Start Menu → "Terminal" or **Alt+F2**
- Each terminal is independent

#### 5. **System Options**
- Restart Desktop (Fluxbox restart)
- Access via: Start Menu at bottom

### Start Button Menu

Click the **"[BJ Start]"** button on the taskbar to toggle the application menu:

```
┌──────────────────┐
│ BoyJack OS v1.0  │
├──────────────────┤
│ FF Firefox       │
│ FM File Manager  │
│ ED Text Editor   │
│ T> Terminal      │
├──────────────────┤
│ RR Restart       │
└──────────────────┘
```

- **Click an item** to launch that application
- **Hover** to highlight items
- **Click outside** the menu to close it

---

## Keyboard Shortcuts

### Essential Shortcuts

| Shortcut | Action |
|----------|--------|
| **Alt+F2** | Open Terminal (or another instance) |
| **Alt+F3** | Open File Manager |
| **Alt+Tab** | Cycle through open windows |
| **Alt+F4** | Close the focused window |

### Workspace Navigation

| Shortcut | Action |
|----------|--------|
| **Ctrl+F1** | Switch to "Main" workspace |
| **Ctrl+F2** | Switch to "Work" workspace |
| **Ctrl+F3** | Switch to "Media" workspace |
| **Ctrl+F4** | Switch to "Files" workspace |

### Window Management

| Shortcut | Action |
|----------|--------|
| **Super+D** | Open desktop menu (right-click alternative) |
| **Super+E** | Open Terminal (alternative to Alt+F2) |
| **Click Title Bar** | Drag to move window |
| **Drag Corner** | Resize window |

### Desktop Menu

Right-click the empty desktop to open a context menu with:
- All available applications
- Workspace selector
- System options

---

## Workspaces

### What are Workspaces?

Virtual workspaces let you organize windows across multiple "screens" without losing them. Each workspace is independent.

### The 4 Workspaces

| Workspace | Purpose | Example Use |
|-----------|---------|------------|
| **Main** | Primary work area | General use |
| **Work** | Development/productivity | Coding, documents |
| **Media** | Content creation | Images, videos |
| **Files** | File management | Organizing files |

### Switching Between Workspaces

1. **Via Keyboard:** Ctrl+F1, Ctrl+F2, Ctrl+F3, or Ctrl+F4
2. **Via Taskbar:** Click the workspace name button
3. **Via Right-Click Menu:** Select from the Workspaces submenu

### Moving Windows Between Workspaces

1. Open the window's context menu (right-click title bar)
2. Select "Move to..." and choose the destination workspace
3. Or use the window manager configuration

---

## Network Access

### Local Network Access

If BoyJack OS is running on a server or remote machine:

1. **Find the IP address:**
   ```bash
   hostname -I
   # or
   ifconfig
   ```

2. **Access from another machine:**
   - Open browser: `http://<IP>:5000/vnc.html`
   - Or use VNC viewer: Connect to `<IP>:5901`

3. **Firewall Considerations:**
   - Port 5901 (VNC) must be accessible
   - Port 5000 (WebSocket) must be accessible
   - Consider network security policies

### Multiple Users

Multiple users can connect simultaneously via VNC. Each connection:
- Sees the same desktop
- Can interact with the same windows
- Sees other users' cursor movements

---

## Troubleshooting

### Desktop Won't Load

**Problem:** Blank or frozen screen

**Solutions:**
1. Wait 15 seconds (boot takes time)
2. Hard-refresh the browser (Ctrl+Shift+R)
3. Check browser console for errors (F12)
4. Restart the application

### Applications Won't Launch

**Problem:** Clicking menu items does nothing

**Solutions:**
1. Ensure the VNC connection is active
2. Check that terminal is not filling the screen
3. Try using keyboard shortcuts instead (Alt+F2, Alt+F3)
4. Check system resources (RAM, CPU)

### Slow Performance

**Problem:** Desktop is sluggish or unresponsive

**Solutions:**
1. Close unnecessary applications
2. Check network latency (VNC works best on fast networks)
3. Reduce screen resolution in VNC viewer settings
4. Allocate more RAM if running in VM

### VNC Connection Drops

**Problem:** Connection disconnects unexpectedly

**Solutions:**
1. Check network stability
2. Look for firewall blocks on ports 5901/5000
3. Check if websockify process is running
4. Restart the application

### Terminal Commands Not Working

**Problem:** Command not found errors

**Solutions:**
1. Check the command is installed: `which command_name`
2. Verify the command path
3. Install missing packages via apt, yum, etc.
4. Check file permissions

---

## System Requirements

### Minimum

- **Processor:** x86_64 with virtualization support
- **RAM:** 1GB
- **Disk:** 500MB free space
- **Network:** Internet connection (for network access)
- **Browser:** Modern web browser (Chrome, Firefox, Safari, Edge)

### Recommended

- **RAM:** 2GB or more
- **Network:** Wired connection (better than WiFi)
- **CPU:** 2+ cores
- **Disk:** 1GB free space
- **Browser:** Latest version of Firefox or Chrome

### Supported Platforms

**As a Server:**
- Linux (any distribution)
- macOS
- Windows (via WSL2 or Docker)

**As a Client (VNC Viewer):**
- Any OS with VNC client software
- Any web browser (no installation needed)

---

## Advanced Usage

### Custom Configuration

BoyJack OS startup is controlled by `start.sh`. Advanced users can:

1. **Change resolution:** Edit the `Xvnc` command in `start.sh` (default: 1280×800)
2. **Modify theme:** Edit Fluxbox configuration in `start.sh`
3. **Pre-launch apps:** Add commands to the startup sequence
4. **Adjust ports:** Change 5901 (VNC) or 5000 (WebSocket)

### Accessing Files

Terminal commands for file operations:

```bash
ls              # List files
cd folder       # Change directory
pwd             # Show current path
cp file dest    # Copy file
mv file dest    # Move file
rm file         # Delete file
mkdir folder    # Create folder
```

### Installing Software

In the terminal, install packages with your distribution's package manager:

```bash
# Debian/Ubuntu
apt update && apt install package_name

# RedHat/CentOS
yum install package_name

# Alpine
apk add package_name
```

---

## Getting Help

### Documentation

- **README.md** — Technical overview
- **ISO_BUILD.md** — ISO building guide
- **replit.md** — System architecture

### Common Resources

- **Desktop Menu:** Right-click desktop for quick access
- **Start Button:** Click [BJ Start] for application menu
- **Terminal:** Use `man command_name` for command help

---

## Quick Reference Card

```
╔════════════════════════════════════════════════════════╗
║             BoyJack OS Quick Reference                ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║ ACCESS:                      SHORTCUTS:               ║
║  Web:  localhost:5000         Terminal:  Alt+F2       ║
║  VNC:  localhost:5901         Files:     Alt+F3       ║
║                               Windows:   Alt+Tab      ║
║ WORKSPACES (Ctrl+F#):         Workspaces: Ctrl+F1-4   ║
║  1: Main                                              ║
║  2: Work                      MENU:                   ║
║  3: Media                      Click [BJ Start]       ║
║  4: Files                      Or right-click         ║
║                                                        ║
║ COLORS:                       RESOLUTION:             ║
║  Background: Navy (#0a0e1a)   1280×800 (default)      ║
║  Text: Cyan (#00f5ff)                                 ║
║  Accent: Electric Blue        THEME:                  ║
║                                Dark Cyberpunk         ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

---

**For support or feature requests, see the project documentation.**

**Version:** 1.0  
**Last Updated:** March 13, 2026  
**License:** See LICENSE file
