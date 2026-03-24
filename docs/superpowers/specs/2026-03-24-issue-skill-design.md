# Issue Skill — Ad-hoc Issue Creation, Investigation, and Triage

**Date:** 2026-03-24
**Status:** Design
**Scope:** limbic plugin — new skill (`limbic:issue`), new agent (`agents/investigator.md`), label taxonomy, stabilization workflow, preflight checks

## Problem

The limbic plugin currently creates all issues in structured batches via `limbic:structure` (PRD → stories → tasks). There is no way to:

1. Capture bugs discovered during development, testing, review, or post-integration use
2. Capture insights that lead to new work (enhancements, refactors) outside the PRD workflow
3. Systematically investigate, triage, and prioritize ad-hoc issues
4. Track stabilization work as a gate to exiting a milestone

The implementer agent has lightweight bug-filing (create a sub-issue under the parent story and move on), but no dedup, no investigation, no severity/priority recommendation, and no stabilization orchestration.

## JTBD

I want to exit this milestone. If there are issues, I need to fix them before I can exit. If there are no issues, I can exit immediately.

## Design

### 1. Architecture: Skill + Agent (Approach B)

Follows the existing dispatch/implementer pattern:

- **`limbic:issue` (skill)** — Thin dispatcher. Captures human input, spawns the investigator agent, handles the approval interaction on return.
- **`agents/investigator.md` (agent)** — Full pipeline: parse → detect context → dedup → create issue → investigate → recommend severity/priority → report.

All real work happens in the subagent to keep the main session context window clean.

### 2. Invocation Modes

**Mode 1: Investigate** — `/issue {description}`

The default. Human describes what they observed. The skill spawns an investigator agent that:
- Parses the description
- Checks for duplicates
- Creates the issue
- Investigates root cause using `superpowers:systematic-debugging`
- Recommends severity and priority
- Returns to the skill for human approval of labels

**Always stops after investigation.** The human decides what happens next.

**Mode 2: Fix** — `/issue fix #N`

For an already-investigated issue. The skill spawns a fix-mode agent that:
- Reads the investigation from the issue body
- Auto-detects push access to base branch (vibe mode vs PR mode)
- **Vibe mode:** fixes directly on the base branch with TDD, commits with `Fixes #{N}`, closes issue
- **PR mode:** creates a branch, implements with TDD, creates a PR targeting the appropriate branch, leaves issue open for human merge

The human can also batch investigated issues and run `limbic:dispatch` instead.

### 3. Investigator Agent Execution Phases

The agent receives: human's raw description, repo context (owner, repo, test/build commands), active milestone info, interactive vs programmatic flag.

**Phase 1: Parse Intent**
Extract from the human's description: what happened, what was expected, which area of the codebase, any mentioned issue/story numbers.

**Phase 2: Detect Context**
- Determine active milestone. If multiple open milestones, use the one matching any referenced issues. If none, the issue is milestone-less (standalone backlog item).
- Auto-detect push access to base branch → vibe or PR mode. Store for the fix phase (if invoked later).

**Phase 3: Dedup Check**
Two-pass duplicate detection against open issues in the milestone:

1. **Scenario-anchored match** (strong signal): same parent story + same failing Gherkin scenario referenced. If the human says "S2 on story #15 is broken" and an open bug already references S2 on #15, that's a dupe.
2. **Semantic similarity fallback**: search open issues with keyword extraction from description. Compare titles and bodies for overlap — same error messages, same files, same behavior. Agent uses judgment (not a numeric threshold).

On dupe found:
- Add a comment to the existing issue with the new context
- Return `status: duplicate` with the existing issue number

On uncertain match:
- If interactive: present the candidate, ask "Is this the same issue as #42?"
- If programmatic: create a new issue (err on the side of not losing information)

**Phase 4: Stabilization Ticket Lookup**
If in stabilization context (human said "stabilization" or a stabilization ticket already exists for the milestone), look up the stabilization parent ticket. If somehow missing (should have been created at milestone creation time), flag an error. Otherwise, the issue is standalone in the milestone with no parent.

**Phase 5: Create Issue**
Minimal spike — fast capture before investigation begins:
- Title: concise summary
- Body: observed vs expected behavior, environment info, parent link (stabilization ticket if applicable, none otherwise)
- Labels: `type:bug` or `type:task` (defect vs enhancement)
- If in stabilization context: create as sub-issue of stabilization ticket (via GitHub Sub-issues API, falling back to `<!-- limbic:parent #N -->`)
- If a related feature story is identifiable: include a URL link in the description for progressive context loading

**Phase 6: Context Load**
If a parent story is referenced, read it for Gherkin scenarios and architecture context. If a wiki meta page exists for the epic, read it. This informs the investigation.

**Phase 7: Investigate**
Invoke `superpowers:systematic-debugging`:
- Identify root cause
- Document reproduction steps (verified)
- Identify affected files
- Assess blast radius (isolated issue or affects other scenarios?)
- Propose fix approach

**Phase 8: Update Issue**
Edit the issue body with investigation findings:
- Root cause analysis
- Verified reproduction steps
- Affected files list
- Proposed fix approach
- Blast radius assessment

**Phase 9: Recommend Severity + Priority**
Based on investigation findings:

Severity (impact on the system):
- `severity:critical` — data loss, crash, or security vulnerability
- `severity:major` — broken feature, no workaround
- `severity:minor` — broken feature, workaround exists
- `severity:trivial` — cosmetic or minor inconvenience

Priority (urgency of fix):
- `priority:critical` — fix now
- `priority:high` — fix this milestone
- `priority:medium` — fix next milestone
- `priority:low` — backlog

Include reasoning with the recommendation.

- If interactive: return recommendation to skill, which presents it for human approval before applying labels
- If programmatic: apply labels directly

**Phase 10: Report**
Return structured result:

```yaml
result:
  issue_number: {N}
  status: created | duplicate
  duplicate_of: {N or null}
  severity_recommendation: {label}
  priority_recommendation: {label}
  reasoning: "{why these levels}"
  fix_mode: vibe | pr
  affected_files: [{list}]
  blast_radius: isolated | cross-scenario | cross-story
  proposed_fix: "{summary}"
```

### 4. Label Taxonomy: Adding Severity

New `severity:` label prefix added to `limbic.yaml` defaults:

```yaml
labels:
  severity:
    critical:
      color: "b60205"
      description: "Data loss, crash, or security vulnerability"
    major:
      color: "d93f0b"
      description: "Broken feature, no workaround"
    minor:
      color: "fbca04"
      description: "Broken feature, workaround exists"
    trivial:
      color: "0e8a16"
      description: "Cosmetic or minor inconvenience"
```

Existing `priority:` labels unchanged.

### 5. Stabilization Ticket

A stabilization ticket is created deterministically at milestone creation time, not lazily by the investigator.

**Script: `scripts/create-stabilization-ticket.sh`**
- Called by `limbic:structure` after milestone creation
- Creates a `type:task` issue titled "Stabilization: {epic}-v{Major}.{Minor}"
- Assigned to the milestone
- Body contains a link to the feature's wiki meta page
- Idempotent — if one already exists for this milestone, no-op

**Preflight check: `scripts/preflight-checks/check-stabilization.sh`**
- For each open milestone, verify a stabilization ticket exists
- Emits JSONL warning/failure if missing
- `limbic:setup` can remediate drift by creating missing stabilization tickets

**Stabilization context detection** (by the investigator agent):
- Explicit: human says "stabilization" or "stabilize" in their description
- Implicit: a stabilization ticket already exists for the active milestone and human references it
- Otherwise: standalone issue, no parent

**Exit criteria:** The milestone can be exited when all children of the stabilization ticket are closed. `limbic:integrate` checks this in its pre-integration audit.

### 6. Integration with Existing Skills

**`limbic:structure`** — After creating the milestone (existing step 5), call `create-stabilization-ticket.sh`. No other changes.

**`limbic:status`** — Shows the stabilization ticket with its children in the dashboard, same grouping pattern as stories with tasks. Includes severity labels in display.

**`limbic:dispatch`** — No changes. Investigated issues have the right shape (affected files, parent link, milestone) to be dispatched normally.

**`limbic:review`** — No changes. PRs from `/issue fix` flow through the normal review pipeline.

**`limbic:integrate`** — Pre-integration audit (step 1) additionally checks: if a stabilization ticket exists, are all its children closed? If not, flag as blockers.

**`limbic:setup`** — Adds `severity:` labels to label creation/verification. Preflight checks validate they exist. Remediates missing stabilization tickets for existing milestones.

**Implementer agent** — No changes. Its lightweight bug-filing behavior stays as-is. Those bugs are visible to `/issue` during dedup.

### 7. File Structure

New files:

```
limbic/
├── skills/
│   └── issue/
│       ├── SKILL.md                # Thin dispatcher: capture input, spawn agent, handle approval
│       └── investigator-prompt.md  # Template filled before spawning agent
├── agents/
│   └── investigator.md             # Subagent: 10-phase spike → investigate → recommend
├── scripts/
│   ├── create-stabilization-ticket.sh  # Called by structure at milestone creation
│   └── preflight-checks/
│       └── check-stabilization.sh      # Verify stabilization tickets exist
```

Changes to existing files:

| File | Change |
|------|--------|
| `templates/limbic.yaml` | Add `severity:` label definitions |
| `scripts/preflight-checks/runner.sh` | Include `check-stabilization.sh` |
| `scripts/preflight-checks/check-labels.sh` | Verify severity labels exist |
| `skills/structure/SKILL.md` | Call `create-stabilization-ticket.sh` after milestone creation |
| `skills/integrate/SKILL.md` | Check stabilization ticket children in pre-integration audit |
| `.claude-plugin/plugin.json` | Register new skill |
| `hooks/session-start.sh` | Add `/issue` to routing table |
| `CLAUDE.md` | Update plugin structure and skill reference table |

### 8. Procedural Context: Stabilization Loop

The `/issue` skill enables a stabilization loop that fits between `limbic:integrate` (or `limbic:review`) and milestone exit:

1. **Deploy** — Completed milestone work is deployed to an environment
2. **Test/Review** — Automated evals, TDD, human review. Human provides feedback.
3. **Capture** — `/issue {description}` for each problem or enhancement found. Agent investigates, recommends severity/priority, human approves.
4. **Fix** — Human decides per-issue: `/issue fix #N` for single fixes, or `limbic:dispatch` for batches. Vibe mode (direct commit) or PR mode (human merge) auto-detected.
5. **Retest** — Another round of evaluation
6. **Repeat** steps 3-5 until stabilization ticket children are all closed
7. **Exit** — `limbic:integrate` confirms stabilization complete, proceeds with milestone close and retrospective
