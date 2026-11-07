# Rex setup

Everything that turns this terminal into the place the work happens. Rebuild it on a new
machine with `./install.sh`, then `rex do comms`.


## On a fresh Mac

Read [SETUP.md](SETUP.md). It describes the whole machine in the order things have to
happen, and says which parts a human still has to do. It is written to be handed to an
agent: "here are my dotfiles, set this up".

## The Home session

One Rex session, two tabs, built by `bin/comms`:

| Tab | What it is |
| --- | --- |
| Calendar | Today, tomorrow or the week, with the event you click spelled out below |
| TV | The living room: pick an album, open an app, work the volume |

## After a reboot

The Rex server does not survive a restart, so the sessions go with it. `snapshot` writes down
what is open; `boot` puts it back.

```sh
snapshot      # save every session: tabs, panes, and the directory each one was in
boot          # recreate anything from that file that is not already open
boot --dry-run
keep on       # save every 30 minutes and restore at login (launchd agents)
```

`Comms` is saved as a recipe rather than a layout, so `boot` rebuilds it with `bin/comms`.
Other sessions come back as their tabs and panes, each in the right directory.

## Commands

| Command | What it does |
| --- | --- |
| `comms` | build or focus the session |
| `snapshot` / `boot` | save the open sessions, put them back after a reboot |
| `keep on` | do that automatically: save every 30 minutes, restore at login |
| `web <url>` | browse in a pane, no ads, no popups (`--text` drops images too); also what `$BROWSER` points at |
| `read <url>` | an article as plain text, without the page around it |
| `news [url]` | headlines to pick from, then read |
| `play <file\|url>` | video and audio in the terminal (`--audio`, `--tv`) |
| `preview <file>` | one image, PDF page or frame |
| `tv <command>` | the TV from the command line: status, apps, yt, music, vol, say, off |
| `agenda-pane`, `tv-pane` | the clickable panes, runnable on their own |
| `agenda` | the same calendar as plain text (`--watch` to keep it on screen) |
| `adproxy` | the filtering proxy, started automatically by `web` |

## Where things live

- `bin/` — every tool, dependency-free where possible; the clickable ones run on `venv/`
- `env.sh` — PATH and BROWSER, sourced from `~/.zshrc`
- `~/.config/rex-comms/` — repos, bots, TV apps, mail account, Discord channels
- `~/.config/rex/init.lua` — the `comms` action and the ⌥Space summon key

## Calendar access

Calendars are read by `bin/agenda-events`, a small EventKit program in the venv. It has to
be that rather than `osascript`, which macOS treats as its own identity and refuses without
ever prompting. Panes are children of **Rex Server** (`com.superlogical.rex.server`), a
separate app from Rex Beta, so that is the entry to enable under Privacy & Security →
Calendars. `tccutil reset Calendar com.superlogical.rex.server` clears a stale refusal.

## The TV

The living room is a rooted webOS TV reached over `ssh tv`, with Shelf (the music app)
serving from the Mac mini at `10.0.0.104:8742`. The TV pane lists the library and starts
playback through a command the Shelf app polls for:

- `POST /api/command {"action": "play", "args": {"id": "<album id>"}}`
- the app checks `GET /api/command?since=<seq>` every two seconds and acts on it
- actions: `play`, `pause`, `next`, `previous`, `stop`

That lives in `~/shelf/server/shelf_server.py` and `~/shelf/app/app.js`, deployed to the
mini (`docker restart shelf`) and to the TV
(`scp app.js tv:/media/developer/apps/usr/palm/applications/com.local.shelf/`).
