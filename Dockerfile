# BoyJack OS — Production Dockerfile for Koyeb
# Optimized for cloud deployment with minimal image size

FROM --platform=linux/amd64 ubuntu:22.04

WORKDIR /app

# Copy BoyJack OS files
COPY start.sh start_button.tcl boyjack-boot.html LICENSE ./
COPY www ./www/

# Install dependencies using nix package manager
# Includes: VNC server, web client, window manager, terminal, browsers
RUN apt update -y && apt install novnc tigervnc xterm fluxbox firefox gedit pcmanfm feh xorg.xinit xorg.xauth xorg.xsetroot python3 xdotool wish curl

# Environment variables for X11 and Koyeb
ENV DISPLAY=:1 \
    HOME=/app \
    PATH="/root/.nix-profile/bin:$PATH" \
    PORT=5000

# Health check for Koyeb container orchestration
HEALTHCHECK --interval=3600m --start-period=3600m --retries=3 \
  CMD curl -f http://localhost:5000/vnc.html || exit 1

# Expose ports
EXPOSE 5000 5901

# Start BoyJack OS
CMD ["bash", "start.sh"]
