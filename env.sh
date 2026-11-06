# Rex tools. Add this line to ~/.zshrc:  source ~/rex/env.sh
export PATH="$HOME/rex/bin:$PATH"
export BROWSER="$HOME/rex/bin/web"   # links open in a pane; `open <url>` still uses Chrome

# On a machine without the Rex app, the CLI lives in the server bundle.
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# Keep an editor pane beside any pane running a coding agent.
# preexec fires the moment you launch one and knows the folder; precmd fires when it
# exits. $REX_BLOCK is set in every Rex pane, so the hooks are inert in other terminals.
# ~/rex/bin/agent-pair does the work, and `agent-pair scan` covers panes that were already
# running an agent before these hooks existed.
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz add-zsh-hook
  _rex_agent_pane=0

  _rex_pair_preexec() {
    [ -n "$REX_BLOCK" ] || return
    case "${1%% *}" in
      claude|codex)
        _rex_agent_pane=1
        ( "$HOME/rex/bin/agent-pair" open "$PWD" >/dev/null 2>&1 & )
        ;;
    esac
  }

  _rex_pair_precmd() {
    [ -n "$REX_BLOCK" ] || return
    if [ "$_rex_agent_pane" = "1" ]; then
      _rex_agent_pane=0
      ( "$HOME/rex/bin/agent-pair" close >/dev/null 2>&1 & )
    fi
  }

  add-zsh-hook preexec _rex_pair_preexec
  add-zsh-hook precmd _rex_pair_precmd
fi
