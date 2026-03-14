#!/usr/bin/env wish
#
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║             BoyJack OS — Application Launcher Start Button              ║
# ║                      Tcl/Tk Widget for Fluxbox                           ║
# ╚══════════════════════════════════════════════════════════════════════════╝
#
# PURPOSE:
# ═════════════════════════════════════════════════════════════════════════════
# This script implements the BoyJack Start Button — a custom application menu
# widget that floats on the Fluxbox taskbar (bottom-left corner). It provides
# quick access to essential applications and system functions.
#
# FEATURES:
# ─────────────────────────────────────────────────────────────────────────────
# • Floats on taskbar at bottom-left (position maintained via xdotool)
# • Single-click to toggle application menu
# • Smooth expand/collapse animations (14ms frame rate)
# • Dark cyberpunk-themed styling (navy/cyan/electric blue)
# • Quick access to:
#   - Firefox Browser (web browsing)
#   - File Manager (folder navigation)
#   - Text Editor (file editing)
#   - Terminal (command-line work)
#   - Restart Desktop (Fluxbox restart)
# • Click-outside-to-close behavior (closes menu when clicking outside)
# • Hand cursor for menu items (visual feedback)
# • Hover effects (item highlighting on mouse over)
#
# KEYBOARD SHORTCUTS (alternative to this button):
# ─────────────────────────────────────────────────────────────────────────────
# Even if this button is not available, these alternatives work:
#   Alt+F2       Open Terminal
#   Alt+F3       Open File Manager
#   Right-click  Open Fluxbox desktop menu (includes all apps)
#   Ctrl+F1-F4   Switch workspaces
#   Alt+Tab      Switch windows
#
# TECHNICAL NOTES:
# ─────────────────────────────────────────────────────────────────────────────
# • Uses xdotool for reliable window positioning (Tk wm unreliable on Fluxbox)
# • Overrideredirect window (no window manager decorations)
# • Menu is packed/unpacked dynamically for smooth animations
# • Position enforcement runs at startup (200ms, 600ms, 1200ms intervals)
# • Keep-on-top behavior ensures button stays visible during menu operations
# • Non-modal menu (click outside to close)
#
# DEPENDENCIES:
# ─────────────────────────────────────────────────────────────────────────────
# • Tcl/Tk 8.6+ (provides Tk package)
# • xdotool (for reliable window positioning)
# • Fluxbox (window manager)
# • Standard Unix tools (sh, firefox, pcmanfm, gedit, xterm, fluxbox-remote)
#
# GRACEFUL DEGRADATION:
# ─────────────────────────────────────────────────────────────────────────────
# If this button fails to launch (e.g., Tcl/Tk unavailable), BoyJack OS
# remains fully functional. Users can access all applications via:
#   1. Keyboard shortcuts (Alt+F2, Alt+F3, etc.)
#   2. Desktop right-click menu
#   3. Pre-launched terminal
#
# ═════════════════════════════════════════════════════════════════════════════

package require Tk

# ── THEME: Dark Cyberpunk Color Scheme ────────────────────────────────────
# The BoyJack OS uses a cohesive dark theme with navy, cyan, and electric blue.
# These colors match the boot screen, terminal, Fluxbox styling, and desktop.
#
set BG_BTN    "#0a0e1a"  ; # Button background (dark navy)
set BG_HOVER  "#003366"  ; # Button hover state (darker blue)
set BG_PRESS  "#0066ff"  ; # Button pressed state (electric blue)
set BG_MENU   "#0d1420"  ; # Menu background (dark navy)
set BG_HDR    "#040810"  ; # Menu header background (darkest)
set BG_IHOV   "#00336a"  ; # Menu item hover (blue)
set FG_CYAN   "#00f5ff"  ; # Primary text (cyan accent)
set FG_DIM    "#4a6080"  ; # Secondary text (dim gray-blue)
set FG_ITEM   "#c0d8f0"  ; # Menu item text (light gray-blue)
set BORDER    "#0044aa"  ; # Border color (electric blue)
set SEP       "#0d2244"  ; # Separator color (dark blue)

# ── FLUXBOX INTEGRATION ────────────────────────────────────────────────────
# fluxbox-remote is Fluxbox's remote control interface. Allows this script
# to send commands to Fluxbox (e.g., restart, toggle menus, manage windows).
set FB_REMOTE "/nix/store/2rfmy75bkhyd1b6z6p70r2d9r49z72mm-fluxbox-1.3.7/bin/fluxbox-remote"

# ── SCREEN DIMENSIONS & BUTTON POSITIONING ────────────────────────────────
# The button floats at the bottom-left corner of the screen.
# Position is refreshed via xdotool to maintain placement in Fluxbox.
#
set SW [winfo screenwidth  .]  ; # Screen width (1280px)
set SH [winfo screenheight .]  ; # Screen height (800px)

set BTN_W  240  ; # Button width (240px — enough for "[" "Start" "]" text)
set BTN_H   30  ; # Button height (30px — matches Fluxbox taskbar)
set WDOW_X   0  ; # Button X position (0 = left edge)
set WDOW_Y  [expr {$SH - $BTN_H}]  ; # Button Y position (bottom of screen)

# ── APPLICATION MENU ITEMS ─────────────────────────────────────────────────
# Format: {Label Icon Command}
# Icon is 2-char shortcut for quick visual identification
# Command runs with DISPLAY=:1 to target the VNC desktop
#
# These match the apps available via keyboard shortcuts and desktop menu.
# Terminal command includes full styling to match pre-launched xterm.
#
set ITEMS {
    {"Firefox Browser"  "FF"  "firefox"}
    {"File Manager"     "FM"  "pcmanfm"}
    {"Text Editor"      "ED"  "gedit"}
    {"Terminal"         "T>"  "xterm -fa Monospace -fs 11 -bg '#0a0e1a' -fg '#00f5ff' -title BoyJack"}
    -
    {"Restart Desktop"  "RR"  "$FB_REMOTE Restart"}
}

# ── CALCULATE MENU DIMENSIONS ─────────────────────────────────────────────
# Menu height is dynamic based on number of items and separators.
# Each item takes 38px, separators take 13px, with 8px footer padding.
#
set MENU_H 56
foreach it $ITEMS {
    if {$it eq "-"} { incr MENU_H 13 } else { incr MENU_H 38 }
}
incr MENU_H 8
set FULL_H [expr {$BTN_H + $MENU_H}]  ; # Total height when menu is expanded

# ── APPLICATION LAUNCHER PROCEDURE ─────────────────────────────────────────
# Launch applications with DISPLAY=:1 so they appear on the VNC desktop.
# Uses shell background execution (&) to prevent blocking.
# Errors are silently caught (app might already be running, etc.).
#
proc launch {cmd} {
    catch { exec /bin/sh -c "DISPLAY=:1 $cmd &" & }
}

# ── XDOTOOL WINDOW POSITIONING PROCEDURE ──────────────────────────────────
# xdotool is used because Tk's wm geometry is unreliable for override-redirect
# windows under Fluxbox. This procedure sizes and positions the button window.
#
# xdotool commands:
#   windowsize: Set window size to BTN_W × h pixels
#   windowmove: Move window to (WDOW_X, y) position
#
# The button always stays at bottom-left; height changes during animations.
# Debug output logged to /tmp/start_btn_debug.log for troubleshooting.
#
proc xdo_place {h} {
    global BTN_W WDOW_X SH
    set xid [winfo id .]
    set y   [expr {$SH - $h}]
    set r1 [catch { exec xdotool windowsize $xid $BTN_W $h } e1]
    set r2 [catch { exec xdotool windowmove $xid $WDOW_X $y } e2]
    catch {
        set fd [open /tmp/start_btn_debug.log a]
        puts $fd "[clock seconds] xdo_place xid=$xid h=$h y=$y r1=$r1 e1=$e1 r2=$r2 e2=$e2"
        close $fd
    }
}

# ── WINDOW SETUP ──────────────────────────────────────────────────────────
# Create an override-redirect window (no decorations, stays on top).
# This button floats freely on the taskbar without window manager interference.
#
# wm withdraw:        Hide initially (will be shown after positioning)
# wm overrideredirect: Remove window decorations (title bar, borders)
# configure -background: Set window background color
# -bd 0:              Remove internal border
#
wm withdraw .
wm overrideredirect . 1
. configure -background $BG_BTN -bd 0
wm geometry . ${BTN_W}x${BTN_H}+${WDOW_X}+${WDOW_Y}

# ── Menu frame ─────────────────────────────────────────────────────────────
frame .menu -bg $BG_MENU -bd 0

frame .menu.hdr -bg $BG_HDR
pack  .menu.hdr -fill x
label .menu.hdr.ic -text "BJ" -font "Courier 14 bold" \
    -bg $BG_HDR -fg $FG_CYAN -padx 10 -pady 5
label .menu.hdr.nm -text "BoyJack OS" -font "Sans 10 bold" \
    -bg $BG_HDR -fg $FG_CYAN
label .menu.hdr.vr -text "v1.0" -font "Sans 8" \
    -bg $BG_HDR -fg $FG_DIM
pack .menu.hdr.ic -side left
pack .menu.hdr.nm -side left -pady {8 2}
pack .menu.hdr.vr -side left -padx 4 -pady {14 0}

frame .menu.divtop -bg $BORDER -height 1
pack  .menu.divtop -fill x

set idx 0
foreach it $ITEMS {
    if {$it eq "-"} {
        frame .menu.s$idx -bg $SEP -height 1
        pack  .menu.s$idx -fill x -padx 10 -pady 6
    } else {
        lassign $it lbl icon cmd
        set f [frame .menu.r$idx -bg $BG_MENU -cursor hand2]
        pack $f -fill x
        label $f.ic -text $icon -font "Courier 10 bold" \
            -bg $BG_MENU -fg $FG_CYAN -width 4 -padx 4 -pady 2 -anchor c
        label $f.lb -text $lbl  -font "Sans 9" \
            -bg $BG_MENU -fg $FG_ITEM -anchor w -padx 4 -pady 2
        pack $f.ic -side left
        pack $f.lb -side left -fill x -expand 1
        set icmd $cmd
        foreach w [list $f $f.ic $f.lb] {
            bind $w <Enter>    [list ihov $f $f.ic $f.lb 1]
            bind $w <Leave>    [list ihov $f $f.ic $f.lb 0]
            bind $w <Button-1> [list do_launch $icmd]
        }
    }
    incr idx
}
frame .menu.foot -bg $BG_MENU -height 8
pack  .menu.foot -fill x

# ── MENU ITEM HOVER EFFECT PROCEDURE ───────────────────────────────────────
# Highlights menu items when the mouse enters/leaves them.
# On hover: Background changes to blue, text becomes cyan.
# Off hover: Background returns to menu color, text returns to normal.
#
proc ihov {f ic lb on} {
    global BG_IHOV BG_MENU FG_CYAN FG_ITEM
    if {$on} { set bg $BG_IHOV; set fg $FG_CYAN } \
    else      { set bg $BG_MENU; set fg $FG_ITEM }
    foreach w [list $f $ic $lb] { $w configure -background $bg }
    $lb configure -foreground $fg
}

# ── LAUNCH PROCEDURE ───────────────────────────────────────────────────────
# When a menu item is clicked:
#   1. Close the menu (with animation)
#   2. Wait 120ms for visual feedback
#   3. Launch the application
#
proc do_launch {cmd} { close_menu; after 120 [list launch $cmd] }

# ── Button bar ────────────────────────────────────────────────────────────
frame .bar -bg $BG_BTN -bd 0
pack  .bar -fill both -expand 1

button .bar.btn \
    -text {[ Start ]} \
    -bg $BG_BTN -fg $FG_CYAN \
    -activebackground $BG_HOVER -activeforeground $FG_CYAN \
    -relief flat -bd 0 -highlightthickness 1 \
    -highlightbackground $BORDER \
    -font "Courier 10 bold" \
    -cursor hand2 -padx 10 -pady 0 \
    -command toggle_menu
pack .bar.btn -fill both -expand 1

bind .bar.btn <Enter>           { if {!$::open} { .bar.btn configure -bg $::BG_HOVER } }
bind .bar.btn <Leave>           { if {!$::open} { .bar.btn configure -bg $::BG_BTN   } }
bind .bar.btn <ButtonPress-1>   { .bar.btn configure -bg $::BG_PRESS }
bind .bar.btn <ButtonRelease-1> { after 60 sync_btn }

proc sync_btn {} {
    global BG_BTN BG_HOVER open
    if {$open} { .bar.btn configure -bg $BG_HOVER -relief sunken } \
    else        { .bar.btn configure -bg $BG_BTN   -relief flat   }
}

# ── MENU TOGGLE & ANIMATION SYSTEM ────────────────────────────────────────
# The menu expands and collapses smoothly with easing. Animation runs at
# 14ms intervals (~72fps) for fluid motion. Variables track animation state.
#
set open   0  ; # Menu open/closed state (0=closed, 1=open)
set animid "" ; # Animation timer ID (used to cancel ongoing animations)

# ── TOGGLE PROCEDURE ───────────────────────────────────────────────────────
# Switches between open and closed menu states.
proc toggle_menu {} {
    global open
    if {$open} { close_menu } else { open_menu }
}

# ── OPEN MENU PROCEDURE ────────────────────────────────────────────────────
# Shows the menu with expand animation. Enables click-outside detection.
proc open_menu {} {
    global open BTN_H animid
    set open 1
    sync_btn
    pack .menu -fill x -side top -before .bar
    set animid [after 0 [list anim_expand $BTN_H]]
    after 300 arm_outside
}

# ── CLOSE MENU PROCEDURE ───────────────────────────────────────────────────
# Hides the menu with collapse animation. Disables click-outside detection.
proc close_menu {} {
    global open animid
    disarm_outside
    set open 0
    sync_btn
    if {$animid ne ""} { after cancel $animid; set animid "" }
    set cur_h [winfo height .]
    after 0 [list anim_collapse $cur_h]
}

# ── EXPAND ANIMATION PROCEDURE ─────────────────────────────────────────────
# Grows the window from current height to full menu height.
# Uses easing (0.4 factor) for smooth deceleration.
# Runs at 14ms intervals until FULL_H is reached.
proc anim_expand {cur_h} {
    global animid FULL_H open
    if {!$open} return
    set step [expr {int(($FULL_H - $cur_h) * 0.4 + 4)}]
    if {$step < 2} { set step 2 }
    set next_h [expr {min($FULL_H, $cur_h + $step)}]
    xdo_place $next_h
    if {$next_h < $FULL_H} {
        set animid [after 14 [list anim_expand $next_h]]
    } else { set animid "" }
}

# ── COLLAPSE ANIMATION PROCEDURE ───────────────────────────────────────────
# Shrinks the window from current height to button height.
# Uses easing (0.4 factor) for smooth deceleration.
# Hides menu frame after collapse completes.
proc anim_collapse {cur_h} {
    global BTN_H
    set step [expr {int(($cur_h - $BTN_H) * 0.4 + 4)}]
    if {$step < 2} { set step 2 }
    set next_h [expr {max($BTN_H, $cur_h - $step)}]
    xdo_place $next_h
    if {$next_h > $BTN_H} {
        after 14 [list anim_collapse $next_h]
    } else {
        pack forget .menu
    }
}

proc arm_outside {}    { bind all <Button-1> +chk_outside }
proc disarm_outside {} { bind all <Button-1> {} }
proc chk_outside {} {
    global open
    if {!$open} return
    after 60 {
        if {!$::open} return
        set px [winfo pointerx .]; set py [winfo pointery .]
        set wx [winfo x .];        set wy [winfo y .]
        set ww [winfo width .];    set wh [winfo height .]
        if {!($px>=$wx && $px<$wx+$ww && $py>=$wy && $py<$wy+$wh)} {
            close_menu
        }
    }
}

# ── INITIALIZATION & POSITION ENFORCEMENT ─────────────────────────────────
# Show the window and enforce position via xdotool at multiple time points.
# This overcomes Tk's unreliable geometry handling under Fluxbox.
#
# Timeline:
#   0ms:    Window created (deiconified/shown)
#   200ms:  First position enforcement + raise to top
#   600ms:  Second enforcement (Fluxbox stabilization)
#   1200ms: Third enforcement (final lock-in)
#   2000ms: Start keep_top loop (maintains on-top status)
#
wm deiconify .
update

# Use xdotool to force position (bypasses Tk's wm geometry limitations)
after 200 { xdo_place $::BTN_H; raise . }
after 600 { xdo_place $::BTN_H; raise . }
after 1200 { xdo_place $::BTN_H; raise . }

# ── KEEP-ON-TOP PROCEDURE ──────────────────────────────────────────────────
# Runs continuously to ensure button stays above other windows.
# This prevents Fluxbox or other windows from covering the button.
# Raises window every 1000ms (1 second).
proc keep_top {} {
    catch { raise . }
    after 1000 keep_top
}
after 2000 keep_top
