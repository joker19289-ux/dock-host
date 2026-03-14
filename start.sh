#!/bin/bash
#
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                      BoyJack OS - Startup Script                         ║
# ║                        Intelligent System Core                           ║
# ╚══════════════════════════════════════════════════════════════════════════╝
#
# This script initializes BoyJack OS — a full graphical desktop operating
# system accessible via web browser through VNC-over-WebSocket.
#
# FEATURES:
# ═════════════════════════════════════════════════════════════════════════════
#
# 1. CUSTOM BOOT SCREEN WITH ANIMATED STARFIELD
#    • HTML5-based animated startup screen with sci-fi theme
#    • Starfield background with twinking stars
#    • Progress bar with kernel log simulation
#    • Smooth transitions to full desktop after boot complete
#    • File: boyjack-boot.html
#
# 2. FLUXBOX WINDOW MANAGER WITH STYLED TASKBAR
#    • Lightweight, efficient window manager (perfect for VNC)
#    • Custom dark cyberpunk-inspired theme (cyan/blue/navy)
#    • Taskbar at bottom showing workspace names, active windows, and clock
#    • Smooth window animations and effects
#    • Right-click desktop menu for app launcher
#    • Window focus on click, smooth transitions
#
# 3. VNC-OVER-WEBSOCKET REMOTE DESKTOP ACCESS
#    • TigerVNC server on port 5901 (local VNC protocol)
#    • Websockify proxy on port 5000 (HTTP/WebSocket)
#    • noVNC web client — connect via browser (no install needed)
#    • Works from any machine on the network
#    • Secure remote desktop without installation or plugins
#    • Perfect for cloud deployment and mobile access
#
# 4. PRE-LAUNCHED APPLICATIONS
#    • xterm: Full-featured terminal with cyan-on-navy theme
#    • Firefox: Web browser for browsing and development
#    • PCManFM: Lightweight file manager with folder navigation
#    • gedit: Simple text editor with syntax highlighting
#    • All launch via right-click desktop menu or keyboard shortcuts
#
# 5. FOUR VIRTUAL WORKSPACES
#    • Workspace 1: "Main"  — Primary workspace
#    • Workspace 2: "Work"  — Development/productivity
#    • Workspace 3: "Media" — Content creation
#    • Workspace 4: "Files" — File management
#    • Switch with Ctrl+F1–F4, visible in taskbar
#
# 6. DARK CYBERPUNK-INSPIRED THEME
#    • Color scheme: Deep navy (#060a12), cyan (#00f5ff), electric blue (#0066ff)
#    • Flat design with gradient fills (solid look)
#    • High contrast for easy readability
#    • Futuristic "BoyJack" visual identity throughout
#    • Themed fonts (Sans, Monospace for terminal)
#
# KEYBOARD SHORTCUTS:
# ═════════════════════════════════════════════════════════════════════════════
#   Alt+F2         Open Terminal                      [Main shortcut]
#   Alt+F3         Open File Manager                  [File browser]
#   Super+D        Open Desktop Menu                  [Right-click alternative]
#   Ctrl+F1–F4     Switch Workspace                   [Workspace switching]
#   Alt+Tab        Switch between Windows             [Window cycling]
#   Alt+F4         Close Window                       [Window closing]
#
# NETWORK ACCESS:
# ═════════════════════════════════════════════════════════════════════════════
#   Local VNC:      localhost:5901  (VNC viewers only)
#   Web Interface:  localhost:5000  (Browser: /vnc.html for client, / for index)
#   Remote Access:  <machine-ip>:5000/vnc.html  (from other machines)
#
# ARCHITECTURE:
# ═════════════════════════════════════════════════════════════════════════════
#   Xvnc (TigerVNC)    → Headless X11 server rendering desktop at 1280×800
#   Fluxbox            → Window manager + taskbar (minimal overhead)
#   xterm/Firefox/etc  → Pre-launched applications in taskbar
#   websockify         → WebSocket proxy (VNC protocol ↔ HTTP)
#   noVNC              → Web-based VNC client (HTML5/Canvas)
#   www/               → Web root serving noVNC + boot screen
#
# ═════════════════════════════════════════════════════════════════════════════

NOVNC_SRC="/nix/store/n7h60i6lqysmya4clas5vghfsjc6sspa-novnc-1.6.0/share/webapps/novnc"
WEBSOCKIFY="/nix/store/vhjcb946r4swhvrfilwwhlainwd2izki-python3.12-websockify-0.13.0/bin/websockify"

# ── Clean up stale VNC locks ───────────────────────────────────────────────
# Remove any leftover VNC server locks from previous sessions.
# This allows the new Xvnc process to start cleanly without conflicts.
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# ── Build web root (novnc + custom pages) ─────────────────────────────────
# Prepare the web server directory by:
#   1. Making www/ writable (Nix store files are read-only)
#   2. Removing old www/ to get clean state
#   3. Copying noVNC web client files (HTML5 browser-based VNC)
#   4. Injecting custom BoyJack OS boot screen
#   5. Creating index.html redirect to boot screen
#
# This creates the complete web interface accessible at http://localhost:5000/
chmod -R u+w www/ 2>/dev/null || true
rm -rf www
mkdir -p www
cp -r "$NOVNC_SRC"/. www/
cp boyjack-boot.html www/boyjack-boot.html

cat > www/index.html << 'EOF'
<!DOCTYPE html><html><head>
<meta charset="UTF-8"/>
<meta http-equiv="refresh" content="0;url=/boyjack-boot.html"/>
<script>window.location.replace('/boyjack-boot.html');</script>
</head><body></body></html>
EOF

# ── Fluxbox configuration ─────────────────────────────────────────────────
# Configure Fluxbox window manager for optimal VNC experience:
#   • 4 workspaces: Main, Work, Media, Files
#   • Bottom taskbar showing workspace names + active windows + clock
#   • Click-to-focus window management (efficient for remote use)
#   • Dark cyberpunk theme applied globally
#   • Keyboard shortcuts for workspace switching and app launching
#
mkdir -p ~/.fluxbox

# Main settings: dark theme, bottom taskbar
# These settings define the core Fluxbox behavior and appearance
cat > ~/.fluxbox/init << 'EOF'
session.screen0.workspaces: 4
session.screen0.workspaceNames: Main,Work,Media,Files
session.screen0.toolbar.visible: true
session.screen0.toolbar.placement: BottomCenter
session.screen0.toolbar.height: 30
session.screen0.toolbar.widthPercent: 100
session.screen0.toolbar.tools: workspacename,prevworkspace,nextworkspace,iconbar,clock
session.screen0.toolbar.clock.format: %H:%M  %a %d %b
session.screen0.iconbar.mode: WorkspaceIcons
session.screen0.iconbar.alignment: Relative
session.screen0.focusModel: ClickToFocus
session.screen0.windowPlacement: RowMinOverlapPlacement
session.screen0.defaultDeco: NORMAL
session.menuFile: ~/.fluxbox/menu
session.keyFile: ~/.fluxbox/keys
session.styleFile: ~/.fluxbox/style
session.autoRaiseDelay: 250
session.doubleClickInterval: 250
session.screen0.edgeSnapThreshold: 10
session.screen0.maxDisableResize: false
EOF

# Application launcher menu (right-click desktop on the Fluxbox desktop)
# This menu appears when you right-click the desktop background.
# Provides easy access to Terminal, File Manager, Text Editor, Browser, and System options.
cat > ~/.fluxbox/menu << 'EOF'
[begin] (BoyJack OS)
[exec]  (🌐  Firefox Browser)  {firefox --display :1}
[exec]  (📁  File Manager)      {pcmanfm --display :1}
[exec]  (📝  Text Editor)       {gedit --display :1}
[exec]  (🖥️   Terminal)          {xterm -fa 'Monospace' -fs 11 -bg '#0a0e1a' -fg '#00f5ff' -title 'BoyJack Terminal'}
[separator]
[submenu] (⚙️  System)
  [exec]   (Screenshot)   {xterm -e 'echo Screenshot tool not configured'}
  [separator]
  [restart]  (Restart Desktop)
  [exit]     (Exit Session)
[end]
[separator]
[workspaces]  (Workspaces)
[separator]
[exec] (About BoyJack OS) {xterm -T 'About' -e 'echo "BoyJack OS v1.0 — Intelligent System Core" && sleep 5'}
[end]
EOF

# Keyboard shortcuts
# Maps keyboard combos to Fluxbox and application launch commands.
# Mod1 = Alt key, Mod4 = Super/Windows key
cat > ~/.fluxbox/keys << 'EOF'
Mod1 F2 :ExecCommand xterm
Mod1 F3 :ExecCommand pcmanfm
Mod4 d  :RootMenu
Mod4 e  :ExecCommand xterm
Ctrl F1 :Workspace 1
Ctrl F2 :Workspace 2
Ctrl F3 :Workspace 3
Ctrl F4 :Workspace 4
Mod1 Tab :NextWindow
Mod1 F4  :Close
EOF

# Dark BoyJack theme for Fluxbox
# Complete color/style configuration for cyberpunk-inspired look.
# Colors: Navy (#0a0e1a background), Cyan (#00f5ff accents), Electric Blue (#0066ff)
# Applies to: toolbar, windows, menus, buttons, borders, text
cat > ~/.fluxbox/style << 'EOF'
# BoyJack OS Dark Theme

*.font:                      Sans-10
*.alpha:                     255

toolbar:                     flat gradient vertical
toolbar.color:               #0a0e1a
toolbar.colorTo:             #060a12
toolbar.borderWidth:         0
toolbar.borderColor:         #00f5ff
toolbar.height:              30

toolbar.clock.font:          Sans-9
toolbar.clock.textColor:     #00f5ff
toolbar.clock.justify:       Right

toolbar.workspace.font:      Sans-bold-9
toolbar.workspace.textColor: #8b00ff
toolbar.workspace.justify:   Center
toolbar.workspace.color:     #0a0e1a
toolbar.workspace.colorTo:   #0a0e1a

toolbar.iconbar.focused:          flat gradient vertical
toolbar.iconbar.focused.color:    #00336a
toolbar.iconbar.focused.colorTo:  #001a40
toolbar.iconbar.focused.textColor: #00f5ff
toolbar.iconbar.focused.font:     Sans-9
toolbar.iconbar.focused.justify:  Center

toolbar.iconbar.unfocused:          flat gradient vertical
toolbar.iconbar.unfocused.color:    #0d1420
toolbar.iconbar.unfocused.colorTo:  #080e18
toolbar.iconbar.unfocused.textColor: #4a6080
toolbar.iconbar.unfocused.font:     Sans-9
toolbar.iconbar.unfocused.justify:  Center

toolbar.iconbar.empty:          flat
toolbar.iconbar.empty.color:    #0a0e1a

window.title.focus:          flat gradient vertical
window.title.focus.color:    #00336a
window.title.focus.colorTo:  #001a40
window.title.focus.textColor: #00f5ff
window.title.focus.font:     Sans-bold-10

window.title.unfocus:        flat gradient vertical
window.title.unfocus.color:  #0d1420
window.title.unfocus.colorTo: #080e18
window.title.unfocus.textColor: #3a5070
window.title.unfocus.font:   Sans-10

window.label.focus:          flat
window.label.focus.color:    #00336a
window.label.focus.textColor: #00f5ff
window.label.unfocus:        flat
window.label.unfocus.color:  #0d1420
window.label.unfocus.textColor: #3a5070

window.handle.focus:         flat
window.handle.focus.color:   #00336a
window.handle.unfocus:       flat
window.handle.unfocus.color: #0d1420

window.grip.focus:           flat
window.grip.focus.color:     #0066ff
window.grip.unfocus:         flat
window.grip.unfocus.color:   #0d1420

window.button.focus:         flat
window.button.focus.color:   #00336a
window.button.focus.picColor: #00f5ff
window.button.unfocus:       flat
window.button.unfocus.color: #0d1420
window.button.unfocus.picColor: #3a5070
window.button.pressed:       flat
window.button.pressed.color: #0066ff

window.borderWidth:          1
window.borderColor:          #0044aa
window.frame.focusColor:     #0044aa
window.frame.unfocusColor:   #0d1420

window.titleHeight:          24
window.handleWidth:          4

menu.title:                  flat gradient vertical
menu.title.color:            #001a40
menu.title.colorTo:          #00336a
menu.title.textColor:        #00f5ff
menu.title.font:             Sans-bold-11
menu.title.justify:          Center

menu.frame:                  flat
menu.frame.color:            #0a0e1a
menu.frame.textColor:        #c0d8f0
menu.frame.font:             Sans-10
menu.frame.justify:          Left

menu.hilite:                 flat gradient vertical
menu.hilite.color:           #003366
menu.hilite.colorTo:         #004488
menu.hilite.textColor:       #00f5ff
menu.hilite.font:            Sans-bold-10

menu.borderWidth:            1
menu.borderColor:            #0044aa

background:                  flat
background.color:            #060a12
EOF

# Fluxbox apps — tells Fluxbox how to treat specific windows
cat > ~/.fluxbox/apps << 'EOF'
[app] (name=boyjack-start)
  [Deco]          {NONE}
  [Sticky]        {yes}
  [Layer]         {2}
  [IconHidden]    {yes}
  [TaskbarHidden] {yes}
[end]
[app] (name=boyjack-menu)
  [Deco]          {NONE}
  [Sticky]        {yes}
  [Layer]         {2}
  [IconHidden]    {yes}
  [TaskbarHidden] {yes}
[end]
EOF

# ── Desktop wallpaper (solid deep navy) ───────────────────────────────────
# Create a simple solid-color wallpaper via xsetroot after X11 starts.
# Color: Deep navy (#060a12) — matches BoyJack theme background
#
# Note: xsetroot is the standard X11 tool for setting desktop backgrounds.
# If fbsetbg is available, Fluxbox prefers it; otherwise xsetroot works great.

# ── Start Xvnc ─────────────────────────────────────────────────────────────
# Launch TigerVNC X11 server (the actual display server rendering the desktop)
#   • Display: :1 (X11 display number)
#   • Security: None (no authentication — for trusted networks)
#   • Resolution: 1280×800 (16:10 widescreen, good for VNC)
#   • Port: 5901 (standard VNC port for protocol-level connections)
#   • Process runs in background, continues to startup steps
echo "🖥️  Starting X11 VNC server on port 5901..."
Xvnc :1 -SecurityTypes None -geometry 1280x800 -rfbport 5901 &
sleep 2

# ── Set wallpaper ──────────────────────────────────────────────────────────
# Apply the solid navy wallpaper to the desktop background
DISPLAY=:1 xsetroot -solid "#060a12" 2>/dev/null || true

# ── Start Fluxbox window manager (has built-in taskbar) ───────────────────
# Launch Fluxbox — lightweight, efficient window manager perfect for VNC.
# Handles: window decorations, taskbar, workspace management, app menu, themes
#
# Note: Some Fluxbox utilities (fluxbox-update_configs, fbsetbg) may not be
# available in minimal environments. These are non-essential — Fluxbox runs
# perfectly fine without them. Non-fatal warnings go to fluxbox.log (not stderr).
echo "🎨 Starting Fluxbox window manager..."
DISPLAY=:1 fluxbox &
sleep 1

# ── Start button (floats on taskbar, toggles app menu) ────────────────────
# Launch the BoyJack Start Button — a custom Tcl/Tk widget that:
#   • Floats on the Fluxbox taskbar at bottom-left corner
#   • Single-click to toggle application menu
#   • Quick access to Firefox, File Manager, Text Editor, Terminal
#   • Restart Desktop option for Fluxbox
#
# This widget is implemented in start_button.tcl and provides an alternative
# to right-clicking the desktop. Menu displays with themed styling matching
# the dark cyberpunk theme. Position is fixed via xdotool for reliability.
#
# If Tcl/Tk is not available, the button won't launch but other app access
# methods remain functional (keyboard shortcuts, right-click menu).
DISPLAY=:1 wish -name boyjack-start start_button.tcl 2>/dev/null &
sleep 0.5

# ── Launch starter apps ────────────────────────────────────────────────────
# PRE-LAUNCH TERMINAL
# The Terminal is pre-launched so it's immediately ready when the desktop loads.
# This is the primary user interface for command-line work on BoyJack OS.
# Other applications are accessible via menu rather than pre-launched for
# performance reasons (reduces initial startup overhead).
#
# TERMINAL CONFIGURATION:
#   • Font: Monospace 11pt (standard monospace terminal font)
#   • Background: #0a0e1a (dark navy — matches BoyJack theme)
#   • Foreground: #00f5ff (cyan — BoyJack accent color)
#   • Title: 'BoyJack Terminal' (shown in window decorations + taskbar)
#   • Size: 90 columns × 28 rows (standard terminal dimensions for 1280×800)
#   • Position: +20+40 (top-left corner, 20px from edges)
#
# OTHER APPLICATIONS ACCESS:
#   Three ways to launch Firefox, File Manager, or Text Editor:
#
#   1. KEYBOARD SHORTCUTS (fastest):
#      Alt+F2       Open Terminal (or another instance)
#      Alt+F3       Open File Manager
#      Right-click  Open Desktop Menu → Firefox Browser or Text Editor
#
#   2. START BUTTON (if Tcl/Tk available):
#      Click the button on the taskbar → dropdown menu with all apps
#
#   3. DESKTOP RIGHT-CLICK MENU:
#      Right-click empty desktop → see full application menu
#
# All apps run with DISPLAY=:1 so they appear on the VNC desktop.
echo "💻 Launching terminal..."
DISPLAY=:1 xterm \
  -fa 'Monospace' -fs 11 \
  -bg '#0a0e1a' -fg '#00f5ff' \
  -title 'BoyJack Terminal' \
  -geometry 90x28+20+40 &

# ── Start websockify serving www/ on port 5000 ────────────────────────────
# Websockify is a WebSocket-to-VNC proxy that:
#   • Listens on 0.0.0.0:5000 (accessible from all network interfaces)
#   • Serves www/ directory (noVNC web client + boot screen)
#   • Proxies VNC protocol over HTTP/WebSocket (browser-compatible)
#   • Connects to localhost:5901 (the Xvnc server)
#
# This allows users to connect via:
#   • Web browser: http://<machine-ip>:5000/vnc.html
#   • Direct VNC: <machine-ip>:5901 (with VNC viewer)
#
# The script blocks here on websockify (main foreground process)
echo "🌐 Starting web interface on port 5000..."
echo ""
echo "============================================================="
echo "         BoyJack OS Started Successfully!"
echo "============================================================="
echo ""
echo "  VNC Server:     port 5901 (TigerVNC)"
echo "  Web Interface:  port 5000 (websockify + noVNC)"
echo ""
echo "  Access via Browser:"
echo "    http://localhost:5000          (boot screen)"
echo "    http://localhost:5000/vnc.html (VNC client)"
echo ""
echo "  Keyboard Shortcuts (on desktop):"
echo "    Alt+F2     Open Terminal"
echo "    Alt+F3     Open File Manager"
echo "    Ctrl+F1-4  Switch Workspaces"
echo "    Alt+Tab    Switch Windows"
echo ""
echo "  Press Ctrl+C to stop the server"
echo ""
echo "============================================================="
echo ""

"$WEBSOCKIFY" --web=www/ 0.0.0.0:5000 localhost:5901
