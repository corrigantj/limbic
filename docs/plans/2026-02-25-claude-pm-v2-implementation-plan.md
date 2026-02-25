# claude-pm v2 Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor the entire claude-pm plugin to implement the v2 design (wiki management, two-wave PR model, versioned epics, new label taxonomy, token-based sizing, ADR lifecycle, validation, pm-review skill).

**Architecture:** Evolutionary refactor — preserve proven dispatch/integrate/status DAG logic while rewriting templates, label taxonomy, and adding wiki + review capabilities. All skills are markdown files that instruct Claude; no runtime code.

**Tech Stack:** Markdown skill files, YAML config, bash hooks, GitHub CLI (`gh`), GitHub MCP server.

**Design doc:** `docs/plans/2026-02-25-claude-pm-v2-refactor-design.md` — the single source of truth for all content specifications.

---

## Task 1: Config Template & Foundation

**Files:**
- Modify: `templates/pm-config.yaml`

**Step 1: Read current config**

Read `templates/pm-config.yaml` to understand existing structure.

**Step 2: Write updated config**

Replace the entire file with the extended schema from design doc Section 1a. The new config must include ALL of the following sections:

```yaml
# Existing sections (preserved):
project:         # owner, repo, base_branch
agents:          # max_parallel, model
branches:        # prefix
worktrees:       # directory
merge:           # strategy, delete_branch
commands:        # test, lint, build

# Updated sections:
approval_gates:  # Add: before_wiki_update (new)
labels: []       # Keep as-is

# NEW sections:
wiki:            # directory (.wiki), auto_clone (true)
epics:           # naming (kebab-case)
validation:      # enabled (true), strict (false)
review:          # polling_interval (60), polling_model (haiku), require_codeowners (false)
sizing:          # metric (tokens), buckets (xs/s/m/l/xl with lower/upper/description)
```

Each sizing bucket must have `lower`, `upper`, and `description` fields. Use the exact ranges from design doc Section 1a.

Remove the `templates:` section (issue_body, pr_body overrides) — replaced by the new template files.

Add clear YAML comments for each section explaining what it does and when auto-detection applies.

**Step 3: Verify config is valid YAML**

Run: `python3 -c "import yaml; yaml.safe_load(open('templates/pm-config.yaml'))"`
Expected: No error

**Step 4: Commit**

```bash
git add templates/pm-config.yaml
git commit -m "feat(config): extend pm-config.yaml with wiki, sizing, review, validation sections"
```

---

## Task 2: Issue Templates (Story, Task, Bug)

**Files:**
- Create: `skills/pm-structure/story-template.md`
- Create: `skills/pm-structure/task-template.md`
- Create: `skills/pm-structure/bug-template.md`
- Delete: `skills/pm-structure/issue-body-template.md`

**Step 1: Create story template**

Create `skills/pm-structure/story-template.md` with the exact template from design doc Section 3b. Required sections:
- PRD link field
- Feature Wiki link field
- User Story (As/I want/So that)
- Context
- Acceptance Criteria (S1, S2, ... with Given/When/Then/Verify)
- Definition of Done (checklist)
- Agent Instructions (optional, HTML comment)
- Scenario Acceptance Tracker (table: Scenario, Status, Task/Bug, Date, Notes)

Add a header explaining this is a template used by pm-structure when creating GitHub Issues.

**Step 2: Create task template**

Create `skills/pm-structure/task-template.md` with the exact template from design doc Section 3c. Required sections:
- Parent link field
- Scenarios Addressed field
- Objective (one sentence)
- Implementation Notes
- Done When (checklist)

**Step 3: Create bug template**

Create `skills/pm-structure/bug-template.md` with the exact template from design doc Section 3d. Required sections:
- Parent link field
- Failing Scenario field
- Environment
- Observed Behavior
- Expected Behavior
- Reproduction Steps (numbered)
- Fix Guidance (optional, HTML comment)

**Step 4: Delete old template**

```bash
git rm skills/pm-structure/issue-body-template.md
```

**Step 5: Verify all three templates exist**

```bash
ls skills/pm-structure/story-template.md skills/pm-structure/task-template.md skills/pm-structure/bug-template.md
```
Expected: All three listed, no errors.

**Step 6: Commit**

```bash
git add skills/pm-structure/story-template.md skills/pm-structure/task-template.md skills/pm-structure/bug-template.md
git commit -m "feat(templates): add story/task/bug templates, remove old issue-body-template"
```

---

## Task 3: Wiki Page Templates

**Files:**
- Create: `skills/pm-structure/prd-template.md`
- Create: `skills/pm-structure/meta-template.md`

**Step 1: Create PRD wiki template**

Create `skills/pm-structure/prd-template.md` with the exact template from design doc Section 2h. Must include:
- Title with `{Epic Name} v{Major}` placeholder
- **Status:** field (default: Draft)
- Table of Contents
- Background (mandatory)
- Objectives
- Target Users
- Scope Matrix (table)
- Functional Requirements (mandatory)
- Non-Functional Requirements
- Dependencies & Risks
- Open Questions
- Changelog (table with version/date/changes)
- Traceability (mandatory — meta page, milestone, product tickets links)

Add a header comment explaining this is a template for GitHub Wiki PRD pages and listing the PRD lifecycle statuses (Draft → In Review → Active → Approved → Superseded).

**Step 2: Create Meta wiki template**

Create `skills/pm-structure/meta-template.md` with the exact template from design doc Section 2g. Must include:
- Title with `{Epic Name}` placeholder
- What This Feature Does Today (narrative)
- Architecture Summary (table: Service/Provider, Key Patterns, Data Models, Key Files, API Endpoints, Config)
- Scope Matrix (table: Capability, Status)
- Version History (table: Version, Milestone, PRD, Status, Date)
- Key Decisions Log (table: Decision, Rationale, ADR, Date)
- Dependencies on Other Epics (table)
- Known Limitations & Tech Debt (list)

Add a header comment explaining this is the canonical feature state page, updated once per shipped version (~10 min).

**Step 3: Verify templates exist**

```bash
ls skills/pm-structure/prd-template.md skills/pm-structure/meta-template.md
```

**Step 4: Commit**

```bash
git add skills/pm-structure/prd-template.md skills/pm-structure/meta-template.md
git commit -m "feat(templates): add PRD and meta wiki page templates"
```

---

## Task 4: Retro Template & Gherkin/PR Updates

**Files:**
- Create: `skills/pm-integrate/retro-template.md`
- Modify: `skills/pm-structure/gherkin-guide.md`
- Modify: `skills/pm-structure/pr-body-template.md`

**Step 1: Create retro template**

Create `skills/pm-integrate/retro-template.md`. This is the wiki retrospective page template used by pm-integrate after milestone completion. Must include:
- Title: `Retro: {Epic Name} v{Major}.{Minor}`
- Milestone Summary (dates, stories completed, tasks completed, bugs filed)
- Lessons Learned (aggregated from micro-retros on task PRs)
- Token Calibration (table: Task, Estimated Size, Actual Tokens, Delta %)
- Calibration Recommendations (proposed bucket adjustments)
- Process Notes (what went well, what needs improvement)
- Action Items (list)

**Step 2: Update gherkin guide**

Modify `skills/pm-structure/gherkin-guide.md`:
- Change size references from `/` to `:` delimiter (`size/xs` → `size:xs`)
- Update size guidance descriptions from time-based to token-based:
  - `size:xs` → "~1-10K tokens, 1-2 scenarios"
  - `size:s` → "~10-50K tokens, 2-3 scenarios"
  - `size:m` → "~50-200K tokens, 3-5 scenarios"
  - `size:l` → "~200-500K tokens, 5-8 scenarios (consider splitting)"
  - `size:xl` → "500K+ tokens, 8+ scenarios (must split)"

**Step 3: Update PR body template**

Modify `skills/pm-structure/pr-body-template.md`:
- Change `Closes #{issue_number}` to `Resolves #{issue_number}` (task PRs target feature branch, not main — `Closes` auto-close behavior may not apply correctly across branches)
- Add "Target branch: `{target_branch}`" field
- Add Lessons Learned section at the bottom:

```markdown
## Lessons Learned
- **Estimated size:** {size label}
- **Actual tokens:** ~{N}K
- **Surprises:** {what differed}
- **Patterns:** {reusable insights}
- **Pitfalls:** {what to avoid}
```

- Update Definition of Done checklist items to match design doc

**Step 4: Verify all files exist and are non-empty**

```bash
wc -l skills/pm-integrate/retro-template.md skills/pm-structure/gherkin-guide.md skills/pm-structure/pr-body-template.md
```

**Step 5: Commit**

```bash
git add skills/pm-integrate/retro-template.md skills/pm-structure/gherkin-guide.md skills/pm-structure/pr-body-template.md
git commit -m "feat(templates): add retro template, update gherkin guide and PR template for v2"
```

---

## Task 5: using-pm Skill Rewrite

**Files:**
- Modify: `skills/using-pm/SKILL.md`

**Step 1: Read current file**

Read `skills/using-pm/SKILL.md`.

**Step 2: Rewrite the skill**

Replace with updated gateway router per design doc Section 4a. Key changes:

1. **YAML frontmatter** — update description to mention brainstorming entry point and 6 skills (not 4)

2. **Prerequisites** — add:
   - Wiki access: `gh api repos/{owner}/{repo} --jq '.has_wiki'` should return `true`
   - Wiki repo cloneable (new check)

3. **Capability Detection** — new section. On first invocation:
   - Check Issue Types availability (org repo check)
   - Check Sub-issues API availability
   - Check Wiki enabled
   - Cache results for session

4. **Skill Table** — update to 6 skills in correct order:
   | Intent | Skill | When |
   |--------|-------|------|
   | New feature/project | `superpowers:brainstorming` | Always start here for new work |
   | Break down a PRD | `claude-pm:pm-structure` | Convert PRD → Wiki + Milestone + Issues |
   | Start implementing | `claude-pm:pm-dispatch` | Spawn agents in worktrees |
   | Check progress | `claude-pm:pm-status` | Dashboard (anytime, crash recovery) |
   | Review PRs | `claude-pm:pm-review` | Poll task PRs, merge into feature branch |
   | Ship it / merge | `claude-pm:pm-integrate` | Feature→main PR, retro, close milestone |

5. **The Flow** — update to v2 flow:
   ```
   brainstorming → PRD → pm:structure → Wiki + Milestone + Issues + feature branch
   → pm:dispatch → agents branch off feature branch
   → pm:status (anytime)
   → pm:review → task PRs merge into feature branch
   → pm:integrate → feature branch → main, retro, close
   ```

6. **Configuration** — mention new config sections (wiki, sizing, review, validation)

7. **Self-referencing** — use `claude-pm:pm-{skill}` everywhere (not `pm:{skill}`)

8. **Recovery** — unchanged

**Step 3: Verify no broken references**

Check that all skill names referenced match actual skill directory names:
```bash
ls skills/*/SKILL.md
```
Expected: using-pm, pm-structure, pm-dispatch, pm-status, pm-review (will exist after Task 9), pm-integrate

**Step 4: Commit**

```bash
git add skills/using-pm/SKILL.md
git commit -m "feat(using-pm): rewrite gateway with brainstorming entry, 6-skill routing, capability detection"
```

---

## Task 6: pm-structure Skill Rewrite

**Files:**
- Modify: `skills/pm-structure/SKILL.md`

This is the largest change. The skill goes from 7 steps to 15 steps.

**Step 1: Read current file**

Read `skills/pm-structure/SKILL.md`.

**Step 2: Rewrite the skill**

Replace with complete rewrite per design doc Section 4b. The 15 steps:

1. **Parse PRD** — extract epic name, version, stories, dependencies (similar to current Step 1, but also extract major/minor version if present)

2. **Read config** — same as current + wiki settings, sizing buckets, validation settings

3. **Convert naming** — NEW step. PRD title → lower-kebab-case. Examples:
   - "Auth With Google" → `auth-with-google`
   - "Calendar v2" → `calendar`
   - Generate milestone name: `{epic}-v{Major}.{Minor}`
   - Generate feature branch: `feature/{epic}-v{Major}`
   - Generate epic label: `epic:{epic}`

4. **Validate inputs** — NEW step (pre-creation). Before creating anything:
   - Verify PRD has required sections (Background, Functional Requirements, Traceability)
   - Verify each story has acceptance criteria
   - Verify milestone name doesn't already exist (or handle reuse)
   - If `validation.enabled` is true, loop until all checks pass

5. **Create/update wiki** — NEW step. Clone wiki repo if needed (`wiki.auto_clone`), pull latest. Create:
   - Home.md (if first epic — landing page linking to all meta pages)
   - Meta page `{Epic-Name}.md` (if first version of this epic — use meta-template.md)
   - PRD page `PRD-{epic}-v{Major}.md` (use prd-template.md, Status: Draft)
   - `_Meta-Template.md` and `_PRD-Template.md` (if they don't exist)
   - Commit and push wiki changes (respect `approval_gates.before_wiki_update`)

6. **Create epic label** — `epic:{name}` with blue color, if it doesn't exist

7. **Create label taxonomy** — NEW delimiter (`:` not `/`). Full taxonomy from design doc Section 1b:
   - `priority:critical/high/medium/low`
   - `agent:ready/blocked/review`
   - `meta:ignore/mustread`
   - `size:xs/s/m/l/xl` (descriptions from sizing config)
   - `status:ready/in-progress/in-review/blocked/done`
   - `type:story/task/bug` (only if Issue Types unavailable — check capability detection)
   - `backlog:now/next/later/icebox` (optional)
   - Use `gh label create --force` (--force updates existing)

8. **Create milestone** — with PRD link AND feature branch name in description:
   ```
   PRD: [PRD-{epic}-v{X}](../../wiki/PRD-{epic}-v{X})
   Feature branch: feature/{epic}-v{Major}
   ```

9. **Create feature branch** — NEW step:
   ```bash
   git checkout -b feature/{epic}-v{Major} {base_branch}
   git push -u origin feature/{epic}-v{Major}
   ```

10. **Create stories** — using story-template.md. Each story gets:
    - Labels: `epic:{name}`, `priority:{level}`, `size:{bucket}`, `status:ready` or `status:blocked`
    - Issue Type: story (if available) or `type:story` label
    - Milestone assignment
    - Size estimated from sizing config buckets

11. **Create dev tasks** — as sub-issues (if available) or linked issues with `<!-- pm:parent #NN -->` fallback. Use task-template.md. Each task gets:
    - Labels: `epic:{name}`, `size:{bucket}`, `status:ready` or `status:blocked`
    - Issue Type: task (if available) or `type:task` label
    - Milestone assignment

12. **Annotate dependencies** — `<!-- pm:blocked-by #N, #M -->` between stories (same as current). Label dependent stories `status:blocked`.

13. **Post-creation validation** — NEW step. Verify each created artifact has required fields:
    - Stories: PRD link, wiki link, at least one scenario, DoD
    - Tasks: parent link, scenarios addressed, objective, done when
    - Milestone: PRD link, feature branch name

14. **Update PRD status** → Active (wiki page, commit and push)

15. **Present summary** — updated format with wiki links:
    ```
    ## Structured: {epic}-v{Major}.{Minor}

    **Milestone:** #{N} — {title}
    **Feature branch:** feature/{epic}-v{Major}
    **Wiki PRD:** [link]
    **Wiki Meta:** [link]
    **Issues:** {story_count} stories, {task_count} tasks

    ### Dependency Graph
    {visual}

    ### Ready for Dispatch
    | # | Title | Type | Size | Priority |
    ...

    ### Blocked
    | # | Title | Blocked By |
    ...

    Next: invoke `claude-pm:pm-dispatch` to start implementation.
    ```

**Important rules** — update from current:
- Every story must have BDD acceptance criteria (scenarios, not just Gherkin features)
- Size XL stories must be split
- Dependencies annotated with HTML comments + status:blocked label
- Validation must pass before creation (measure twice, cut once)
- Approved/Superseded PRDs cannot be modified — create new version instead

**Step 3: Verify the skill references correct template filenames**

Check that all referenced templates exist:
```bash
ls skills/pm-structure/story-template.md skills/pm-structure/task-template.md skills/pm-structure/bug-template.md skills/pm-structure/prd-template.md skills/pm-structure/meta-template.md skills/pm-structure/gherkin-guide.md skills/pm-structure/pr-body-template.md
```

**Step 4: Commit**

```bash
git add skills/pm-structure/SKILL.md
git commit -m "feat(pm-structure): rewrite for wiki PRDs, versioned epics, sub-issues, validation"
```

---

## Task 7: pm-dispatch Skill Update

**Files:**
- Modify: `skills/pm-dispatch/SKILL.md`
- Modify: `skills/pm-dispatch/implementer-prompt.md`

**Step 1: Read current files**

Read both `skills/pm-dispatch/SKILL.md` and `skills/pm-dispatch/implementer-prompt.md`.

**Step 2: Update pm-dispatch SKILL.md**

Modify per design doc Section 4c. Key changes (preserve core DAG logic):

1. **Step 1 (Read Config)** — add `wiki`, `sizing`, `review` sections to what's read. Add `approval_gates.before_wiki_update`.

2. **Step 2 (Fetch Issues)** — update label references: `status:ready` not `status/ready`. Filter out `meta:ignore` issues. Collect `meta:mustread` issues separately (they'll be injected into agent context).

3. **Step 3 (Build DAG)** — handle sub-issue hierarchy. When building the DAG:
   - Parse `<!-- pm:blocked-by -->` as before
   - Also parse `<!-- pm:parent #NN -->` to understand story→task relationships
   - Walk parent→child to include task-level dependencies

4. **Step 4 (Identify Batch)** — update label references. Add:
   - Skip `meta:ignore` and `meta:mustread` issues (not work items)
   - Token-based sizing preference: when priorities equal, prefer smaller token estimates first
   - Use `size:` not `size/` labels

5. **Step 5 (Approval Gate)** — update branch naming to show feature branch target:
   - Branch column shows `pm/{issue}-{slug}` (branching from `feature/{epic}-v{Major}`)

6. **Step 6 (Dispatch)** — key changes:
   - Branch from **feature branch** not base branch: `git checkout -b pm/{issue}-{slug} feature/{epic}-v{Major}`
   - Worktree branches from feature branch
   - Read `meta:mustread` issue bodies and include in agent prompt
   - Read wiki context (meta page, PRD page) and include relevant excerpts in agent prompt
   - Update label references to `:` delimiter
   - Fill the updated implementer-prompt.md (see Step 3 below)

7. **Step 7 (Monitor)** — update label references. After batch complete:
   - Check if next batch ready (same as current)
   - If all in-review: suggest `claude-pm:pm-review` (not `claude-pm:pm-integrate`)

**Step 3: Update implementer-prompt.md**

Modify the prompt template to reflect the two-wave model:

```markdown
You are a pm-implementer agent. Implement the following GitHub Issue.

## Issue
- **Number:** #{issue_number}
- **Title:** {issue_title}
- **Repository:** {owner}/{repo}
- **Feature Branch:** {feature_branch}

## Issue Body
{issue_body}

## Context Chain

### Feature Wiki (Meta Page)
{meta_wiki_excerpt_or_link}

### PRD
{prd_excerpt_or_link}

### Must-Read Context
{mustread_issues_content_or_none}

## Your Branch and Worktree
- **Branch name:** {branch_prefix}/{issue_number}-{slug}
- **Branch from:** {feature_branch} (NOT main)
- **PR target:** {feature_branch} (NOT main)
- **Worktree path:** {worktree_dir}/{branch_prefix}/{issue_number}-{slug}

## Build Commands
- **Test:** `{test_command}`
- **Lint:** `{lint_command}`
- **Build:** `{build_command}`

## Sizing
- **Estimated size:** {size_label}
- **Token range:** {lower}-{upper}

## PR Template
{pr_body_template}

## Instructions
1. Read the `agents/pm-implementer.md` agent definition in the claude-pm plugin
2. Follow the 10-phase execution procedure exactly
3. Branch from and PR back to the FEATURE BRANCH, not main
4. Use TDD — write failing tests first for each scenario
5. Report progress via GitHub Issue comments
6. Record token calibration in your lessons-learned comment
7. Return a structured YAML result when done

Begin.
```

**Step 4: Verify consistent label references**

Search for any remaining `/` delimiter labels in both files:
```bash
grep -n "status/" skills/pm-dispatch/SKILL.md skills/pm-dispatch/implementer-prompt.md
grep -n "type/" skills/pm-dispatch/SKILL.md skills/pm-dispatch/implementer-prompt.md
grep -n "size/" skills/pm-dispatch/SKILL.md skills/pm-dispatch/implementer-prompt.md
grep -n "priority/" skills/pm-dispatch/SKILL.md skills/pm-dispatch/implementer-prompt.md
```
Expected: No matches (all should use `:` delimiter now)

**Step 5: Commit**

```bash
git add skills/pm-dispatch/SKILL.md skills/pm-dispatch/implementer-prompt.md
git commit -m "feat(pm-dispatch): update for feature branch, mustread injection, new label taxonomy"
```

---

## Task 8: pm-status Skill Update

**Files:**
- Modify: `skills/pm-status/SKILL.md`

**Step 1: Read current file**

Read `skills/pm-status/SKILL.md`.

**Step 2: Update the skill**

Modify per design doc Section 4d. Preserve core dashboard logic. Key changes:

1. **Step 1 (Fetch Issues)** — also fetch sub-issues for each story. Parse `<!-- pm:parent #NN -->` to build parent→child relationships.

2. **Step 2 (Categorize)** — update all label references to `:` delimiter. Same status buckets but with new labels:
   - `status:done`, `status:in-review`, `status:in-progress`, `status:blocked`, `status:ready`
   - Handle `meta:ignore` (skip from display) and `meta:mustread` (show in separate "Context" section)

3. **Step 3 (Fetch PR Status)** — check PRs targeting the **feature branch** (not base branch). Branch pattern is still `pm/{issue_number}-*`.

4. **Step 4 (Present Dashboard)** — updated format:
   - Group by story with nested tasks/bugs underneath:
     ```
     ### Story #10: Swipe to create event [size:m] [status:in-review]
       - Task #10.1: Implement gesture handler [status:done]
       - Task #10.2: Wire Next button [status:in-review]
       - Bug  #10.4: Next button nav broken [status:ready]
       Scenarios: S1 ✅ | S2 🐛 (#10.4) | S2a ✅
     ```
   - Add wiki links section:
     ```
     ### Wiki Links
     - **Meta page:** [Epic Name](wiki link)
     - **PRD:** [PRD-epic-v1](wiki link)
     ```
   - Add lessons count per story
   - Update recommended next actions:
     - If task PRs need review: suggest `claude-pm:pm-review`
     - If all tasks merged to feature branch: suggest `claude-pm:pm-integrate`

5. **Recovery** — unchanged (still reads all state from GitHub)

**Step 3: Verify no old label references remain**

```bash
grep -n "status/" skills/pm-status/SKILL.md
grep -n "type/" skills/pm-status/SKILL.md
```
Expected: No matches

**Step 4: Commit**

```bash
git add skills/pm-status/SKILL.md
git commit -m "feat(pm-status): update for sub-issue grouping, new labels, wiki links"
```

---

## Task 9: pm-review Skill (NEW)

**Files:**
- Create: `skills/pm-review/SKILL.md`

**Step 1: Create the skill directory**

```bash
mkdir -p skills/pm-review
```

**Step 2: Write the pm-review skill**

Create `skills/pm-review/SKILL.md` per design doc Section 4e. This is an entirely new skill.

```markdown
---
name: pm-review
description: Use after pm-dispatch agents create PRs — polls for human review activity on task PRs targeting the feature branch, addresses feedback, merges approved PRs, captures micro-retros
---
```

**Type:** Rigid. Follow this process exactly.

**Inputs:**
- A feature branch with open task PRs
- Access to the project repository (GitHub MCP + gh CLI)

**Process — 7 steps:**

1. **Identify open task PRs** — Find all open PRs targeting the feature branch (`feature/{epic}-v{Major}`). For each, collect: PR number, issue number, CI status, review state.

2. **Spawn polling sub-agent** — Use Task tool to spawn a haiku-model agent that:
   - Polls `gh api repos/{owner}/{repo}/pulls/{pr}/reviews` at `review.polling_interval` seconds
   - Also polls `gh api repos/{owner}/{repo}/pulls/{pr}/comments` for inline comments
   - When new review activity detected, returns the review data (comments, status, requested changes)
   - Agent is minimal — only detects changes, does not reason about code

3. **On activity detected** — Main agent receives review data:
   - Parse inline comments and review comments
   - If "approved" — proceed to step 5
   - If "changes requested" — proceed to step 4
   - If comments only (no formal review) — address comments, push, resume polling

4. **Address feedback** — For each requested change:
   - Read the comment/review
   - Make code changes in the task's worktree
   - Run tests to verify fix
   - Commit with message referencing the review comment
   - Push updated commits
   - Post reply on the PR addressing each comment
   - Resume polling (back to step 2)

5. **On approval — merge task PR** —
   - Check PR is up-to-date with feature branch (rebase if behind)
   - Merge using rebase strategy (task PRs always rebase into feature branch)
   - Delete task branch if `merge.delete_branch` is true
   - If `review.require_codeowners` is true, verify a CODEOWNERS match approved

6. **Capture micro-retro** — After merge, post a lessons-learned comment on the task PR:
   ```markdown
   ## Micro-Retro: #{issue_number}
   - **Estimated size:** {size label from issue}
   - **Actual tokens:** ~{N}K
   - **What went well:** {summary}
   - **What went wrong:** {summary}
   - **Surprises:** {unexpected challenges}
   - **Patterns discovered:** {reusable insights}
   ```
   Also update the parent story's Scenario Acceptance Tracker if task scenarios are now passing.

7. **Check for next batch** — After merging:
   - Check if new tasks are unblocked (dependencies resolved)
   - If yes, suggest `claude-pm:pm-dispatch` for next batch
   - If all task PRs merged, suggest `claude-pm:pm-integrate`
   - Present summary:
     ```
     ## Review Cycle Complete

     | PR | Issue | Status | Merged |
     |----|-------|--------|--------|
     | #{pr} | #{issue}: {title} | Approved | Yes |

     Micro-retros captured: {count}
     Tasks still open: {count}
     Next: {recommendation}
     ```

**Important rules:**
1. Never merge without approval (or CODEOWNERS approval if required)
2. Always rebase task PRs onto feature branch before merging
3. Run tests after addressing feedback before pushing
4. Capture micro-retro on every merged PR — no exceptions
5. The polling sub-agent uses the cheapest model (`review.polling_model`, default haiku)
6. If polling detects the PR was closed/rejected, report to user and stop

**Step 3: Verify skill file exists and has YAML frontmatter**

```bash
head -5 skills/pm-review/SKILL.md
```
Expected: YAML frontmatter with name and description

**Step 4: Commit**

```bash
git add skills/pm-review/SKILL.md
git commit -m "feat(pm-review): add new skill for task PR review polling and micro-retros"
```

---

## Task 10: pm-integrate Skill Update

**Files:**
- Modify: `skills/pm-integrate/SKILL.md`

**Step 1: Read current file**

Read `skills/pm-integrate/SKILL.md`.

**Step 2: Update the skill**

Modify per design doc Section 4f. Preserve core merge logic but restructure for the two-wave model. The skill now handles wave 2 (feature→main) plus finalization.

Key changes to existing steps:

1. **Step 1 (Pre-Integration Audit)** — verify all **task PRs** are merged into feature branch (not into main). Check scenario acceptance trackers on all stories. If any tasks still open, report and offer options.

2. **Step 2 (Build Merge Order)** — SIMPLIFIED. In the two-wave model, there's typically **one feature PR** to merge (feature→main). If multiple feature branches are ready (multiple epics), use dependency ordering between them. Remove the per-issue topological sort (that's now handled by pm-review merging task PRs into the feature branch).

3. **Step 3 (Approval Gate)** — present the feature→main merge plan. Show aggregate of all changes.

4. **Step 4 (Create Feature PR)** — NEW substep. Create PR from `feature/{epic}-v{Major}` → base branch. Include:
   - Title: `{Epic Name} v{Major}.{Minor}`
   - Body: summary of all stories/tasks completed, link to milestone, link to PRD

5. **Step 5 (Poll for review)** — NEW substep. Same polling mechanism as pm-review but for the feature→main PR. Spawn haiku polling sub-agent, address feedback, push fixes.

6. **Step 6 (On approval — merge)** — merge using configured strategy (squash/merge/rebase from config). Run post-merge test verification on base branch.

7. **Step 7 (Ask user)** — NEW step. Ask whether to close milestone or keep feature branch open:
   - If close: proceed to finalization (steps 8-13)
   - If keep open: stop here, user invokes pm-dispatch for next minor version

8. **Step 8 (Collect micro-retros)** — NEW. Gather all micro-retro comments from task PRs in the milestone.

9. **Step 9 (Create retro wiki page)** — NEW. Use retro-template.md. Clone/pull wiki repo, create `Retro-{epic}-v{X}.{Y}.md`, commit and push.

10. **Step 10 (Update meta wiki page)** — NEW. Update the meta page:
    - "What This Feature Does Today" → describe shipped state
    - Scope Matrix → reflect new reality
    - Version History → mark this version as shipped
    - Key Decisions → add any ADRs created during this version

11. **Step 11 (Update PRD status)** — Set to Approved. Commit and push wiki.

12. **Step 12 (Create sizing calibration PR)** — NEW. Tabulate estimated vs actual tokens from all task micro-retros. Generate recommended bucket adjustments. Create PR modifying `sizing` section of `.github/pm-config.yaml`.

13. **Step 13 (Close milestone)** — same as current Step 5.

14. **Step 14 (Final report)** — updated to include wiki links, retro link, calibration PR link.

Update **Conflict Resolution** section:
- Conflicts now happen at the feature→main level, not per-task
- Same strategies apply (additive auto-resolve, overlapping present to user, semantic revert)

Update **Important Rules**:
- Add: "Always create retro wiki page before closing milestone"
- Add: "Always update meta wiki page after merge"
- Add: "Always create sizing calibration PR"
- Update label references to `:` delimiter

**Step 3: Verify no old label references**

```bash
grep -n "status/" skills/pm-integrate/SKILL.md
grep -n "type/" skills/pm-integrate/SKILL.md
```
Expected: No matches

**Step 4: Commit**

```bash
git add skills/pm-integrate/SKILL.md
git commit -m "feat(pm-integrate): update for feature→main PR, retro, wiki update, calibration"
```

---

## Task 11: pm-implementer Agent Rewrite

**Files:**
- Modify: `agents/pm-implementer.md`

**Step 1: Read current file**

Read `agents/pm-implementer.md`.

**Step 2: Rewrite the agent**

Modify per design doc Section 4g. Preserve core identity and TDD mandate. Key changes:

1. **Inputs You Receive** — update to include:
   - Feature branch name (branch FROM this, PR TO this)
   - Wiki context (meta page excerpt, PRD excerpt)
   - Must-read context (meta:mustread issue bodies)
   - Sizing info (estimated size label, token range)

2. **Core Rules** — update:
   - Rule 1: Branch from **feature branch**, not base branch
   - Rule 2: TDD (unchanged)
   - Rule 3: Report via GitHub (unchanged)
   - Rule 4: Never guess (unchanged)
   - Rule 5: Stay in lane (unchanged)
   - Rule 6 (NEW): **Read context chain** — before implementing, read meta wiki → PRD → mustread issues → story → task

3. **Execution Procedure** — 10 phases (from 8):
   - Phase 1 (Setup): Create worktree branching from **feature branch**
   - Phase 2 (Context): Read full context chain — meta wiki, PRD, mustread issues, story, task
   - Phase 3 (Understand): Parse issue body, read affected files, block if unclear
   - Phase 4 (Plan): Map scenarios to tests, identify files
   - Phase 5 (Implement - TDD): RED → GREEN → REFACTOR per scenario
   - Phase 6 (Verify): Full test suite, lint, build
   - Phase 7 (Create PR): Push, create PR **targeting feature branch**
   - Phase 8 (Update Issue): Labels → `status:in-review`
   - Phase 9 (Scenario Tracker): Update parent story's Scenario Acceptance Tracker
   - Phase 10 (Report): Return structured YAML result

4. **Structured YAML result** — add fields:
   ```yaml
   result:
     issue_number: {N}
     status: success | error | blocked
     branch: {branch_name}
     feature_branch: {feature_branch}
     pr_number: {N or null}
     tests_passing: true | false
     test_count: {N}
     files_changed: [{list}]
     commits: {N}
     estimated_size: {label}
     actual_tokens: {N}
     scenarios_addressed: [S1, S2]
     reason: ""
   ```

5. **Lessons comment** — NEW. Before returning, post a lessons-learned comment on the issue:
   ```markdown
   ## Lessons Learned
   - **Estimated size:** {size:X} (~{lower}-{upper} tokens)
   - **Actual tokens:** ~{N}K
   - **Surprises:** {what differed}
   - **Patterns:** {reusable insights}
   - **Pitfalls:** {what to avoid}
   ```

6. **Bug filing** — If agent discovers bugs during implementation, file bug sub-issue under parent story using bug-template.md.

7. Update all label references to `:` delimiter.

**Step 3: Verify no old label references**

```bash
grep -n "status/" agents/pm-implementer.md
grep -n "type/" agents/pm-implementer.md
```
Expected: No matches

**Step 4: Commit**

```bash
git add agents/pm-implementer.md
git commit -m "feat(pm-implementer): rewrite for feature branch, context chain, lessons, calibration"
```

---

## Task 12: Meta Files (plugin.json, CLAUDE.md, README.md, hooks)

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `hooks/session-start.sh`
- Modify: `CLAUDE.md`
- Modify: `README.md`

**Step 1: Update plugin.json**

Bump version to `0.2.0`. Update description:

```json
{
  "name": "claude-pm",
  "description": "GitHub-native project management for Claude Code: wiki PRDs, versioned epics, two-wave PR model, parallel agent execution, token-based sizing calibration",
  "version": "0.2.0",
  "author": {
    "name": "Travis Corrigan",
    "email": "travis@matterflower.com"
  },
  "repository": "https://github.com/traviscorrigan/claude-pm",
  "license": "MIT",
  "keywords": ["project-management", "github-issues", "github-wiki", "parallel-agents", "worktrees", "skills", "versioned-epics"]
}
```

**Step 2: Update hooks/session-start.sh**

No structural changes needed — it already reads `skills/using-pm/SKILL.md` dynamically. The updated using-pm content will be injected automatically. Just verify it still works:

```bash
bash hooks/session-start.sh
```
Expected: Valid JSON output with `additional_context` containing the updated using-pm content.

**Step 3: Update CLAUDE.md**

Rewrite to reflect new architecture:

- **What This Is** — mention wiki PRDs, versioned epics, two-wave PR model, token-based sizing
- **Plugin Structure** — updated tree with 6 skills (add pm-review), new template files
- **Skill Flow** — updated flow diagram with brainstorming entry, feature branches, pm-review
- **Key Conventions** — update:
  1. GitHub Issues + Wiki are the durable state machine
  2. Dependencies: `<!-- pm:blocked-by -->` and `<!-- pm:parent -->`
  3. Label taxonomy: `epic:`, `priority:`, `agent:`, `meta:`, `size:`, `status:` (`:` delimiter)
  4. Two-wave PR model: task PRs → feature branch → main
  5. Config via `.github/pm-config.yaml` with sizing buckets
  6. PRD lifecycle: Draft → In Review → Active → Approved → Superseded
- **Prerequisites** — add wiki access
- **Skill Reference** — 6 skills with updated descriptions

**Step 4: Update README.md**

Rewrite to reflect new architecture:

- **How It Works** — updated 6-step flow (brainstorming → structure → dispatch → review → status → integrate)
- **Quick Start** — updated examples mentioning wiki, feature branches
- **Configuration** — show full pm-config.yaml with new sections (sizing, wiki, review, validation)
- **Architecture** — describe two-wave PR model, wiki management, versioned epics, token calibration
- **Plugin Structure** — updated tree
- **Skill Reference** — 6 skills

**Step 5: Commit**

```bash
git add .claude-plugin/plugin.json CLAUDE.md README.md
git commit -m "docs: update plugin metadata, CLAUDE.md, and README for v2 architecture"
```

---

## Task 13: Final Verification & Cleanup

**Files:**
- All files in the repository

**Step 1: Verify all expected files exist**

```bash
echo "=== Skills ==="
ls skills/using-pm/SKILL.md
ls skills/pm-structure/SKILL.md
ls skills/pm-structure/story-template.md
ls skills/pm-structure/task-template.md
ls skills/pm-structure/bug-template.md
ls skills/pm-structure/prd-template.md
ls skills/pm-structure/meta-template.md
ls skills/pm-structure/pr-body-template.md
ls skills/pm-structure/gherkin-guide.md
ls skills/pm-dispatch/SKILL.md
ls skills/pm-dispatch/implementer-prompt.md
ls skills/pm-status/SKILL.md
ls skills/pm-review/SKILL.md
ls skills/pm-integrate/SKILL.md
ls skills/pm-integrate/retro-template.md
echo "=== Agents ==="
ls agents/pm-implementer.md
echo "=== Config ==="
ls templates/pm-config.yaml
echo "=== Meta ==="
ls .claude-plugin/plugin.json
ls CLAUDE.md
ls README.md
```
Expected: All files listed, no errors.

**Step 2: Verify old template is deleted**

```bash
ls skills/pm-structure/issue-body-template.md 2>&1
```
Expected: "No such file or directory"

**Step 3: Global check for old label delimiter**

Search entire codebase for old `/` delimiter labels that should now use `:`:

```bash
grep -rn "status/" skills/ agents/ templates/ --include="*.md" --include="*.yaml" | grep -v "pm:blocked-by" | grep -v "http"
grep -rn "type/" skills/ agents/ templates/ --include="*.md" --include="*.yaml" | grep -v "subagent_type"
grep -rn "size/" skills/ agents/ templates/ --include="*.md" --include="*.yaml" | grep -v "batch size" | grep -v "Batch size"
grep -rn "priority/" skills/ agents/ templates/ --include="*.md" --include="*.yaml"
```
Expected: No matches (all should use `:` delimiter)

**Step 4: Check for any `pm:` self-references that should be `claude-pm:`**

```bash
grep -rn "pm:" skills/ agents/ --include="*.md" | grep -v "claude-pm:" | grep -v "pm:blocked-by" | grep -v "pm:parent" | grep -v "pm-config"
```
Expected: No matches — all skill references should use `claude-pm:pm-{skill}` format

**Step 5: Validate YAML config**

```bash
python3 -c "import yaml; yaml.safe_load(open('templates/pm-config.yaml')); print('Valid YAML')"
```
Expected: "Valid YAML"

**Step 6: Final commit if any cleanup was needed**

```bash
git status
# If changes: git add and commit with "chore: final v2 cleanup"
```

**Step 7: Verify git log shows clean commit history**

```bash
git log --oneline -15
```
Expected: Clean sequence of commits from Tasks 1-12.
