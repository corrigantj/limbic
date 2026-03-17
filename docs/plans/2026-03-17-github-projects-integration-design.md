# GitHub Projects Integration — Design Spec

**Date:** 2026-03-17
**Status:** Draft
**Epic:** limbic plugin enhancement

## Problem

limbic creates issues via `limbic:structure` and manages their lifecycle through labels and milestones, but there is no visual project board. Issues have nowhere to live as a kanban. Both the developer and stakeholders lack a shared, visual dashboard of work status outside the CLI.

## Goals

1. Give developers a visual kanban board that reflects issue status in real time
2. Give stakeholders a shareable URL to track feature progress without Claude Code
3. Integrate with the existing `status:` label workflow — no new state machines
4. Keep the blast radius small — most skills should not need board API calls

## Non-Goals

- Replacing the CLI `/status` dashboard — the board complements it
- Programmatic view creation — GitHub's API does not expose view CRUD mutations
- Programmatic workflow automation setup — GitHub's API does not expose workflow CRUD mutations
- Per-epic boards or per-epic views — one board per repo, no view management

## Design Decisions

### One board per repo

A single GitHub Project board is created per repository, shared across all epics. This avoids board sprawl and gives stakeholders a single URL to bookmark. Filtering by epic label or milestone provides per-epic focus within the board.

### Four columns

| Column | Trigger | Managed by |
|--------|---------|------------|
| Ready | "Item added to project" workflow automation | GitHub automation (setup guides user to configure) |
| In Progress | `status:in-progress` label added | `limbic:dispatch` sets via API |
| In Review | `status:in-review` label added | `implementer` agent sets via API |
| Done | Issue closed | GitHub automation (setup guides user to configure) |

No Backlog column. Limbic's dispatch handles prioritization and batching.

Blocked issues remain in their current column with the `status:blocked` label as a visual indicator — no separate Blocked column.

### Label-driven automation with two explicit API calls

GitHub's built-in project workflow automations handle the bookends:
- Item added → Ready
- Item closed → Done
- Item reopened → Ready

The two intermediate transitions (Ready → In Progress, In Progress → In Review) require explicit `gh project item-edit` calls because GitHub workflows cannot trigger on label changes. This is a small cost (two API calls total across dispatch and implementer) for a four-column kanban.

### Board name defaults to repo name

The setup wizard recommends the repo name as the board title but asks the user to confirm or customize.

## Configuration Changes

New fields in `.github/limbic.yaml` under the existing `project` key:

```yaml
project:
  owner: ""        # existing — auto-detected from git remote
  repo: ""         # existing — auto-detected from git remote
  base_branch: ""  # existing — auto-detected from git remote
  board_number:    # NEW — GitHub Project number, populated by setup
  board_title: ""  # NEW — GitHub Project title, populated by setup
```

`board_number` is the primary key used by all skills to interact with the board. `board_title` is stored for display purposes (milestone descriptions, wiki meta page links).

## Preflight Changes

New script: `scripts/preflight-checks/check-project.sh`

Two checks:

1. **`project.exists`** — if `board_number` is present in config, verify the board exists and is linked to the repo via `gh project view`. If the board is missing or not linked, emit fail with fix suggestion to run `limbic:setup`.

2. **`project.status_field`** — verify the board has a "Status" field with the expected single-select options: Ready, In Progress, In Review, Done. If options are missing or renamed, emit warn. This catches configuration drift.

Preflight does **not** check workflow automation state — there is no API for reading workflow configuration. The setup wizard guidance is best-effort.

## Setup Wizard Changes

New wizard section, slotted as **Section 2** (after Project Identity, before Sizing Buckets):

**Section 2: Project Board**

1. Ask the user for a board name. Default recommendation: repo name.
2. Check if a board with that title already exists: `gh project list --owner {owner} --format json`
3. If exists: "Found existing board '{title}' (#{number}). Use this one?" — if yes, store and skip creation.
4. If not exists:
   - Create: `gh project create --owner {owner} --title "{title}" --format json`
   - Link to repo: GraphQL `linkProjectV2ToRepository` mutation
   - Store `board_number` and `board_title` in config
5. Present workflow automation guide:
   > "Now configure the board's automation. Open this URL:"
   > `https://github.com/users/{owner}/projects/{number}/settings/workflows`
   >
   > Enable these workflows:
   > 1. **Item added to project** → Set status to "Ready"
   > 2. **Item closed** → Set status to "Done"
   > 3. **Item reopened** → Set status to "Ready"
   >
   > Also set the default view to Board layout grouped by Status.
   >
   > Let me know when you've done this.
6. Wait for user confirmation before proceeding.

**Updated wizard section order:**
1. Project identity
2. Project board *(new)*
3. Sizing buckets
4. Wiki settings
5. Labels
6. Approval gates

Config file is written using the Write tool directly (no `mkdir` — Write creates parent directories automatically).

## Skill Changes

### `limbic:structure`

After creating all issues (stories + tasks) and assigning to the milestone:

- Read `board_number` and `owner` from config
- For each created issue: `gh project item-add {board_number} --owner {owner} --url {issue_url}`
- The "Item added to project" workflow automatically sets Status to Ready
- Add the board URL to:
  - Milestone description (alongside PRD link and feature branch name)
  - Wiki meta page (alongside existing links)

No conditional board checks — if structure is executing, preflight already passed and validated the board.

### `limbic:dispatch`

After labeling each dispatched issue `status:in-progress`:

- Query the board for the issue's project item ID
- Set the Status field to "In Progress": `gh project item-edit --id {item_id} --field-id {status_field_id} --project-id {project_id} --single-select-option-id {in_progress_option_id}`

### `implementer` agent

After creating the PR and updating labels to `status:in-review` (Phase 8):

- Query the board for the issue's project item ID
- Set the Status field to "In Review": `gh project item-edit --id {item_id} --field-id {status_field_id} --project-id {project_id} --single-select-option-id {in_review_option_id}`

The implementer already reads `limbic.yaml` during its context-loading phase, so `board_number` and `owner` are available.

### `limbic:review`

No board changes. Issue closure triggers the "Item closed → Done" workflow automation automatically.

### `limbic:status`

Include the board URL in the dashboard output:
```
**Project Board:** https://github.com/users/{owner}/projects/{number}
```

### `limbic:integrate`

No board changes. Completed issues stay in the Done column. The board persists across epics.

## Manual Steps (One-Time During Setup)

These cannot be automated via API:

1. **Workflow automations** — three rules configured in project Settings > Workflows
2. **Default view layout** — set to Board, grouped by Status field

The setup wizard provides the exact URL and step-by-step instructions. These only need to be done once per board.

## File Changes Summary

| File | Change |
|------|--------|
| `skills/setup/SKILL.md` | New Section 2 (Project Board) in wizard |
| `skills/structure/SKILL.md` | Add issues to board, add board URL to milestone + wiki |
| `skills/dispatch/SKILL.md` | Set board Status to "In Progress" |
| `agents/implementer.md` | Set board Status to "In Review" |
| `skills/status/SKILL.md` | Show board URL in dashboard |
| `templates/limbic.yaml` | Add `board_number` and `board_title` fields |
| `scripts/preflight-checks/check-project.sh` | New preflight script |
| `CLAUDE.md` | Update plugin structure and references |
| `README.md` | Update documentation |
