# claude-pm

GitHub-native project management for Claude Code. Create wiki PRDs with versioned epics, structure work into GitHub Milestones with story/task sub-issue hierarchies, dispatch parallel implementation agents (each in its own git worktree branching from a feature branch), manage the PR review cycle with a two-wave model, and calibrate future estimates with token-based sizing.

## How It Works

1. **You brainstorm** a design and save it as a PRD
2. **`claude-pm:pm-structure`** creates a wiki PRD page, a meta page, a GitHub Milestone with Issues (stories, tasks, bugs), and a feature branch
3. **`claude-pm:pm-dispatch`** spawns parallel pm-implementer agents — each in its own worktree, branching from the feature branch, implementing with TDD, creating task PRs
4. **`claude-pm:pm-status`** shows a live dashboard from GitHub state (works across session crashes)
5. **`claude-pm:pm-review`** polls task PRs for review status, merges approved PRs into the feature branch, and captures lessons learned
6. **`claude-pm:pm-integrate`** merges the feature branch to main, creates a retrospective wiki page, calibrates sizing estimates, and closes the milestone

GitHub Issues + Wiki are the durable state machine — session crashes are fully recoverable.

## Prerequisites

- [superpowers](https://github.com/obra/superpowers) plugin installed (provides brainstorming, TDD, worktrees, debugging)
- GitHub MCP server configured (for issue/PR/milestone management)
- `gh` CLI authenticated (`gh auth status`)
- A repository with a GitHub remote
- **Wiki enabled** on the GitHub repository

## Installation

### Claude Code (via Plugin Marketplace)

```
/plugin marketplace add corrigantj/claude-pm
/plugin install claude-pm@claude-pm
```

To update after new releases:

```
/plugin marketplace update claude-pm
```

### Manual Installation

Clone this repository and register it as a Claude Code plugin:

```bash
git clone https://github.com/corrigantj/claude-pm.git
cd your-project
# Add to your project's .claude/plugins or global plugins
```

## Quick Start

### 1. Describe What You Want to Build

The `using-pm` skill is loaded automatically on session start. Just describe your project — it routes to brainstorming, which produces a PRD:

```
I want to build a user authentication system with Google OAuth
```

This kicks off `superpowers:brainstorming` to explore requirements, then saves a PRD to `docs/plans/`.

### 2. Structure into Wiki + GitHub Issues

Once you have a PRD, `using-pm` routes to `pm-structure` (or you can invoke it directly):

```
Structure this PRD into GitHub issues
```

This creates:
- A wiki PRD page and meta page
- A GitHub Milestone with a feature branch
- Story issues with task/bug sub-issues
- Gherkin acceptance criteria and dependency annotations
- Labels (`epic:`, `size:`, `status:`, `priority:`)

### 3. Dispatch Implementation Agents

```
Start implementing
```

This spawns parallel agents (default: 3), each:
- Working in its own git worktree
- Branching from the feature branch
- Following TDD (tests first from Gherkin scenarios)
- Creating a task PR targeting the feature branch

### 4. Check Progress

```
What's the project status?
```

Dashboard shows: progress bar, sub-issue grouping by story, CI status, blockers, next actions.

### 5. Review and Merge Task PRs

```
Check on task PRs
```

Polls task PRs for review status, merges approved PRs into the feature branch, and captures lessons learned for each completed task.

### 6. Integrate and Ship

```
Merge the feature branch
```

Merges the feature branch to main, creates a retrospective wiki page, calibrates token-based sizing estimates, and closes the milestone.

## Configuration

Create `.github/pm-config.yaml` in your project repository:

```yaml
# claude-pm v2 configuration
# All values shown are defaults and can be omitted if unchanged.

# Project identity (auto-detected from git remote if omitted)
project:
  owner: ""
  repo: ""
  base_branch: ""

# Agent execution
agents:
  max_parallel: 3    # Max concurrent agents
  model: opus        # Model for agents (opus | sonnet)

# Branch naming
branches:
  prefix: pm         # Branches: pm/{issue}-{slug}

# Worktree management
worktrees:
  directory: .worktrees

# Approval gates
approval_gates:
  before_dispatch: false
  before_merge: false
  before_close_milestone: false
  before_wiki_update: false

# Merge strategy (two-wave model)
merge:
  task_strategy: rebase    # squash | merge | rebase (wave 1: task → feature)
  feature_strategy: squash # squash | merge | rebase (wave 2: feature → main)
  delete_branch: true

# Build commands (auto-detected if omitted)
commands:
  test: ""
  lint: ""
  build: ""

# Additional labels beyond the default taxonomy
labels: []

# Wiki management
wiki:
  directory: .wiki    # Wiki clone location relative to repo root
  auto_clone: true    # Automatically clone the wiki repo on first use
  meta_page: ""       # Path to wiki meta page (auto-derived from epic name if empty)
  prd: ""             # Path to PRD wiki page (auto-derived from epic name if empty)

# Epics
epics:
  naming: kebab-case  # kebab-case | snake_case | camelCase

# Validation
validation:
  enabled: true   # Run validation checks
  strict: false   # Treat warnings as errors

# Review polling
review:
  polling_interval: 60    # Seconds between review-state polls
  polling_timeout: 3600   # Max seconds before polling gives up (default: 1 hour)
  polling_model: haiku    # Model used for polling (haiku | sonnet)
  require_codeowners: false

# Token-based sizing
sizing:
  metric: tokens   # tokens | lines | files
  token_ranges:    # Flat lookup for agents (auto-derived from buckets if empty)
  buckets:
    xs:
      lower: 1000
      upper: 10000
      description: "Trivial change, single file"
    s:
      lower: 10000
      upper: 50000
      description: "Small feature, few files"
    m:
      lower: 50000
      upper: 200000
      description: "Moderate feature, multiple files"
    l:
      lower: 200000
      upper: 500000
      description: "Large feature, significant scope"
    xl:
      lower: 500000
      upper: null
      description: "Must be split — too large for one agent session"
```

All values have sensible defaults. The file is optional.

## Architecture

### Two-Wave PR Model

Task PRs target the feature branch (wave 1, managed by `pm-review`). Once all tasks are merged, the feature branch is merged to main (wave 2, managed by `pm-integrate`). This isolates in-progress work from the main branch and enables parallel development without conflicts.

### Wiki Management

claude-pm maintains a project wiki with three page types:
- **PRD pages** — living design documents with a lifecycle: Draft, In Review, Active, Approved, Superseded
- **Meta pages** — index pages linking milestones, issues, and PRDs for an epic
- **Retro pages** — retrospective summaries created during pm-integrate with sizing calibration data

### Versioned Epics

Epics use lower-kebab-case naming with semantic versioning: `{epic}-v{Major}.{Minor}`. This allows multiple versions of the same epic to coexist (e.g., `auth-system-v1.0` and `auth-system-v2.0`), with wiki pages and milestones scoped to each version.

### Token-Based Sizing

Issues are sized based on estimated token consumption, configured as buckets in `.github/pm-config.yaml`. During `pm-integrate`, actual token usage is compared against estimates, and the sizing calibration is updated in the retrospective wiki page. This feedback loop improves future estimates.

### Label Taxonomy

Labels use a `:` delimiter with standardized prefixes:
- `epic:` — associates issues with a versioned epic
- `priority:` — urgency (critical, high, medium, low)
- `meta:` — metadata labels (e.g., `meta:ignore`, `meta:mustread`)
- `size:` — token-based sizing (xs, s, m, l, xl)
- `status:` — workflow state (ready, in-progress, in-review, done, blocked)

### Sub-Issue Hierarchy

Work is organized as stories containing task and bug sub-issues. Stories represent product-level requirements with Gherkin acceptance criteria. Tasks and bugs are implementation-level work items linked to their parent story via `<!-- pm:parent #N -->` comments.

## Skill Reference

| Skill | Purpose |
|-------|---------|
| `claude-pm:using-pm` | Gateway — kicks off brainstorming, routes to PM skills based on intent |
| `claude-pm:pm-structure` | Convert PRD into Wiki pages + Milestone + Issues + feature branch |
| `claude-pm:pm-dispatch` | Spawn parallel agents for ready issues |
| `claude-pm:pm-status` | Live progress dashboard from GitHub state |
| `claude-pm:pm-review` | Poll task PRs, merge into feature branch, capture lessons learned |
| `claude-pm:pm-integrate` | Merge feature branch to main, create retro, calibrate sizing |

## Plugin Structure

```
claude-pm/
├── .claude-plugin/plugin.json     # Plugin metadata (v0.2.0)
├── hooks/                         # SessionStart hook loads using-pm (gateway that routes to all other skills)
├── skills/                        # 6 skills: using-pm, pm-structure, pm-dispatch, pm-status, pm-review, pm-integrate
│   ├── using-pm/                  # Gateway router — brainstorming entry, capability detection
│   ├── pm-structure/              # PRD → Wiki + Milestone + Issues + feature branch
│   │   ├── story-template.md      # Product story template
│   │   ├── task-template.md       # Dev task sub-issue template
│   │   ├── bug-template.md        # Bug sub-issue template
│   │   ├── prd-template.md        # Wiki PRD page template
│   │   ├── meta-template.md       # Wiki meta page template
│   │   ├── pr-body-template.md    # PR body template
│   │   └── gherkin-guide.md       # BDD scenario writing guide
│   ├── pm-dispatch/               # Spawn parallel agents on feature branch
│   ├── pm-status/                 # Progress dashboard with sub-issue grouping
│   ├── pm-review/                 # Task PR polling, merge to feature branch, lessons learned
│   │   └── polling-prompt.md      # Polling sub-agent prompt template
│   └── pm-integrate/              # Feature→main PR, retro, wiki update, calibration
│       └── retro-template.md      # Retrospective wiki page template
├── agents/pm-implementer.md       # Subordinate agent: 9-phase TDD workflow
├── templates/pm-config.yaml       # Configuration schema with sizing buckets
├── CLAUDE.md
├── LICENSE
└── README.md
```

## License

MIT
