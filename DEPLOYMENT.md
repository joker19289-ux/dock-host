# BoyJack OS — Deployment Guide

## Overview

BoyJack OS can be deployed in multiple ways for different use cases:

## Deployment Options

### 1. Local Development (Current)

**Already Running!**

```
Web Interface: http://localhost:5000
VNC Server: localhost:5901
```

No setup required—the app is already running on Replit.

### 2. Cloud Deployment (Replit)

BoyJack OS is currently deployed on Replit as a long-running application.

**Benefits:**
- Public URL accessible from anywhere
- Always-on server (configured as `vm`)
- No local setup required
- Easy sharing via URL

**Current Configuration:**
- Type: `vm` (persistent, always-running)
- Port: 5000 (web) + 5901 (VNC)
- Domain: Replit public URL

### 3. Docker Container

**Create Dockerfile:**

```dockerfile
FROM nixos/nix:latest

COPY start.sh start_button.tcl boyjack-boot.html LICENSE /app/
COPY www /app/www/
WORKDIR /app

RUN nix-shell -p novnc tigervnc xterm fluxbox firefox gedit pcmanfm feh xorg.xinit xorg.xauth xorg.xsetroot python3 xdotool wish --run "echo 'Dependencies installed'"

EXPOSE 5000 5901
CMD ["bash", "start.sh"]
```

**Build & Run:**

```bash
docker build -t boyjack-os .
docker run -d -p 5000:5000 -p 5901:5901 boyjack-os
```

Then access at `http://localhost:5000`

### 4. Virtual Machine

**For VirtualBox/KVM/QEMU:**

1. Build bootable ISO:
   ```bash
   bash build-iso.sh
   ```

2. Create VM with 1GB+ RAM

3. Boot from `boyjack-os.iso`

4. VNC/web interface available on VM's network

### 5. Bare Metal (Physical Hardware)

**Requirements:**
- x86_64 computer
- USB drive or CD/DVD
- 500MB+ disk space

**Steps:**

1. Build ISO:
   ```bash
   bash build-iso.sh
   ```

2. Write to USB:
   ```bash
   sudo dd if=boyjack-os.iso of=/dev/sdX bs=4M
   ```

3. Boot from USB

4. System runs with full VNC/web access

## Production Considerations

### Security

⚠️ **Current State:** No authentication

For production use, add:
- VNC password (`vnc-password` in Xvnc)
- HTTP authentication (proxy in front of port 5000)
- SSH tunneling for remote access
- Firewall rules restricting access

### Performance

- **RAM:** 1GB minimum, 2GB+ recommended
- **CPU:** 2+ cores for smooth desktop
- **Network:** Wired Ethernet for best performance
- **Resolution:** 1280×800 (adjust in start.sh)

### Monitoring

No built-in monitoring currently. For production:
- Monitor process: `pgrep -f "Xvnc|fluxbox|websockify"`
- Monitor ports: `netstat -tlnp | grep :5901`
- Monitor logs: `/tmp/fluxbox.log` and websockify output

### Backups

Nothing persists between restarts (stateless design). Critical files:
- `start.sh` — System startup
- `start_button.tcl` — App launcher
- `boyjack-boot.html` — Boot screen
- `www/` — Web client

Keep these under version control.

## Accessing the System

### From Same Machine

```
Browser:  http://localhost:5000
VNC:      localhost:5901
```

### From Network

```
Browser:  http://<IP>:5000/vnc.html
VNC:      <IP>:5901
```

### Remote Access (via SSH tunnel)

```bash
ssh -L 5000:localhost:5000 -L 5901:localhost:5901 user@remote_host
# Then access at localhost:5000 or localhost:5901
```

## Scaling

BoyJack OS is single-instance (one desktop). For multiple users:

- Each user connects to same desktop via VNC
- Shared mouse/keyboard (collaborative experience)
- For separate desktops, run multiple instances on different ports

**Example: Multiple instances**

```bash
# Instance 1
Xvnc :1 -rfbport 5901 &
websockify 0.0.0.0:5000 localhost:5901

# Instance 2 (different port)
Xvnc :2 -rfbport 5902 &
websockify 0.0.0.0:5001 localhost:5902
```

## Troubleshooting Deployment

### Port Already in Use

If ports 5000 or 5901 are in use:

```bash
# Find what's using the port
lsof -i :5000
lsof -i :5901

# Kill the process
kill <PID>

# Or change ports in start.sh
```

### VNC Connection Refused

Check if Xvnc is running:

```bash
ps aux | grep Xvnc
```

If not running, check `start.sh` output for errors.

### Websockify Connection Failed

Verify websockify is running:

```bash
ps aux | grep websockify
```

Check if it's listening:

```bash
netstat -tlnp | grep 5000
```

## Deployment Checklist

- [ ] Test on local machine first
- [ ] Verify web UI loads (http://localhost:5000)
- [ ] Verify VNC access (localhost:5901)
- [ ] Test keyboard/mouse input
- [ ] Test application launching
- [ ] Check desktop rendering quality
- [ ] Verify network access (if remote)
- [ ] Monitor system resources
- [ ] Set up logging/monitoring
- [ ] Document access URLs
- [ ] Create backup/recovery procedure

## Support

For issues, check:
1. `start.sh` output (terminal logs)
2. `/tmp/fluxbox.log` (window manager logs)
3. `/tmp/start_btn_debug.log` (start button logs)
4. Browser console (F12 Developer Tools)
5. VNC viewer connection logs

---

**Deployment Ready!** BoyJack OS is configured for cloud deployment on Replit.
