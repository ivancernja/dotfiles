# Setting this up on a fresh Mac

Point an agent at this file. It describes the whole machine, in the order things have to
happen, and says plainly which parts a human still has to do.

What you end up with: Rex as the terminal with its panes and saved sessions, five macOS
desktops on cmd+1 to cmd+5 with apps pinned to them, SketchyBar instead of the menu bar,
Hammerspoon handling window sizing and the page keys, Neovim with LazyVim, Inkdrop with
vim keys, and the shell with its aliases and tools.

## Order

Each step depends on the one before it. Do not skip ahead.

### 1. Prerequisites

```sh
xcode-select --install                     # if git is missing
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
gh auth login                              # needed before anything clones
```

### 2. Clone this repo

It must live at `~/rex`, because the tools reference that path directly.

```sh
git clone https://github.com/ivancernja/dotfiles.git ~/rex
cd ~/rex
```

### 3. Packages

```sh
brew bundle --file=Brewfile
```

37 entries, which is what this setup actually needs rather than everything that happened
to be installed: the CLI tools `~/.zshrc` aliases over standard commands (eza, bat,
ripgrep, fd, procs, dust, duf, btop and the rest), the prompt and history tools, what
`~/rex/bin` calls (jq, gh, delta, mpv), SketchyBar, and the JetBrains Mono Nerd Font that
SketchyBar and the terminal both need. Five casks: Ghostty, Hammerspoon, Inkdrop, Finicky
and the font.

A commented section at the bottom holds the things that are probably wanted but are not
part of the setup, such as Encore, Go, Node and Blender. `Brewfile.full` is the unedited
dump of all 78 if something is missing.

Rex itself is not in Homebrew. Install it from superlogical.com and launch it once, so the
server registers its launch agent.

### 4. The Python environment

The panes are Textual apps and run from their own virtualenv.

```sh
python3 -m venv ~/rex/venv
~/rex/venv/bin/pip install -r ~/rex/requirements.txt
```

### 5. Put the config files in place

```sh
./bin/dotfiles push
```

That copies `home/` out to where each file belongs: `~/.zshrc`, `~/.hammerspoon/init.lua`,
`~/.config/rex/init.lua`, `~/.config/nvim/`, `~/.config/sketchybar/`, Inkdrop's `init.js`
and `keymap.json`, and `~/.config/rex-comms/workspaces.json`.

Then make the shell load it:

```sh
echo 'source "$HOME/rex/env.sh"' >> ~/.zshrc
```

Without that line `~/rex/bin` is not on PATH, `$BROWSER` is unset, and the agent pane
hooks never load. It is the single easiest thing to forget.

### 6. SSH keys

```sh
./bin/restore-ssh
```

Then read **Rotate the keys** below. Do not skip it.

### 7. Tools and launch agents

```sh
./install.sh
```

### 8. macOS settings

```sh
./macos-defaults.sh
```

This binds cmd+1 to cmd+5 to the five desktops, stops macOS reordering desktops by recent
use, hides the menu bar so SketchyBar can take the top, sets the Dock to hide but stay
reachable, and pins each app to its desktop.

The app pinning resolves space UUIDs from the live machine rather than copying them, since
they differ on every Mac. If fewer than five desktops exist it says so and does nothing
else; add them in Mission Control and run it again.

### 9. Start SketchyBar

```sh
brew services start sketchybar
```

### 10. Inkdrop's vim plugin

Inkdrop 6 ships no `ipm`, and the plugin is TypeScript with no built `lib`, so it has to
be compiled:

```sh
git clone --depth 1 https://github.com/inkdropapp/inkdrop-vim /tmp/inkdrop-vim
cd /tmp/inkdrop-vim && npm install && npm run build
mkdir -p ~/Library/Application\ Support/inkdrop/packages/vim
cp -R package.json lib styles keymaps ~/Library/Application\ Support/inkdrop/packages/vim/
```

Its dependencies bundle into `lib/index.js`, so no `node_modules` is needed at runtime.

## What a human still has to do

None of this can be scripted.

- **Log out once.** The menu bar only disappears after WindowServer re-reads the setting at
  login, and newly created desktops only register their shortcuts then too.
- **Grant Accessibility to Hammerspoon** in System Settings, Privacy and Security. Window
  sizing, the page keys and the window rescue all depend on it.
- **Create five desktops** in Mission Control if `macos-defaults.sh` says there are fewer.
- **Raycast** cannot be transferred. Its config is in SQLCipher databases with the key in
  the keychain. Install it, set the hotkey to cmd+Space (moving Spotlight to ctrl+Space),
  and re-add the extensions and the cmd+shift app shortcuts by hand.
- **Login items**: Raycast and Hammerspoon. Nothing else.
- **SSH keys** are in this repo, under `secrets/ssh`. `./bin/restore-ssh` puts them in
  `~/.ssh` with the right permissions, and never overwrites a key that is already there.
  Then rotate them, which is the next section.

## Rotate the keys

The private keys for the TV and the mini are committed here so a fresh machine can reach
both without needing a second device to hand. That is a deliberate trade, and it is meant
to be temporary: anything committed stays in git history, so these keys should be replaced
once the new machine works.

Once `ssh tv` and `ssh mini` both answer:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/id_lgtv_new -N ""
ssh-keygen -t ed25519 -f ~/.ssh/id_mini_new -N ""

ssh-copy-id -i ~/.ssh/id_lgtv_new.pub tv
ssh-copy-id -i ~/.ssh/id_mini_new.pub mini
```

Check the new keys work, point `~/.ssh/config` at them, remove the old public keys from
`~/.ssh/authorized_keys` on each host, then clear them from here:

```sh
cd ~/rex
git rm -r --cached secrets/ssh
rm -rf secrets/ssh
echo "secrets/" >> .gitignore
git commit -m "Remove the ssh keys after rotating them"
git push
```

That stops them being handed to the next clone. It does not remove them from history, so
the old keys stay readable to anyone who already has one. That is fine once the hosts no
longer accept them, which is the point of doing this.

## Credentials

Each tool prints its own setup steps when its credential is missing, so running it is the
quickest way to find out what it wants.

| What | Where it lives | How to set it |
|---|---|---|
| Linear | keychain `linear-terminal` | `linear-login` |
| GitHub | `gh` keyring | `gh auth login` |
| The TV | ssh key for `root@10.0.0.123` | copy the key, add a `tv` host to `~/.ssh/config` |
| The mini | ssh, then `mini-link` | same tailnet |
| Calendar | TCC grant to **Rex Server** | System Settings, Privacy and Security, Calendars |

## Checking it worked

```sh
workspace                 # five workspaces listed
rex do work               # Linear and pull requests
rex do comms              # calendar and TV
snapshot --list           # profiles
sketchybar --query bar    # eight items
```

In the interface: cmd+1 to cmd+5 move between desktops, a new window opens almost
maximized, ctrl+alt+cmd+R rescues a window stranded off screen, and opening a second window
on a desktop says so.

## Things that are deliberately absent

- **Karabiner-Elements** broke system-wide key repeat through an unapproved DriverKit
  extension. Do not reinstall it.
- **yabai, skhd and AeroSpace** were all tried and removed. macOS 26 no longer lets a
  window move between Spaces programmatically, so pinning apps to desktops is the only
  approach that works.
