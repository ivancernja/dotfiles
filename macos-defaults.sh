#!/usr/bin/env bash
# macOS settings that make this machine behave like the other one.
# Safe to run more than once. Run it after the apps are installed, so the
# app-to-desktop bindings have something to bind to.
set -u
B=$'\033[1m'; D=$'\033[2m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[0m'
step() { printf '\n%s%s%s\n' "$B" "$1" "$R"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$R" "$1"; }
todo() { printf '  %s•%s %s\n' "$Y" "$R" "$1"; }

step "Desktop switching on cmd+1 to cmd+5"
# Symbolic hotkey ids 118-122 are "Switch to Desktop 1" through 5. The parameters are
# the character code, the key code, and the modifier mask: 1048576 is Command.
i=0
for pair in "118:49:18" "119:50:19" "120:51:20" "121:52:21" "122:53:23"; do
  id="${pair%%:*}"; rest="${pair#*:}"; char="${rest%%:*}"; code="${rest#*:}"
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" "
<dict><key>enabled</key><true/><key>value</key><dict>
<key>parameters</key><array>
<integer>$char</integer><integer>$code</integer><integer>1048576</integer></array>
<key>type</key><string>standard</string></dict></dict>"
  i=$((i+1))
done
ok "cmd+1 to cmd+5 bound ($i hotkeys)"

step "Spaces and the Dock"
# Stop macOS reordering desktops by recent use, or cmd+1-5 stop meaning anything.
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48
defaults delete com.apple.dock autohide-delay 2>/dev/null || true
defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true
ok "desktops stay in order, Dock hides but stays reachable"

step "Menu bar"
# SketchyBar replaces it. _HIHideMenuBar is the old key and is still read by some
# things; AutoHideMenuBarOption is where macOS 26 actually keeps the setting.
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write com.apple.controlcenter AutoHideMenuBarOption -int 1
ok "menu bar set to hide"
todo "the menu bar only disappears after a logout: WindowServer reads this at login"

step "Apps on their own desktops"
# The bindings reference space UUIDs, which are different on every machine, so they
# are resolved here from the live list rather than copied from the other Mac.
python3 - <<'PY'
import plistlib, subprocess, sys

WANT = {
    1: ["com.superlogical.rex"],
    2: ["com.google.Chrome", "com.kagi.kagimacOS"],
    3: ["info.pkpk.inkdrop"],
    4: ["com.anysphere.sand"],
    5: ["com.apple.finder", "com.tinyspeck.slackmacgap", "com.hnc.Discord"],
}

raw = subprocess.run(["defaults", "export", "com.apple.spaces", "-"],
                     capture_output=True).stdout
try:
    spaces = plistlib.loads(raw)
except Exception as exc:
    print(f"    could not read the space list: {exc}")
    sys.exit(0)

monitors = (spaces.get("SpacesDisplayConfiguration", {})
                  .get("Management Data", {}).get("Monitors", []))
main = next((m for m in monitors if m.get("Display Identifier") == "Main"), None)
if not main:
    print("    no main display in the space list")
    sys.exit(0)

uuids = [s["uuid"] for s in main.get("Spaces", []) if s.get("type") == 0]
print(f"    {len(uuids)} desktops exist")
if len(uuids) < len(WANT):
    print(f"    need {len(WANT)}: add more in Mission Control, then run this again")
    sys.exit(0)

for position, bundles in WANT.items():
    for bundle in bundles:
        subprocess.run(["defaults", "write", "com.apple.spaces", "app-bindings",
                        "-dict-add", bundle, uuids[position - 1]],
                       capture_output=True)
        print(f"    desktop {position}  {bundle}")
PY
killall Dock 2>/dev/null || true
ok "Dock restarted"

step "Apply the hotkeys without logging out"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null \
  && ok "hotkey table reloaded" || todo "log out and back in to pick up the hotkeys"

step "Wallpaper"
WALL="$HOME/rex/assets/wallpaper.jpg"
if [ -f "$WALL" ]; then
  if osascript -e "tell application \"System Events\" to set picture of every desktop to \"$WALL\"" >/dev/null 2>&1; then
    ok "wallpaper set"
  else
    todo "set the wallpaper by hand from ~/rex/assets/wallpaper.jpg (System Events needs Accessibility)"
  fi
else
  todo "no wallpaper in ~/rex/assets"
fi

printf '\n%sStill needs you:%s\n' "$B" "$R"
todo "create five desktops in Mission Control if there are fewer, then run this again"
todo "log out once, for the menu bar and any new desktops"
todo "grant Accessibility to Hammerspoon in System Settings, Privacy and Security"
todo "recreate the tv and mini ssh hosts and copy their keys, see SETUP.md"
