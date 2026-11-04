# Rex tools. Add this line to ~/.zshrc:  source ~/rex/env.sh
export PATH="$HOME/rex/bin:$PATH"
export BROWSER="$HOME/rex/bin/web"   # links open in a pane; `open <url>` still uses Chrome

# On a machine without the Rex app, the CLI lives in the server bundle.
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
