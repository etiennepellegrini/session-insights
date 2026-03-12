---
description: Write 2-5 session insights to memory
color: blue
---

Review this session and append 2-5 concise observations to `~/.claude/memory/session-insights.md`.

Focus on interaction patterns, workflow preferences, communication dynamics, or technical learnings about how the user works — NOT summaries of what was accomplished.

Good insights: things you'd want a future instance to know that aren't already in CLAUDE.md. For example:
- How the user responded to different explanation styles
- Workflow patterns (e.g., preferred order of operations, review habits)
- Technical preferences revealed by choices made during the session
- Moments where your approach needed correction and why
- Blind spots that surfaced

Each insight is one line: `- [tag] Observation text`
Tags: `[workflow]` `[communication]` `[technical]` `[preference]` `[blindspot]`
Group under a `## YYYY-MM-DD` date header; reuse today's if it exists.
Be specific and actionable, not generic.

Example output:
```markdown
## 2026-03-11
- [workflow] Prefers validating with external tools before manual review
- [communication] Responds well to concise explanations with optional detail
```

$ARGUMENTS
