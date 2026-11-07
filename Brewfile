# What this setup needs. `brew bundle --file=Brewfile`
#
# Brewfile.full is the unedited dump from the machine this came from, if you want
# something that is not here.

tap "felixkratz/formulae"

# The shell. ~/.zshrc aliases every one of these over a standard command name, so
# without them `ls`, `cat`, `grep`, `find`, `ps`, `du`, `df` and `top` are plain again.
brew "eza"                      # ls
brew "bat"                      # cat
brew "ripgrep"                  # grep
brew "fd"                       # find
brew "procs"                    # ps
brew "dust"                     # du
brew "duf"                      # df
brew "btop"                     # top
brew "tokei"                    # cloc
brew "jless"                    # json
brew "glow"                     # md
brew "watchexec"                # watch
brew "lazygit"                  # lg
brew "helix"                    # nano
brew "neovim"                   # v, vi, vim
brew "yazi"                     # the y function
brew "fastfetch"                # runs at shell start

# Prompt, history, completion, jumping. Each is loaded behind `command -v`, so a
# missing one degrades quietly rather than erroring.
brew "starship"
brew "atuin"
brew "zoxide"
brew "fzf"
brew "carapace"
brew "direnv"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# What ~/rex/bin actually calls.
brew "jq"                       # comms, work, snapshot
brew "gh"                       # github-pane
brew "git-delta"                # the pull request diffs
brew "mpv"                      # play
brew "yt-dlp"                   # play, for links
brew "ical-buddy"               # a fallback for the agenda
brew "felixkratz/formulae/sketchybar"

cask "ghostty"
cask "hammerspoon"
cask "inkdrop"
cask "finicky"
cask "orion"
cask "font-jetbrains-mono-nerd-font"

# Not needed for the setup, but probably wanted. Uncomment what applies.
# brew "encoredev/tap/encore"   # work
# brew "go"
# brew "node"
# brew "deno"
# brew "ffmpeg"
# brew "whisper.cpp"
# cask "blender"                # the car projects
# cask "claude-code"
# cask "ngrok"
