#!/usr/bin/env bash
# Rebuild this terminal setup on a fresh Mac, or repair it on this one.
#   ./install.sh            install what is missing, then print what still needs credentials
#   ./install.sh --session  do that, then open the Comms session
set -u
REX_DIR="$HOME/rex"
CONF="$HOME/.config/rex-comms"
B=$'\033[1m'; D=$'\033[2m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[0m'

step() { printf '\n%s%s%s\n' "$B" "$1" "$R"; }
have() { command -v "$1" >/dev/null 2>&1; }
ok()   { printf '  %s✓%s %s\n' "$G" "$R" "$1"; }
todo() { printf '  %s•%s %s\n' "$Y" "$R" "$1"; }

step "Command line tools"
BREW_PKGS="mpv yt-dlp fzf jq gh glow btop yazi ripgrep"
if have brew; then
  missing=""
  for pkg in $BREW_PKGS; do
    brew list --formula "$pkg" >/dev/null 2>&1 || missing="$missing $pkg"
  done
  if [ -n "$missing" ]; then
    echo "  installing:$missing"
    brew install $missing
  fi
  ok "homebrew packages"
else
  todo "install Homebrew first: https://brew.sh"
fi

step "Terminal browser"
if have carbonyl; then
  ok "carbonyl"
elif have npm; then
  npm i -g carbonyl && ok "carbonyl installed"
else
  todo "needs node and npm for carbonyl"
fi

step "Python side (the clickable panes)"
PY=$(command -v python3.14 || command -v python3.13 || command -v python3)
if [ ! -x "$REX_DIR/venv/bin/python" ]; then
  "$PY" -m venv "$REX_DIR/venv" && "$REX_DIR/venv/bin/pip" -q install textual pyobjc-framework-EventKit
fi
"$REX_DIR/venv/bin/python" -c "import textual, EventKit" 2>/dev/null && ok "textual and the EventKit bridge" || todo "the venv did not install cleanly"

step "Config"
mkdir -p "$CONF" "$HOME/.local/state/rex-comms"
[ -f "$CONF/tv.json" ] || cat > "$CONF/tv.json" <<'JSON'
{
  "host": "tv",
  "mac": "",
  "music_app": "com.local.shelf",
  "shelf": "http://10.0.0.104:8742",
  "apps": [
    {"name": "Shelf", "id": "com.local.shelf"},
    {"name": "Launcher", "id": "com.still.launcher"},
    {"name": "YouTube", "id": "youtube.leanback.v4"},
    {"name": "Netflix", "id": "netflix"}
  ]
}
JSON
ok "config in $CONF"

step "Rex"
mkdir -p "$HOME/.config/rex"
if ! grep -q 'name  = "comms"' "$HOME/.config/rex/init.lua" 2>/dev/null; then
  cat >> "$HOME/.config/rex/init.lua" <<'LUA'

-- Comms: mail, feeds, pull requests, the TV, web and bots.
rex.action{
  name  = "comms",
  title = "Open Home Session",
  description = "Calendar and the living room in one session",
  run   = function()
    local out, err = rex.exec{ os.getenv("HOME") .. "/rex/bin/comms" }
    if err ~= nil then error(err, 0) end
    return out
  end,
}

-- Summon Rex over whatever app is in front.
rex.bind("alt+space", "client.visibility.toggle")
LUA
fi
rex config reload >/dev/null 2>&1 && ok "rex action 'comms' ready (palette: Open Home Session)"

step "Shell"
if grep -q 'rex/env.sh' "$HOME/.zshrc" 2>/dev/null; then
  ok "~/.zshrc sources ~/rex/env.sh"
else
  todo "add this line to ~/.zshrc:   source ~/rex/env.sh"
fi

step "Calendar"
printf '  %s•%s macOS grants this to %sRex Server%s, not Rex Beta:\n' "$Y" "$R" "$B" "$R"
printf '    System Settings → Privacy & Security → Calendars → Rex Server\n'

step "Surviving reboots"
if launchctl list 2>/dev/null | grep -q dev.rex.boot; then
  ok "sessions are saved every 30 minutes and restored at login"
else
  todo "turn it on with:   keep on"
fi

step "Done"
echo "  Open everything with:  rex do comms"
echo "  Put sessions back after a reboot with:  boot"
case "${1:-}" in
  --session) "$REX_DIR/bin/comms" >/dev/null && echo "  Comms session opened." ;;
esac
