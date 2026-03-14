# BoyJack OS — Production Dockerfile
# Base image : nixos/nix:latest  (lightweight, all-in-one)
# Disk       : 512 GB free
# Ports      : 5000 (noVNC web) + 5901 (TigerVNC)

FROM nixos/nix:latest

WORKDIR /app

# ── Configure Nix for Docker ──────────────────────────────────────────────
# Docker does not support Nix sandboxing or user namespaces.
# filter-syscalls must be off to allow Nix builds inside a container.
RUN mkdir -p /etc/nix && printf '%s\n' \
    'sandbox = false' \
    'filter-syscalls = false' \
    'experimental-features = nix-command flakes' \
    >> /etc/nix/nix.conf

# ── Add nixpkgs channel AND install all packages in one RUN layer ─────────
# Combining into a single RUN ensures the channel is available to nix-env.
# Splitting into two RUN commands risks the channel not persisting between layers.
RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs \
 && nix-channel --update \
 && nix-env -iA \
      nixpkgs.tigervnc \
      nixpkgs.novnc \
      nixpkgs.xterm \
      nixpkgs.fluxbox \
      nixpkgs.firefox \
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
      nixpkgs.bash \
      nixpkgs.netcat \
 && nix-env -iA nixpkgs.gnome.gedit 2>/dev/null \
    || nix-env -iA nixpkgs.gedit \
 && nix-collect-garbage -d

# ── Copy BoyJack OS files ─────────────────────────────────────────────────
COPY start.sh start_button.tcl boyjack-boot.html LICENSE ./
COPY www ./www/

# ── Runtime environment ───────────────────────────────────────────────────
ENV DISPLAY=:1 \
    HOME=/app \
    PATH="/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    PORT=5000

# ── Health check — auto-detects service health, no timeout ───────────────
HEALTHCHECK --interval=15s --start-period=0s --retries=0 \
  CMD curl -f http://localhost:5000/vnc.html 2>/dev/null \
      || nc -z localhost 5901

# ── Ports ─────────────────────────────────────────────────────────────────
EXPOSE 5000 5901

# ── Start BoyJack OS ──────────────────────────────────────────────────────
CMD ["bash", "start.sh"]
