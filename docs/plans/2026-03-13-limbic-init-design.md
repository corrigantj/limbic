# Design: `limbic:init` — Setup, Configuration & Preflight

**Date:** 2026-03-13
**Status:** Draft

---

## Problem

The limbic plugin assumes a fully configured GitHub environment — wiki enabled, labels created, gh CLI authenticated, correct permissions. Users discover missing prerequisites mid-`structure` as cryptic errors. There is no standalone setup flow, no way to validate the environment, and no way to detect or fix drift after initial configuration.

Additionally, `using-limbic` duplicates prerequisite and capability detection logic that belongs in a deterministic, hookable script — not an LLM skill.

## Design Summary

Three new components:

1. **`limbic:init` skill** — Conversational wizard that produces `.github/limbic.yaml`, plus remediation logic that converges GitHub state to match the config.
2. **Modular preflight check scripts** — Deterministic bash scripts under `scripts/preflight-checks/` that validate environment, repo capabilities, config, labels, and wiki state. Output is JSONL. Never mutate — only report.
3. **PreToolUse hook** — Runs preflight before `structure`, `dispatch`, `review`, `integrate`. Returns `deny` with JSONL report on failure, `allow` on success with JSONL injected as `additionalContext`.

Additionally, `using-limbic` is deleted and replaced by a slim routing table injected via the session-start hook.

## Key Design Decisions

- **Preflight scripts are purely diagnostic.** They check and report, never mutate. The model reads the report and decides how to remediate.
- **`init` is idempotent.** Run it once to bootstrap, run it again to detect and fix drift. It converges — never destructive.
- **Merge strategy is not configurable.** The two-wave model (rebase task PRs into feature, squash feature into main) is opinionated and hardcoded.
- **Capability detection results flow via context injection.** The preflight JSONL is injected by the hook; downstream skills read it from context. No state files.
- **`using-limbic` is eliminated.** Its routing table moves to the session-start hook. Its prerequisite and capability checks move to the preflight scripts.

---

## File Structure

```
limbic/
├── skills/
│   └── init/
│       └── SKILL.md                    # Conversational wizard + remediation logic
├── scripts/
│   └── preflight-checks/
│       ├── runner.sh                   # Orchestrator — runs all checks, aggregates JSONL
│       ├── check-env.sh               # gh CLI, git repo, GitHub remote
│       ├── check-repo.sh              # Wiki enabled, Issue Types API, Sub-issues API
│       ├── check-config.sh            # limbic.yaml exists, parses, schema valid
│       ├── check-labels.sh            # Label taxonomy matches config
│       └── check-wiki.sh              # Wiki cloneable, Home page, templates
├── hooks/
│   ├── hooks.json                     # SessionStart + PreToolUse hooks
│   ├── session-start.sh               # Slim routing table injection (replaces using-limbic)
│   └── preflight.sh                   # PreToolUse wrapper — skips init/status, delegates to runner
```

---

## Preflight Check Scripts

### Output Format (JSONL)

Each check emits one JSON line per item:

```json
{"check": "env.gh_cli", "status": "pass", "message": "gh 2.45.0 authenticated as corrigantj"}
{"check": "repo.wiki", "status": "fail", "message": "Wiki not enabled", "fix": "Enable in repo Settings > General > Features > Wiki"}
{"check": "labels.missing", "status": "fail", "message": "Missing label: priority:critical", "fix": "gh label create \"priority:critical\" --color \"b60205\" --description \"Must have -- blocks project\" --force"}
```

Fields:
- `check` — Dotted identifier (category.item)
- `status` — `pass`, `fail`, or `warn`
- `message` — Human-readable description
- `fix` — Suggested remediation (shell command or human instruction)

### runner.sh

- Accepts config path argument (defaults to `.github/limbic.yaml`)
- Auto-detects owner/repo from git remote
- Runs all check scripts in order, concatenates JSONL output
- Accepts `--check <name>` flag to run a single check category
- Exit 0 if all pass, exit 1 if any fail

### check-env.sh

- `gh` CLI installed and in PATH
- `gh auth status` passes (authenticated)
- Current directory is a git repo
- Git remote points to GitHub

### check-repo.sh

- Wiki enabled (`gh api repos/{owner}/{repo} --jq '.has_wiki'`)
- Issue Types API available (`gh api repos/{owner}/{repo}/issue-types` — 200 = available, 404 = unavailable)
- Sub-issues API available (`gh api repos/{owner}/{repo}/issues/1/sub_issues` — 200 or 404 = available, 422 = unavailable; if issue #1 does not exist, use `gh api repos/{owner}/{repo}/issues --jq '.[0].number'` to find any issue, or report as `warn` if repo has no issues)

### check-config.sh

- `.github/limbic.yaml` exists
- Parses as valid YAML (no syntax errors)
- Required fields present or defaults apply cleanly
- No unknown top-level keys (catches typos) — valid keys defined by `templates/limbic.yaml` in the plugin: `project`, `agents`, `branches`, `worktrees`, `approval_gates`, `commands`, `labels`, `wiki`, `epics`, `validation`, `review`, `sizing` (nested key validation is not in scope — only top-level)

### check-labels.sh

- Fetches all repo labels via `gh label list`
- Compares against expected taxonomy from config:
  - Priority: `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
  - Meta: `meta:ignore`, `meta:mustread`
  - Size: `size:xs`, `size:s`, `size:m`, `size:l`, `size:xl`
  - Status: `status:ready`, `status:in-progress`, `status:in-review`, `status:blocked`, `status:done`
  - Type (only if Issue Types unavailable): `type:story`, `type:task`, `type:bug`
  - Backlog: `backlog:now`, `backlog:next`, `backlog:later`, `backlog:icebox`
  - Epic labels (from existing milestones/config)
  - Custom labels from `limbic.yaml`
- Reports each missing label individually with the exact `gh label create` command in the `fix` field

### check-wiki.sh

- Wiki repo cloneable (shallow clone test)
- `Home.md` exists
- `_Meta-Template.md` and `_PRD-Template.md` templates exist — reported as `warn` (not `fail`) since these are created by `structure` on first epic and may not exist yet

---

## Hook Mechanism

### PreToolUse Hook

Claude Code's `PreToolUse` hook fires before any tool executes. It can return `allow`, `deny`, or `ask`. When it returns `deny`, it provides a `permissionDecisionReason` that Claude receives as feedback. When it returns `allow`, it can inject `additionalContext`.

**Trigger:** `PreToolUse` event with tool name matcher `Skill`.

**Behavior:**
1. `hooks/preflight.sh` receives the tool input as JSON on stdin (includes the skill name argument)
2. Parses the skill name from the input
3. Skips (returns `allow` with no context) if skill is `init` or `status`
4. For gated skills (`structure`, `dispatch`, `review`, `integrate`): delegates to `scripts/preflight-checks/runner.sh`
5. All checks pass → returns `allow` with JSONL report as `additionalContext` (so downstream skills can read capability detection results)
6. Any check fails → returns `deny` with `permissionDecisionReason` containing the JSONL report so the model can read failures and remediate

**hooks.json** (matches existing Claude Code plugin hooks schema):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "async": false
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Skill",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/preflight.sh",
            "async": false
          }
        ]
      }
    ]
  }
}
```

The `preflight.sh` wrapper receives the `Skill` tool's input JSON on stdin, extracts the skill name, and decides whether to gate or pass through.

### Session-Start Hook (Updated)

Replaces the current full `using-limbic` skill injection with a slim routing table:

```
<LIMBIC_PLUGIN>
You have project management capabilities via the limbic plugin.

## Skill Routing

| User Intent | Skill |
|---|---|
| First-time setup / "init" / fix drift | limbic:init |
| New feature / project / "plan this" | superpowers:brainstorming → limbic:structure |
| "Break this down" / has a PRD | limbic:structure |
| "Start working" / "Dispatch" | limbic:dispatch |
| "What's the status?" | limbic:status |
| "Review PRs" / "Check feedback" | limbic:review |
| "Merge" / "Ship it" / "Integrate" | limbic:integrate |

## Flow

init → brainstorming → structure → dispatch → status → review → integrate

## Preflight

A hook runs preflight checks before structure, dispatch, review, and integrate.
If checks fail, read the JSONL report and remediate before proceeding.
</LIMBIC_PLUGIN>
```

---

## `limbic:init` Skill

### Flow: No Config Exists

1. Detect owner/repo from git remote
2. Present recommended defaults section by section:
   - Project identity (owner, repo, base branch)
   - Agent settings (max parallel, model)
   - Sizing buckets
   - Wiki settings
   - Labels (show full default taxonomy including backlog labels, ask about custom labels)
   - Approval gates
3. For each section: show the default, ask "looks good or want to change anything?"
4. Write `.github/limbic.yaml`
5. Run preflight → report results → remediate

### Flow: Config Exists

1. Run preflight silently
2. All green → "Everything's in sync."
3. Drift found → present drift report, offer two paths:
   - "Fix drift" → model remediates to match config
   - "Edit config" → reopen wizard for relevant sections
4. After changes → re-run preflight to confirm convergence

### Remediation (Model-Driven)

The model reads the `fix` field from each failed check and decides:
- **Can execute directly:** `gh label create ...`, wiki page creation, config file generation
- **Needs human action:** "You need to enable wiki in repo Settings" — waits for confirmation, then re-checks

---

## Changes to Existing Components

### Deleted

- `skills/using-limbic/` — entire directory removed

### Modified: `skills/structure/SKILL.md`

- Remove prerequisite checking (was duplicating using-limbic's checks)
- Remove capability detection logic — read from preflight JSONL in context
- Replace Step 7 (full taxonomy creation) with per-epic label creation only (`epic:{name}`) — taxonomy labels (priority, meta, size, status, backlog, type) already exist from `init`
- Renumber Steps 8-15 → Steps 7-14 accordingly
- Update checklist item 4 to reflect: "Create epic label and milestone" (not full taxonomy)
- Keep: PRD parsing, wiki pages, milestone, stories, tasks, dependency annotation, validation

### Modified: `templates/limbic.yaml`

- Remove `merge` section entirely

### Modified: `skills/review/SKILL.md` and `skills/integrate/SKILL.md`

- Remove references to `merge.task_strategy`, `merge.feature_strategy`, and `merge.delete_branch` from config
- Hardcode merge behavior: rebase for task PRs (wave 1), squash for feature PRs (wave 2), delete branch after merge

### Modified: `hooks/hooks.json`

- Add PreToolUse hook entry for preflight

### Modified: `hooks/session-start.sh`

- Replace full `using-limbic` skill content injection with slim routing table

---

## Changes to Documentation

### Modified: `CLAUDE.md`

- Update Plugin Structure tree: add `scripts/preflight-checks/`, `skills/init/`, remove `skills/using-limbic/`
- Update Skill Flow: add `init` as entry point
- Update Skill Reference table: add `limbic:init`, remove `limbic:using-limbic`
- Update Key Conventions label taxonomy: add `backlog:` and `type:` prefixes
- Update Prerequisites: reference `limbic:init` as the setup mechanism

---

## Consuming Preflight Results in Skills

All limbic skills that run behind the PreToolUse gate receive the preflight JSONL as `additionalContext`. Skills should parse capability flags from this context:

- **Issue Types available:** look for `check: "repo.issue_types"` with `status: "pass"`
- **Sub-issues API available:** look for `check: "repo.sub_issues"` with `status: "pass"`
- **Wiki available:** look for `check: "repo.wiki"` with `status: "pass"`

Skills that are NOT gated (`init`, `status`) should not depend on preflight context being present. If `status` needs capability info, it runs `scripts/preflight-checks/runner.sh --check repo` directly.

---

## Runner Exit Codes

- **Exit 0:** All checks pass (may include warnings)
- **Exit 1:** At least one check failed

The PreToolUse hook uses exit 0 → `allow` (with JSONL as additionalContext), exit 1 → `deny` (with JSONL as permissionDecisionReason). Warnings do not block.

---

## What Is NOT In Scope

- New configuration knobs beyond what `limbic.yaml` already defines (minus merge)
- Any changes to the `agents/implementer.md` agent
