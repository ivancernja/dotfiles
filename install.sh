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
BREW_PKGS="aerc w3m ical-buddy mpv yt-dlp fzf jq gh git-delta glow lazygit btop yazi ripgrep"
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
  "$PY" -m venv "$REX_DIR/venv" && "$REX_DIR/venv/bin/pip" -q install textual
fi
"$REX_DIR/venv/bin/python" -c "import textual" 2>/dev/null && ok "textual" || todo "textual did not install"

step "Config"
mkdir -p "$CONF" "$HOME/.local/state/rex-comms"
[ -f "$CONF/repos.txt" ] || printf 'encoredev/www\nencoredev/examples\n' > "$CONF/repos.txt"
[ -f "$CONF/bots.tsv" ] || printf 'claude\tclaude\ncodex\tcodex\n' > "$CONF/bots.tsv"
[ -f "$CONF/discord.json" ] || printf '{\n  "channels": []\n}\n' > "$CONF/discord.json"
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
[ -f "$CONF/mail.json" ] || printf '{\n  "address": "ivan@encore.dev",\n  "imap": "imap.gmail.com",\n  "smtp": "smtp.gmail.com",\n  "name": "Ivan"\n}\n' > "$CONF/mail.json"
ok "config in $CONF"

step "Rex"
mkdir -p "$HOME/.config/rex"
if ! grep -q 'name  = "comms"' "$HOME/.config/rex/init.lua" 2>/dev/null; then
  cat >> "$HOME/.config/rex/init.lua" <<'LUA'

-- Comms: mail, feeds, pull requests, the TV, web and bots.
rex.action{
  name  = "comms",
  title = "Open Comms Session",
  description = "Mail, feeds, pull requests, the TV, web and bots in one session",
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
rex config reload >/dev/null 2>&1 && ok "rex action 'comms' ready (palette: Open Comms Session)"

step "Shell"
if grep -q 'rex/env.sh' "$HOME/.zshrc" 2>/dev/null; then
  ok "~/.zshrc sources ~/rex/env.sh"
else
  todo "add this line to ~/.zshrc:   source ~/rex/env.sh"
fi

step "Credentials still needed"
for entry in "rex-gmail:Gmail app password" "rex-slack:Slack user token" "rex-discord:Discord bot token"; do
  service="${entry%%:*}"; what="${entry#*:}"
  if security find-generic-password -s "$service" >/dev/null 2>&1; then
    ok "$what"
  else
    todo "$what — security add-generic-password -s $service -a me -w"
  fi
done
printf '  %s•%s Calendar: System Settings → Privacy & Security → Calendars → Rex Beta\n' "$Y" "$R"

step "Done"
echo "  Open everything with:  rex do comms"
case "${1:-}" in
  --session) "$REX_DIR/bin/comms" >/dev/null && echo "  Comms session opened." ;;
esac
