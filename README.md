# conversation-stopper

Pick up a [Claude Code](https://claude.com/claude-code) conversation again after you've exited it, without having to remember `claude --resume <uuid>`.

Each time a Claude Code session ends, `conv-stop` saves it to `~/.conv-stop`. You can then list your recent conversations across every project folder and reopen one by its short id.

```
$ conv-stop list
ID  DATE              FOLDER                        SUMMARY
7   2026-11-13 00:38  ~/projects/party-defi         Building conversation-stopper tool with GitHub publishing setup
4   2026-11-12 18:02  ~/projects/ergates/sport      Fixing fixture parser for weekend league results
2   2026-11-11 09:15  ~/projects/trades-mtm         Choosing interpolation scheme for SONIA discount curve

$ conv-stop load 4        # cds to ~/projects/ergates/sport and runs claude --resume <session>
```

## Requirements

- macOS or Linux
- Python 3.8+ (standard library only)
- Claude Code (`claude` on your `PATH`)

## Install

```sh
git clone git@github.com:hardlianotion/conversation-stopper.git
cd conversation-stopper
ln -s "$PWD/conv-stop" ~/.local/bin/conv-stop   # or anywhere on your PATH
conv-stop install
```

`conv-stop install` adds a `SessionEnd` hook to `~/.claude/settings.json`. It keeps a backup of the file as `settings.json.bak`, and running it again is safe. To remove the hook, run `conv-stop uninstall`.

## Commands

| Command | What it does |
|---|---|
| `conv-stop list` | Lists the most recent conversation in each folder |
| `conv-stop list --all` | Lists every recorded conversation |
| `conv-stop load <id>` | Resumes conversation `<id>` in its own folder |
| `conv-stop show <id>` | Shows one entry's details, including the full `claude` command |
| `conv-stop delete <id>` | Forgets conversation `<id>` (`rm` also works) |
| `conv-stop install` / `uninstall` | Adds or removes the Claude Code hook |

When `conv-stop load` exits, you're back in the shell and folder you started from.

## How it works

1. When a session ends, Claude Code runs `conv-stop record` and passes it the session id, the folder and the transcript path.
2. `conv-stop` saves or updates that session's entry in `~/.conv-stop`, a JSON map. A session that has been resumed updates its existing entry and keeps its id.
3. To begin with, the summary is the first seven words of your last message. A background process then replaces it with a 7-word summary of the end of the conversation, written by a one-off `claude -p --model haiku` call. That call has no tools and doesn't save a session, and it doesn't delay your exit.
   - The call uses your normal Claude Code login, and costs a fraction of a cent per conversation.
   - If it fails, the first-seven-words summary stays.
4. Sessions in which nothing was said aren't recorded.

Each entry in `~/.conv-stop` holds: a short id, the folder, the `claude --resume` command, the date, and the summary.

## Configuration

These environment variables are optional:

| Variable | Default | Purpose |
|---|---|---|
| `CONV_STOP_FILE` | `~/.conv-stop` | Where conversations are stored |
| `CONV_STOP_MODEL` | `haiku` | Model used for summaries |
| `CONV_STOP_SETTINGS` | `~/.claude/settings.json` | Claude Code settings file used by `install` and `uninstall` |

## Related Claude Code commands

- `claude --continue` resumes the most recent conversation in the current folder.
- `claude --resume`, with no id, opens a picker of the conversations from the current folder.

`conv-stop` adds a single list covering every folder, short ids, and a summary of where each conversation stopped.

## Licence

MIT
