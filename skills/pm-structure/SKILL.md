---
name: pm-structure
description: Use when converting a PRD or design document into a GitHub Wiki PRD, Meta page, Milestone with feature branch, and dependency-ordered Stories with dev task sub-issues
---

# pm-structure -- PRD to GitHub Artifacts

**Type:** Rigid. Follow this process exactly.

## Inputs

- A PRD file (in `docs/plans/` or provided by user)
- Access to project repository (GitHub MCP + gh CLI)

## Process

### Step 1: Parse PRD

Read the PRD file. Extract:
- **Epic name** -- the high-level feature name (e.g., "Auth With Google")
- **Version** -- if present in the PRD (defaults to v1.0 if absent)
- **Stories** -- each distinct user-facing behavior becomes a product story
- **Dependencies** -- which stories depend on which
- **Shared infrastructure** -- foundation work needed before feature work

If the PRD is ambiguous, ask the user for clarification before proceeding.

### Step 2: Read Configuration

Read `.github/pm-config.yaml` from the project root. Extract:
- **Wiki settings** -- `wiki.auto_clone`, template paths
- **Sizing buckets** -- `sizing.buckets` with time ranges and descriptions
- **Validation settings** -- `validation.enabled`, required PRD sections
- **Approval gates** -- `approval_gates.before_wiki_update`, etc.

Auto-detect owner/repo from git remote if not configured:
```bash
gh repo view --json owner,name --jq '.owner.login + "/" + .name'
```

If no config file exists, show defaults and continue:
```yaml
project:
  owner: (from git remote)
  repo: (from git remote)
  base_branch: (from git default branch)
wiki:
  auto_clone: true
sizing:
  buckets:
    xs: "< 30 min"
    s: "30 min - 1 hour"
    m: "1 - 3 hours"
    l: "3 - 8 hours"
    xl: "Should be split"
validation:
  enabled: true
labels: []
```

### Step 3: Convert Naming

Convert the PRD title into lower-kebab-case and derive all artifact names:

| Artifact | Convention | Example |
|----------|-----------|---------|
| Epic name (kebab) | lower-kebab-case | `auth-with-google` |
| Milestone title | `{epic}-v{Major}.{Minor}` | `auth-with-google-v1.0` |
| Feature branch | `feature/{epic}-v{Major}` | `feature/auth-with-google-v1` |
| Epic label | `epic:{epic}` | `epic:auth-with-google` |
| PRD wiki page | `PRD-{epic}-v{Major}` | `PRD-auth-with-google-v1` |
| Meta wiki page | `{Epic-Name}` (Title-Case) | `Auth-With-Google` |

Always include the minor version in the milestone title (e.g., `v1.0` not `v1`).

### Step 4: Validate Inputs (Pre-Creation)

Before creating any GitHub artifacts, if `validation.enabled` is true:

1. **PRD sections** -- Verify the PRD has required sections: Background, Functional Requirements, Traceability
2. **Story completeness** -- Verify each extracted story has at least one acceptance scenario
3. **Milestone uniqueness** -- Verify milestone name doesn't already exist (or offer to reuse an existing one)
4. **PRD immutability** -- Verify no Approved or Superseded PRD exists for this epic version (Approved/Superseded PRDs cannot be modified -- create a new version instead)
5. **Size sanity** -- Flag any story estimated at XL (must be split before proceeding)

Loop until all checks pass. Report all failures at once so the user can fix them in batch.

### Step 5: Create/Update Wiki

Clone the wiki repo if needed (`wiki.auto_clone`). Pull latest.

Then create or update these pages:

1. **`Home.md`** -- If it doesn't exist, create a landing page that links to all meta pages and milestones
2. **Meta page `{Epic-Name}.md`** -- If this is the first version of this epic, create using `meta-template.md` from this skill directory
3. **PRD page `PRD-{epic}-v{Major}.md`** -- Create using `prd-template.md` from this skill directory. Set Status to **Draft**
4. **`_Meta-Template.md`** and **`_PRD-Template.md`** -- If they don't exist, create hidden templates (copies of `meta-template.md` and `prd-template.md`) so wiki editors can create pages manually

Commit and push wiki changes. Respect `approval_gates.before_wiki_update` -- if set, confirm with user before pushing.

### Step 6: Create Epic Label

Create `epic:{epic}` with color `0052cc` (blue) if it doesn't already exist:
```bash
gh label create "epic:{epic}" --color "0052cc" --description "Epic: {Epic Name}" --force
```

### Step 7: Create Label Taxonomy

Use `:` delimiter (NOT `/`). Create via `gh label create --force`:

**Priority labels:**
- `priority:critical` (color: `b60205`, description: "Must have -- blocks project")
- `priority:high` (color: `d93f0b`, description: "Should have -- core functionality")
- `priority:medium` (color: `fbca04`, description: "Nice to have -- enhances project")
- `priority:low` (color: `0e8a16`, description: "Could defer -- not blocking")

**Agent labels:**
- `agent:ready` (color: `7057ff`, description: "Ready for agent pickup")
- `agent:blocked` (color: `7057ff`, description: "Agent cannot proceed")
- `agent:review` (color: `7057ff`, description: "Agent work complete, needs review")

**Meta labels:**
- `meta:ignore` (color: `006b75`, description: "Exclude from PM tracking")
- `meta:mustread` (color: `006b75`, description: "Required reading for agents")

**Size labels (descriptions from `sizing.buckets` config):**
- `size:xs` (color: `bfd4f2`)
- `size:s` (color: `bfd4f2`)
- `size:m` (color: `bfd4f2`)
- `size:l` (color: `bfd4f2`)
- `size:xl` (color: `bfd4f2`)

**Status labels:**
- `status:ready` (color: `0e8a16`, description: "Ready for implementation")
- `status:in-progress` (color: `fbca04`, description: "Agent is working on this")
- `status:in-review` (color: `1d76db`, description: "PR created, awaiting review")
- `status:blocked` (color: `d73a4a`, description: "Blocked by dependency or question")
- `status:done` (color: `333333`, description: "Completed and merged")

**Type labels (ONLY if Issue Types are unavailable -- detect via capability check):**
- `type:story` (color: `cccccc`, description: "Product story")
- `type:task` (color: `cccccc`, description: "Dev task")
- `type:bug` (color: `cccccc`, description: "Bug report")

**Backlog labels (optional):**
- `backlog:now` (color: `ededed`, description: "Current sprint")
- `backlog:next` (color: `ededed`, description: "Next sprint")
- `backlog:later` (color: `ededed`, description: "Future sprint")
- `backlog:icebox` (color: `ededed`, description: "Deprioritized")

Also create any custom labels from `pm-config.yaml`.

Run label creation as a batch:
```bash
gh label create "priority:critical" --color "b60205" --description "Must have -- blocks project" --force
gh label create "priority:high" --color "d93f0b" --description "Should have -- core functionality" --force
# ... repeat for all labels
```

### Step 8: Create Milestone

Create the milestone via `gh api`:
```bash
gh api repos/{owner}/{repo}/milestones --method POST \
  -f title="{epic}-v{Major}.{Minor}" \
  -f description="PRD: [PRD-{epic}-v{X}](../../wiki/PRD-{epic}-v{X})
Feature branch: feature/{epic}-v{Major}" \
  -f state="open"
```

The milestone description **must** include:
- Link to the PRD wiki page
- Feature branch name

If a milestone with this title already exists, use it instead of creating a duplicate.

Capture the milestone number from the response for use in subsequent steps.

### Step 9: Create Feature Branch

Create and push the feature branch from the configured base branch:
```bash
git checkout -b feature/{epic}-v{Major} {base_branch}
git push -u origin feature/{epic}-v{Major}
```

If the feature branch already exists, check it out instead.

### Step 10: Create Stories

For each product story extracted from the PRD, compose the issue body using `story-template.md` from this skill directory. Fill in:

- **PRD link** -- `[PRD-{epic}-v{X}](../../wiki/PRD-{epic}-v{X})`
- **Feature wiki link** -- `[{Epic Name}](../../wiki/{Epic-Name})`
- **User story** -- As a {persona}, I want to {action} so that {benefit}
- **Context** -- Why this matters (2-3 sentences)
- **Acceptance criteria** -- BDD scenarios numbered S1, S2, etc.
- **Definition of Done** -- Standard checklist
- **Agent instructions** -- Technical guidance, key files, constraints

Apply labels:
- `epic:{name}` -- links story to the epic
- `priority:{level}` -- from PRD priority or inferred
- `size:{bucket}` -- estimated from `sizing.buckets` config ranges
- `status:ready` or `status:blocked` -- based on dependency analysis

Use Issue Type `story` if available, otherwise apply `type:story` label.

Assign to the milestone created in Step 8.

Size estimation: use the `sizing.buckets` config to determine the appropriate size label. If a story estimates at `size:xl`, it must be split into smaller stories before creation.

Create stories in dependency order:
1. **Foundation / infra stories first** -- no dependencies
2. **Feature stories next** -- may depend on infra
3. **Integration / polish stories last** -- depend on features

### Step 11: Create Dev Tasks

For each story, create dev tasks as sub-issues. Compose bodies using `task-template.md` from this skill directory. Fill in:

- **Parent link** -- `#{parent_issue_number}`
- **Scenarios addressed** -- which parent scenarios (S1, S2, etc.) this task covers
- **Objective** -- one sentence describing what this task produces
- **Implementation notes** -- file paths, function signatures, architectural decisions
- **Done when** -- concrete, verifiable checklist items

If Sub-issues API is available, create tasks as sub-issues of their parent story.

If Sub-issues API is unavailable, create as regular issues with `<!-- pm:parent #NN -->` in the body to link to the parent story.

Apply labels:
- `epic:{name}` -- links task to the epic
- `size:{bucket}` -- estimated from scope
- `status:ready` or `status:blocked` -- based on dependency analysis

Use Issue Type `task` if available, otherwise apply `type:task` label.

### Step 12: Annotate Dependencies

For each story that depends on other stories, ensure the body contains:
```html
<!-- pm:blocked-by #12, #15 -->
```

This HTML comment is invisible to human readers but machine-parseable by `claude-pm:pm-dispatch`.

Also label dependent stories as `status:blocked` (not `status:ready`).

Dependencies must be annotated both ways:
- The HTML comment in the issue body (for machine parsing)
- The `status:blocked` label (for visual scanning)

### Step 13: Post-Creation Validation

After all artifacts are created, verify each one:

**Stories must have:**
- PRD link in body
- Wiki link in body
- At least one numbered scenario (S1+)
- Definition of Done section

**Tasks must have:**
- Parent link in body
- Scenarios addressed listed
- Objective section
- Done When checklist

**Milestone must have:**
- PRD link in description
- Feature branch name in description

Report any validation failures. Fix them before proceeding.

### Step 14: Update PRD Status

Update the wiki PRD page:
- Set Status from **Draft** to **Active**
- Populate the Traceability section with issue numbers and milestone link
- Commit and push wiki changes

### Step 15: Present Summary

Output a summary for the user:

```markdown
## Structured: {epic}-v{Major}.{Minor}

**Milestone:** #{N} -- {title}
**Feature branch:** feature/{epic}-v{Major}
**Wiki PRD:** [PRD-{epic}-v{X}](../../wiki/PRD-{epic}-v{X})
**Wiki Meta:** [{Epic Name}](../../wiki/{Epic-Name})
**Issues:** {story_count} stories, {task_count} tasks

### Dependency Graph
{visual representation using indentation or ASCII}

### Ready for Dispatch
| # | Title | Type | Size | Priority |
|---|-------|------|------|----------|
| {number} | {title} | {type} | {size} | {priority} |

### Blocked
| # | Title | Blocked By |
|---|-------|-----------|
| {number} | {title} | #{deps} |

**Next:** invoke `claude-pm:pm-dispatch` to start implementation.
```

## Important Rules

1. **Never create duplicate issues** -- check existing milestone issues first
2. **Every story must have BDD acceptance criteria** -- numbered scenarios S1, S2, etc.
3. **Dependencies annotated both ways** -- HTML comment in body + `status:blocked` label
4. **Size XL issues must be split** -- create smaller stories instead
5. **Foundation/infra first** -- create in dependency order
6. **One behavior per story** -- split if covering multiple behaviors
7. **Validation must pass before creation** -- measure twice, cut once (Step 4)
8. **Approved/Superseded PRDs cannot be modified** -- create a new version instead
9. **All skill references use `claude-pm:pm-{skill}` format**
