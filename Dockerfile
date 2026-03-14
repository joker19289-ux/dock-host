# BoyJack OS — Production Dockerfile
# Base image : nixos/nix:latest  (lightweight, all-in-one)
# Disk       : 512 GB free
# Ports      : 5000 (noVNC web) + 5901 (TigerVNC)

FROM nixos/nix:latest

WORKDIR /app

# ── Enable nixpkgs channel so nix-env can resolve packages ───────────────
RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs \
 && nix-channel --update

# ── Permanently install all packages via nix-env -iA ─────────────────────
# nix-shell only creates a temporary scope; nix-env writes to /root/.nix-profile
# which persists across RUN layers and is available at container runtime.
RUN nix-env -iA \
    nixpkgs.novnc \
    nixpkgs.tigervnc \
    nixpkgs.xterm \
    nixpkgs.fluxbox \
    nixpkgs.firefox \
    nixpkgs.gedit \
    nixpkgs.pcmanfm \
    nixpkgs.feh \
    nixpkgs.xorg.xinit \
    nixpkgs.xorg.xauth \
    nixpkgs.xorg.xsetroot \
    nixpkgs.xorg.xrandr \
    nixpkgs.python3 \
    nixpkgs.xdotool \
    nixpkgs.tcl \
    nixpkgs.curl \
    nixpkgs.wget \
    nixpkgs.git \
    nixpkgs.bash

# ── Copy BoyJack OS files ─────────────────────────────────────────────────
COPY start.sh start_button.tcl boyjack-boot.html LICENSE ./
COPY www ./www/

# ── Runtime environment ───────────────────────────────────────────────────
ENV DISPLAY=:1 \
    HOME=/app \
    PATH="/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    PORT=5000

# ── Health check — auto-detects service health, no timeout ───────────────
# Checks noVNC web first; falls back to VNC port probe
HEALTHCHECK --interval=15s --start-period=0s --retries=0 \
  CMD curl -f http://localhost:5000/vnc.html 2>/dev/null || \
      nc -z localhost 5901

# ── Ports ─────────────────────────────────────────────────────────────────
EXPOSE 5000 5901

# ── Start BoyJack OS ──────────────────────────────────────────────────────
CMD ["bash", "start.sh"]
