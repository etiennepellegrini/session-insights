#!/usr/bin/env bash
# ======================================================================
# reflect-on-stop.bash
#
## Claude Code Stop hook — nudge Claude to write session insights
##
## Reads the reflect.md command file for instructions (single source of
## truth) and embeds them in the blocking reason so the main model does
## the reflection.
##
## Triggers only when:
##   1. Not already in a reflection loop (stop_hook_active)
##   2. Session transcript exceeds size threshold
##   3. Insights file exists (opt-in gate)
##
## Requires: jq
#
# ======================================================================

INSIGHTS_FILE="$HOME/.claude/memory/session-insights.md"
MIN_TRANSCRIPT_KB=50

# --- Locate plugin root (set by Claude Code for plugin hooks)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
REFLECT_MD="$PLUGIN_ROOT/commands/reflect.md"

# --- Read Stop event JSON from stdin
input=$(cat)

# --- Prevent infinite loops
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')
if [ "$stop_hook_active" = "true" ]; then
    exit 0
fi

# --- Check that the insights file exists (opt-in gate)
if [ ! -f "$INSIGHTS_FILE" ]; then
    exit 0
fi

# --- Check transcript size as proxy for session substance
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
    exit 0
fi

transcript_kb=$(( $(wc -c < "$transcript_path" 2>/dev/null || echo 0) / 1024 ))
if [ "$transcript_kb" -lt "$MIN_TRANSCRIPT_KB" ]; then
    exit 0
fi

# --- Build reflection instructions from reflect.md
if [ -f "$REFLECT_MD" ]; then
    # Strip the $ARGUMENTS placeholder, escape for JSON
    instructions=$(sed '/$ARGUMENTS/d' "$REFLECT_MD" | jq -Rs .)
    # Remove surrounding quotes that jq -Rs adds (we'll embed in our own JSON string)
    instructions=${instructions:1:-1}
else
    # Fallback if reflect.md is missing
    instructions="Append 2-5 concise interaction insights to ~/.claude/memory/session-insights.md. Focus on workflow patterns, communication dynamics, or technical preferences — not task summaries."
fi

# --- Block stop and ask Claude to reflect
cat <<EOF
{"decision":"block","reason":"This was a substantial session. Before stopping:\\n\\n${instructions}"}
EOF

exit 0
