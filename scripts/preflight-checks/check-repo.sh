#!/usr/bin/env bash
set -euo pipefail

: "${OWNER:?OWNER env var required}"
: "${REPO:?REPO env var required}"

emit() {
  local check="$1" status="$2" message="$3" fix="${4:-}"
  if [ -n "$fix" ]; then
    jq -nc --arg c "$check" --arg s "$status" --arg m "$message" --arg f "$fix" \
      '{check:$c, status:$s, message:$m, fix:$f}'
  else
    jq -nc --arg c "$check" --arg s "$status" --arg m "$message" \
      '{check:$c, status:$s, message:$m}'
  fi
}

# repo.wiki
has_wiki="$(gh api "repos/${OWNER}/${REPO}" --jq '.has_wiki' 2>/dev/null || echo "false")"
if [ "$has_wiki" = "true" ]; then
  emit "repo.wiki" "pass" "Wiki is enabled for ${OWNER}/${REPO}"
else
  emit "repo.wiki" "fail" "Wiki is not enabled for ${OWNER}/${REPO}" \
    "Enable in repo Settings > General > Features > Wiki"
fi

# repo.issue_types
if gh api "repos/${OWNER}/${REPO}/issue-types" --jq '.' &>/dev/null; then
  emit "repo.issue_types" "pass" "Issue Types API is available"
else
  emit "repo.issue_types" "warn" "Issue Types API not available — will use type: labels instead"
fi

# repo.sub_issues
test_issue="$(gh api "repos/${OWNER}/${REPO}/issues" --jq '.[0].number' 2>/dev/null || echo "")"
if [ -z "$test_issue" ] || [ "$test_issue" = "null" ]; then
  emit "repo.sub_issues" "warn" "No issues found in repo — cannot test sub-issues API"
else
  http_status="$(gh api "repos/${OWNER}/${REPO}/issues/${test_issue}/sub_issues" --silent -i 2>&1 | head -1 | awk '{print $2}')"
  if [ "$http_status" = "200" ] || [ "$http_status" = "404" ]; then
    emit "repo.sub_issues" "pass" "Sub-issues API is accessible (HTTP ${http_status} on issue #${test_issue})"
  else
    emit "repo.sub_issues" "warn" "Sub-issues API returned unexpected status ${http_status} for issue #${test_issue}"
  fi
fi
