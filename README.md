# Rex setup

Everything that turns this terminal into the place the work happens. Rebuild it on a new
machine with `./install.sh`, then `rex do comms`.

## The Comms session

One Rex session, six tabs, built by `bin/comms`:

| Tab | What it is |
| --- | --- |
| Mail | Gmail over IMAP, clickable: folders, message list, reader, reply and send |
| Feeds | Today's agenda, Slack DMs and mentions, Discord channels |
| PRs | Every open pull request in the encoredev org, with Vercel preview links |
| TV | The living room: pick an album, open an app, work the volume |
| Web | Carbonyl behind an ad-filtering proxy, popups blocked, pages forced dark |
| Bots | Whatever is in `~/.config/rex-comms/bots.tsv` |

## Commands

| Command | What it does |
| --- | --- |
| `comms` | build or focus the session |
| `web <url>` | browse in a pane, no ads, no popups (`--text` drops images too) |
| `read <url>` | an article as plain text, without the page around it |
| `news [url]` | headlines to pick from, then read |
| `play <file\|url>` | video and audio in the terminal (`--audio`, `--tv`) |
| `preview <file>` | one image, PDF page or frame |
| `tv <command>` | the TV from the command line: status, apps, yt, music, vol, say, off |
| `prs`, `mail`, `feeds`, `tv-pane` | the clickable panes, runnable on their own |
| `adproxy` | the filtering proxy, started automatically by `web` |

## Where things live

- `bin/` — every tool, dependency-free where possible; the clickable ones run on `venv/`
- `env.sh` — PATH and BROWSER, sourced from `~/.zshrc`
- `~/.config/rex-comms/` — repos, bots, TV apps, mail account, Discord channels
- `~/.config/rex/init.lua` — the `comms` action and the ⌥Space summon key
- Keychain — `rex-gmail`, `rex-slack`, `rex-discord`

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
