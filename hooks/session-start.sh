#!/usr/bin/env bash
# SessionStart hook for limbic plugin
# Injects a slim routing table — replaces the old using-limbic skill injection

set -euo pipefail

# Escape string for JSON embedding
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

routing_table="<LIMBIC_PLUGIN>
You have project management capabilities via the limbic plugin.

## Skill Routing

| User Intent | Skill |
|---|---|
| First-time setup / \"setup\" / fix drift | limbic:setup |
| New feature / project / \"plan this\" | superpowers:brainstorming then limbic:structure |
| \"Break this down\" / has a PRD | limbic:structure |
| \"Start working\" / \"Dispatch\" | limbic:dispatch |
| \"What's the status?\" | limbic:status |
| \"Review PRs\" / \"Check feedback\" | limbic:review |
| \"Merge\" / \"Ship it\" / \"Integrate\" | limbic:integrate |

## Flow

setup -> brainstorming -> structure -> dispatch -> status -> review -> integrate

## Preflight

A hook runs preflight checks before structure, dispatch, review, and integrate (not setup or status).
If checks fail, read the JSONL report and remediate before proceeding.
</LIMBIC_PLUGIN>"

escaped=$(escape_for_json "$routing_table")

cat <<EOF
{
  "additional_context": "${escaped}",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${escaped}"
  }
}
EOF

exit 0
