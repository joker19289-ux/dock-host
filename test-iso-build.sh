#!/bin/bash
# Test BoyJack OS ISO Build
# Creates a distributable package of the OS (requires xorriso for full bootable ISO)

set -e

echo "🧪 Testing BoyJack OS packaging..."
echo ""

BUILD_DIR="iso_test_build"
ISO_ROOT="$BUILD_DIR/boyjack-os"

# Clean
rm -rf "$BUILD_DIR"
mkdir -p "$ISO_ROOT"

# Copy OS files
echo "📋 Packaging BoyJack OS files..."
cp boyjack-boot.html "$ISO_ROOT/"
cp -r www "$ISO_ROOT/"
cp start.sh "$ISO_ROOT/"
cp start_button.tcl "$ISO_ROOT/"
cp replit.md "$ISO_ROOT/README.md"
cp LICENSE "$ISO_ROOT/"

# Create manifest
cat > "$ISO_ROOT/MANIFEST.txt" << 'MANIFEST'
BoyJack OS v1.0 - Distribution Package
=======================================

CONTENTS:
- start.sh              Main startup script (460+ lines)
- start_button.tcl      Application launcher widget (380+ lines)
- boyjack-boot.html    Animated boot screen
- www/                 noVNC web client + boot screen files
- README.md            Full system documentation
- LICENSE              Project license

FEATURES:
✅ Custom animated boot screen with starfield
✅ Fluxbox window manager with dark cyberpunk theme
✅ VNC-over-WebSocket remote access
✅ 4 virtual workspaces
✅ Pre-launched terminal with custom styling
✅ Quick app launcher (Firefox, File Manager, Text Editor)
✅ Complete keyboard shortcut support

SYSTEM REQUIREMENTS:
- x86_64 processor with virtualization
- 1GB RAM minimum (2GB recommended)
- 500MB disk space
- Network interface

HOW TO RUN:
1. As Docker container: docker run boyjack-os
2. As standalone VNC server: bash start.sh
3. On physical hardware: Boot from boyjack-os.iso

ACCESS:
- VNC Server: localhost:5901
- Web Interface: http://localhost:5000

KEYBOARD SHORTCUTS:
- Alt+F2       Open Terminal
- Alt+F3       Open File Manager
- Ctrl+F1-F4   Switch Workspaces
- Alt+Tab      Switch Windows
- Alt+F4       Close Window

For detailed information, see README.md
MANIFEST

# Create tarball
echo "📦 Creating distribution tarball..."
tar -czf boyjack-os-v1.0.tar.gz -C "$BUILD_DIR" boyjack-os/

# Create checksum
sha256sum boyjack-os-v1.0.tar.gz > boyjack-os-v1.0.tar.gz.sha256

# Show results
echo ""
echo "✅ BoyJack OS Package Test Complete!"
echo ""
echo "📦 Distribution Files:"
ls -lh boyjack-os-v1.0.* | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "📄 Contents:"
tar -tzf boyjack-os-v1.0.tar.gz | head -20
echo ""
echo "✨ Package is ready for distribution!"
echo ""
echo "To create a full bootable ISO on a system with xorriso:"
echo "  bash build-iso.sh"
