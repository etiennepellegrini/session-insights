# session-insights plugin

This plugin enables Claude to build a feedback loop about interaction patterns.

## What it does

- **Stop hook**: Triggers auto-reflection after substantial sessions (>50KB transcript)
- **SessionStart hook**: Nudges for curation when insights file exceeds 200 lines
- **Commands**: `/reflect` (write insights), `/curate` (review/prune)

## Key behaviors

**When writing insights** (via `/reflect` or Stop hook):
- Focus on *interaction dynamics* (workflow, communication, preferences), not task summaries
- Format: `- [tag] Observation text` under `## YYYY-MM-DD` headers
- Tags: `[workflow]` `[communication]` `[technical]` `[preference]` `[blindspot]`
- 2-5 insights per session, specific and actionable

**When curating** (via `/curate`):
- Categorize each insight: Keep, Merge, Drop, or Promote
- Only promote insights validated across multiple sessions
- Get explicit user approval before modifying CLAUDE.md

## Opt-in mechanism

All functionality is gated on `~/.claude/memory/session-insights.md` existence. If the file doesn't exist, hooks do nothing (instant disable without changing settings).

## Design principles

- Single source of truth: Stop hook reads `commands/reflect.md` at runtime
- Separation of concerns: reflect writes, curate prunes, SessionStart nudges
- Editorial control: Claude proposes, user decides what stays
- Loop prevention: `stop_hook_active` flag prevents infinite reflection cycles
