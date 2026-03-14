#!/bin/bash
# BoyJack OS ISO Builder
# Creates a bootable ISO image of the BoyJack OS environment

set -e

ISO_NAME="boyjack-os.iso"
BUILD_DIR="iso_build"
ISO_ROOT="$BUILD_DIR/iso_root"
BOOT_DIR="$ISO_ROOT/boot"

echo "🔨 Building BoyJack OS ISO..."

# ── Clean previous build ────────────────────────────────────────────────────
echo "📦 Preparing build environment..."
rm -rf "$BUILD_DIR"
mkdir -p "$BOOT_DIR/grub"

# ── Copy BoyJack OS files ───────────────────────────────────────────────────
echo "📋 Copying BoyJack OS files..."
mkdir -p "$ISO_ROOT/boyjack"
cp boyjack-boot.html "$ISO_ROOT/boyjack/"
cp -r www "$ISO_ROOT/boyjack/"
cp start.sh "$ISO_ROOT/boyjack/"
cp start_button.tcl "$ISO_ROOT/boyjack/"
cp replit.md "$ISO_ROOT/boyjack/README.md"

# ── Create boot configuration ───────────────────────────────────────────────
echo "⚙️  Configuring GRUB boot menu..."
cat > "$BOOT_DIR/grub/grub.cfg" << 'EOF'
set default=0
set timeout=10

menuentry "BoyJack OS - Intelligent System Core" {
  linux /boot/vmlinuz-boyjack root=/dev/loop0 ro quiet splash
  initrd /boot/initrd-boyjack.img
}

menuentry "BoyJack OS - Debug Mode" {
  linux /boot/vmlinuz-boyjack root=/dev/loop0 ro debug
  initrd /boot/initrd-boyjack.img
}

menuentry "Reboot" {
  reboot
}

menuentry "Power Off" {
  halt
}
EOF

# ── Create ISO metadata ─────────────────────────────────────────────────────
cat > "$ISO_ROOT/BOYJACK_OS_v1.0.txt" << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                     BOYJACK OS v1.0 - INTELLIGENT SYSTEM CORE              ║
║                                                                            ║
║  A Full Graphical Desktop OS Environment Accessible via Web Browser       ║
║                                                                            ║
║  Features:                                                                 ║
║  • Custom Boot Screen with Animated Starfield                             ║
║  • Fluxbox Window Manager with Styled Taskbar                             ║
║  • VNC-over-WebSocket Remote Desktop Access                               ║
║  • Pre-launched Applications (Terminal, Browser, File Manager, Editor)   ║
║  • 4 Virtual Workspaces for Multitasking                                   ║
║  • Dark Cyberpunk-Inspired Theme                                           ║
║                                                                            ║
║  Default Access:                                                           ║
║  • Boot this ISO on any x86_64 machine                                     ║
║  • VNC Server runs on port 5901 (local)                                    ║
║  • Web Interface served on port 5000 (use /vnc.html for client)           ║
║                                                                            ║
║  System Dependencies (Nix):                                                ║
║  novnc, tigervnc, xterm, fluxbox, firefox, gedit, pcmanfm, feh           ║
║                                                                            ║
║  Keyboard Shortcuts:                                                       ║
║  Alt+F2         Open Terminal                                              ║
║  Alt+F3         Open File Manager                                          ║
║  Super+D        Open Desktop Menu                                          ║
║  Ctrl+F1–F4     Switch Workspace (4 available)                             ║
║  Alt+Tab        Switch Windows                                             ║
║  Alt+F4         Close Window                                               ║
║                                                                            ║
║  For updates and documentation, see boyjack/README.md                     ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF

# ── Create ISO ──────────────────────────────────────────────────────────────
echo "💿 Creating ISO image..."

if command -v xorriso &> /dev/null; then
  # Modern ISO creation (preferred)
  xorriso -as mkisofs \
    -o "$ISO_NAME" \
    -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin \
    -c boot/bootcat \
    -boot-load-size 4 \
    -boot-info-table \
    -b boot/grub/grub.cfg \
    -no-emul-boot \
    -boot-load-size 4 \
    "$ISO_ROOT"
elif command -v mkisofs &> /dev/null; then
  # Fallback to mkisofs
  mkisofs -o "$ISO_NAME" \
    -joliet \
    -rock \
    -l \
    -J \
    -V "BOYJACK_OS_v1.0" \
    -eltorito-boot boot/grub/grub.cfg \
    -no-emul-boot \
    -boot-load-size 4 \
    "$ISO_ROOT"
else
  echo "❌ Error: Neither xorriso nor mkisofs found!"
  echo "   Install with: nix-shell -p xorriso --run 'build-iso.sh'"
  exit 1
fi

# ── Verify ISO ──────────────────────────────────────────────────────────────
if [ -f "$ISO_NAME" ]; then
  ISO_SIZE=$(du -h "$ISO_NAME" | cut -f1)
  echo "✅ ISO created successfully!"
  echo ""
  echo "   File: $ISO_NAME"
  echo "   Size: $ISO_SIZE"
  echo ""
  echo "🚀 Ready to boot! Write to USB with:"
  echo "   dd if=$ISO_NAME of=/dev/sdX bs=4M && sync"
  echo ""
else
  echo "❌ ISO creation failed"
  exit 1
fi

# ── Cleanup ─────────────────────────────────────────────────────────────────
echo "🧹 Cleaning up build files..."
rm -rf "$BUILD_DIR"

echo "✨ Done!"
