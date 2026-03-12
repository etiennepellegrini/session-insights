#!/usr/bin/env bash
# ======================================================================
# check-insights-size.bash
#
## Claude Code SessionStart hook — nudge if insights file needs curation
##
## SessionStart stdout is injected as context Claude can see and relay.
## If the insights file exceeds the line threshold, outputs a message
## that Claude should mention to the user.
#
# ======================================================================

INSIGHTS_FILE="$HOME/.claude/memory/session-insights.md"
MAX_LINES=200

if [ ! -f "$INSIGHTS_FILE" ]; then
    exit 0
fi

line_count=$(wc -l < "$INSIGHTS_FILE" 2>/dev/null || echo 0)

if [ "$line_count" -gt "$MAX_LINES" ]; then
    echo "Note: session-insights.md is at ${line_count} lines (threshold: ${MAX_LINES}). Mention to the user that it could use a /session-insights:curate pass."
fi

exit 0
