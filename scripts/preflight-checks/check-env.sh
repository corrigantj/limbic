#!/usr/bin/env bash
set -euo pipefail

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

# env.gh_cli
if ! command -v gh &>/dev/null; then
  emit "env.gh_cli" "fail" "GitHub CLI (gh) not found" "Install GitHub CLI: https://cli.github.com/"
  exit 0
fi
emit "env.gh_cli" "pass" "GitHub CLI found: $(command -v gh)"

# env.gh_auth
if ! gh auth status &>/dev/null; then
  emit "env.gh_auth" "fail" "Not authenticated with GitHub CLI" "Run: gh auth login"
else
  username="$(gh api user --jq '.login' 2>/dev/null || echo "unknown")"
  emit "env.gh_auth" "pass" "Authenticated as ${username}"
fi

# env.git_repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  emit "env.git_repo" "fail" "Not inside a git repository" "Run: git init"
  exit 0
fi
emit "env.git_repo" "pass" "Inside a git repository"

# env.github_remote
remote_url="$(git remote get-url origin 2>/dev/null || echo "")"
if [ -z "$remote_url" ]; then
  emit "env.github_remote" "fail" "No remote 'origin' configured"
elif echo "$remote_url" | grep -qE 'github\.com|github\.dev'; then
  emit "env.github_remote" "pass" "GitHub remote found: ${remote_url}"
else
  emit "env.github_remote" "fail" "Remote 'origin' does not point to GitHub: ${remote_url}"
fi

# env.python_yaml
if ! command -v python3 &>/dev/null; then
  emit "env.python_yaml" "warn" "python3 not found — YAML config validation will be skipped" "Install Python 3: https://www.python.org/downloads/"
elif ! python3 -c "import yaml" &>/dev/null; then
  emit "env.python_yaml" "warn" "PyYAML not installed — YAML config validation will be skipped" "Run: pip3 install pyyaml"
else
  emit "env.python_yaml" "pass" "python3 and PyYAML are available"
fi
