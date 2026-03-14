# BoyJack OS — Production Dockerfile for Koyeb
# Optimized for cloud deployment with minimal image size

FROM nixos/nix:latest

WORKDIR /app

# Copy BoyJack OS files
COPY start.sh start_button.tcl boyjack-boot.html LICENSE ./
COPY www ./www/

# Install dependencies using nix package manager
# Includes: VNC server, web client, window manager, terminal, browsers
RUN nix-shell -p novnc tigervnc xterm fluxbox firefox gedit pcmanfm feh xorg.xinit xorg.xauth xorg.xsetroot python3 xdotool wish curl --run "echo 'Dependencies installed successfully'"

# Environment variables for X11 and Koyeb
ENV DISPLAY=:1 \
    HOME=/app \
    PATH="/root/.nix-profile/bin:$PATH" \
    PORT=5000

# Health check for Koyeb container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:5000/vnc.html || exit 1

# Expose ports
EXPOSE 5000 5901

# Start BoyJack OS
CMD ["bash", "start.sh"]
