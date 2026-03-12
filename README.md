# session-insights

A Claude Code plugin that gives Claude a feedback loop: it writes concise
observations about your interaction patterns at the end of each session, and
you curate them on your schedule.

Claude writes unbounded. You prune when it gets long. Durable insights
graduate to your CLAUDE.md.

## How it works

```
Session start ──▶ Claude reads session-insights.md (via CLAUDE.md instruction)
                  SessionStart hook warns if file > 200 lines

    ... session ...

Session end ────▶ Stop hook blocks if transcript was substantial (> 50KB)
                  Claude writes 2-5 interaction insights, then stops

On your schedule ▶ /session-insights:curate — keep, merge, drop, or promote
```

## Install

### 1. Install the plugin

```bash
# From a local clone:
claude plugin add --path /path/to/session-insights

# Or from a marketplace (if published):
# claude plugin install session-insights@your-marketplace
```

### 2. Create the insights file

```bash
cp /path/to/session-insights/seed/session-insights.md \
   ~/.claude/memory/session-insights.md
```

The file must exist for the hooks to activate. Deleting it disables
everything — instant kill switch.

### 3. Add to your CLAUDE.md

Append to your CLAUDE.md (or equivalent memory file):

```markdown
### Session Insights

**At session start, read `~/.claude/memory/session-insights.md`** for observations from previous sessions about interaction patterns, workflow dynamics, and working style — things that help you work with me more effectively. 
Writing to this file is handled by the `session-insights` plugin; don't write to it unprompted.
```

## Commands

| Command | What it does |
|---------|-------------|
| `/session-insights:reflect` | Write 2-5 insights about the current session. Use anytime. |
| `/session-insights:curate` | Review all insights: keep, merge, drop, or promote to CLAUDE.md. |

## Hooks

| Event | Behavior |
|-------|----------|
| **Stop** | If transcript > 50KB and insights file exists, blocks and asks Claude to reflect. Skips if already reflecting (loop prevention). |
| **SessionStart** | If insights file > 200 lines, outputs a nudge that Claude relays to you. |

## Configuration

Tunable constants in the hook scripts:

| Variable | File | Default | Purpose |
|----------|------|---------|---------|
| `MIN_TRANSCRIPT_KB` | `hooks/scripts/reflect-on-stop.bash` | 50 | Minimum transcript size to trigger auto-reflection |
| `MAX_LINES` | `hooks/scripts/check-insights-size.bash` | 200 | Line count threshold for curation nudge |
| `INSIGHTS_FILE` | both scripts | `~/.claude/memory/session-insights.md` | Path to insights file |

## Notes

**Resumed sessions:** If you resume a session with `--continue` or `--resume`, the Stop hook will analyze the **entire** transcript again when you exit, including portions already reflected upon. This can result in duplicate or overlapping insights. Use `/curate` to merge similar observations after long multi-part sessions.

## Design

**Single source of truth:** The Stop hook reads `commands/reflect.md` at
runtime and embeds its content in the blocking reason. No instruction
duplication between the hook and the slash command.

**Separation of concerns:**
- `/reflect` and the Stop hook only *write* — no size awareness, no pruning
- `/curate` only *prunes* — categorizes, merges, drops, occasionally promotes
- The SessionStart hook only *nudges* — checks line count, surfaces a message

**Editorial control:** Claude proposes observations; you decide what stays.
Nothing touches CLAUDE.md without your explicit approval via `/curate`.

**Opt-in:** Both hooks check for the insights file's existence before doing
anything. Delete the file to disable all behavior without touching settings.

## Plugin structure

```
session-insights/
├── .claude-plugin/
│   └── plugin.json              # manifest
├── commands/
│   ├── reflect.md               # /session-insights:reflect
│   └── curate.md                # /session-insights:curate
├── hooks/
│   ├── hooks.json               # Stop + SessionStart hook config
│   └── scripts/
│       ├── reflect-on-stop.bash     # Stop hook logic
│       └── check-insights-size.bash # SessionStart hook logic
├── seed/
│   └── session-insights.md      # Copy to ~/.claude/memory/
└── README.md
```

## License

MIT
