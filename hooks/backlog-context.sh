#!/usr/bin/env bash
# backlog-context.sh — PreToolUse hook for brainstorming context injection
# Injects backlog item count when superpowers:brainstorming is invoked.
# Does NOT gate — always allows. Only adds context.

set -uo pipefail

# Read tool input from stdin
input=$(cat)

# Extract skill name from the Skill tool input
skill_name=$(echo "$input" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    skill = data.get('skill', '') or data.get('tool_input', {}).get('skill', '')
    print(skill)
except Exception:
    print('')
" 2>/dev/null) || skill_name=""

# Only inject context for brainstorming
if [ "$skill_name" != "superpowers:brainstorming" ]; then
  echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
  exit 0
fi

# Detect owner/repo from git remote
repo_slug=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null) || repo_slug=""

if [ -z "$repo_slug" ]; then
  echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
  exit 0
fi

# Count open backlog items across all tiers
# gh --label does AND matching, so query each tier separately
count=0
for tier in now next later icebox; do
  n=$(gh issue list --repo "$repo_slug" --label "backlog:${tier}" \
    --state open --json number --jq 'length' 2>/dev/null || echo 0)
  count=$((count + n))
done

# No backlog items — allow without context
if [ "$count" -eq 0 ]; then
  echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
  exit 0
fi

# Build the system message
read -r -d '' msg <<SYSMSG || true
This repo has ${count} open backlog items. Early in the brainstorming session, ask the user: "There are ${count} items in the backlog. Want me to check for anything relevant to what we're working on?" If they say yes, fetch the backlog issues with:
  for tier in now next later icebox; do
    gh issue list --repo ${repo_slug} --label "backlog:\${tier}" --state open --json number,title,labels
  done
Merge the results, cluster by theme, and present a summary.
SYSMSG

# Escape for JSON
escaped_msg=$(python3 -c "
import sys, json
print(json.dumps(sys.stdin.read().strip()))
" <<< "$msg" 2>/dev/null) || escaped_msg="\"backlog context unavailable\""

echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"allow\"},\"systemMessage\":${escaped_msg}}"
exit 0
