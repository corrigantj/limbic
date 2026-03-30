---
name: issue
description: Use when reporting a bug, filing an issue, investigating a problem, fixing an already-investigated issue, or quickly capturing a backlog idea — supports ad-hoc issue creation, duplicate detection, root-cause investigation, severity/priority recommendation, stabilization tracking, and lightweight backlog capture
---

# issue — Ad-hoc Issue Creation, Investigation, and Triage

**Type:** Rigid. Follow this process exactly.

## Invocation Modes

This skill has three modes:

1. **Investigate** (default) — `/issue {description}`
   Human describes a bug, enhancement, or problem. The skill spawns an investigator agent.

2. **Fix** — `/issue fix #{issue_number}`
   For an already-investigated issue. The skill spawns a fix agent.

3. **Backlog** — `/issue backlog "idea title"` or `/issue backlog {tier} "idea title"`
   Quick capture of a backlog idea. No investigation, no milestone. Tier is `now`, `next`, `later` (default), or `icebox`.

## Mode 1: Investigate

### Inputs

- A human's description of an issue (bug, enhancement, or problem)
- Access to the project repository (gh CLI)

### Checklist

You MUST create a task for each of these items and complete them in order:

1. **Gather context** — read limbic.yaml, detect milestones, read preflight capability flags (Step 1)
2. **Fill prompt and spawn investigator** — fill the investigator-prompt.md template and spawn the agent (Step 2)
3. **Handle result** — process the agent's structured result, handle approval if interactive (Step 3)

### Process

#### Step 1: Gather Context

Read `.github/limbic.yaml` from the project root. Extract:
- `owner` and `repo` from git remote
- `base_branch` (default: `main`)
- Build commands: `test_command`, `lint_command`, `build_command`

Fetch open milestones:
```bash
gh api repos/{owner}/{repo}/milestones?state=open --jq '.[] | "\(.number)\t\(.title)"'
```

Read preflight capability flags from the PreToolUse hook's additionalContext (JSONL):
- `repo.issue_types` — pass/fail
- `repo.sub_issues` — pass/fail

#### Step 2: Fill Prompt and Spawn Investigator

1. Read `skills/issue/investigator-prompt.md`
2. Replace all `{placeholders}` with values from Step 1 and the human's description
3. Set `{interactive_flag}` to `true` (human is present in the conversation)
4. Spawn the investigator agent:

```
Agent tool:
  subagent_type: "limbic:investigator"
  prompt: {filled_prompt}
```

Wait for the agent to return.

#### Step 3: Handle Result

Parse the agent's structured YAML result.

**If `status: duplicate`:**
- Report to the human: "This looks like a duplicate of #{duplicate_of}. I added your context as a comment on the existing issue."
- Done.

**If `status: created` (interactive):**
- Present the investigation summary:
  ```
  Issue #{issue_number} created and investigated.

  Recommended severity: {severity_recommendation}
  Recommended priority: {priority_recommendation}
  Reasoning: {reasoning}

  Blast radius: {blast_radius}
  Fix mode: {fix_mode} (auto-detected)
  Proposed fix: {proposed_fix}

  Apply these labels? (yes / override with different values / skip)
  ```
- On approval: apply labels via `gh issue edit --add-label`
- On override: apply the human's chosen labels
- On skip: leave unlabeled

**If `status: created` (programmatic — this path is for when other skills invoke /issue):**
- Labels already applied by the agent. Return the result silently.

## Mode 2: Fix

### Inputs

- An issue number (`/issue fix #N`)
- The issue must already be investigated (has root cause, affected files, proposed fix in its body)

### Checklist

1. **Read the issue** — fetch issue body, extract investigation findings (Step 1)
2. **Detect fix mode** — check vibe vs PR mode (Step 2)
3. **Execute fix** — TDD implementation (Step 3)

### Process

#### Step 1: Read the Issue

```bash
gh issue view {issue_number} --repo {owner}/{repo} --json body,title,labels,milestone
```

Verify the issue has investigation findings (Fix Guidance or Investigation section populated, not the `<!-- Investigation pending -->` placeholder). If not investigated yet, tell the human: "This issue hasn't been investigated yet. Run `/issue {description}` first or manually add investigation findings to the issue body."

Extract: root cause, affected files, proposed fix approach, severity, priority.

#### Step 2: Detect Fix Mode

Auto-detect vibe vs PR mode:
```bash
# Check branch protection
gh api repos/{owner}/{repo}/branches/{base_branch}/protection 2>/dev/null
```
- Branch protection with required reviews → PR mode
- No protection or no review requirement → check push access:
  ```bash
  gh api repos/{owner}/{repo} --jq '.permissions.push'
  ```
- Push access → vibe mode. No push access → PR mode.

Tell the human which mode was detected and what will happen.

#### Step 3: Execute Fix

**Vibe mode:**
1. Ensure you're on the base branch and it's up to date
2. Invoke `superpowers:test-driven-development`
3. Write a failing test that reproduces the issue
4. Implement the minimal fix to make it pass
5. Run full test suite — verify no regressions
6. Invoke `superpowers:verification-before-completion`
7. Commit with message: `fix: {description} (Fixes #{issue_number})`
8. Push to base branch
9. Close the issue:
   ```bash
   gh issue close {issue_number} --repo {owner}/{repo} --reason completed
   ```

**PR mode:**
1. Create a branch: `fix/{issue_number}-{slug}`
2. Invoke `superpowers:test-driven-development`
3. Write a failing test that reproduces the issue
4. Implement the minimal fix to make it pass
5. Run full test suite — verify no regressions
6. Invoke `superpowers:verification-before-completion`
7. Commit with message: `fix: {description}`
8. Push branch and create PR:
   ```bash
   gh pr create --title "Fix #{issue_number}: {title}" \
     --body "Fixes #{issue_number}

   ## Root Cause
   {from investigation}

   ## Fix
   {what was changed}

   ## Test Plan
   - [ ] New test reproduces the issue
   - [ ] Fix makes the test pass
   - [ ] Full test suite passes with no regressions"
   ```
9. Tell the human the PR is ready for review. Do NOT close the issue — the PR merge will close it via the `Fixes #N` reference.

## Mode 3: Backlog

### Inputs

- A title string (`/issue backlog "idea title"`)
- Optional tier keyword: `now`, `next`, `later` (default), `icebox`

### Invocation Examples

```
/issue backlog "add rate limiting to public API"
/issue backlog now "fix onboarding flow before launch"
/issue backlog icebox "explore GraphQL migration"
```

### Checklist

1. **Parse arguments and create issue** — extract tier and title, create the GitHub issue (Step 1)
2. **Offer description** — ask if the user wants to add detail (Step 2)

### Process

#### Step 1: Parse Arguments and Create Issue

Parse the arguments after `backlog`:
- If the first word is `now`, `next`, `later`, or `icebox`, use it as the tier. The rest is the title.
- Otherwise, default tier is `later`. Everything after `backlog` is the title.
- Strip surrounding quotes from the title if present.

Read `owner`/`repo` from git remote:
```bash
gh repo view --json owner,name --jq '.owner.login + "/" + .name'
```

Create the issue:
```bash
gh issue create --repo {owner}/{repo} \
  --title "{title}" \
  --label "backlog:{tier}" --label "type:task" \
  --body ""
```

Capture the issue number from the output.

Report: `Backlog item #{number} created with backlog:{tier}`

#### Step 2: Offer Description

Ask the user: "Want to add any detail to the description for later?"

- If yes: take the user's input and update the issue:
  ```bash
  gh issue edit {number} --repo {owner}/{repo} --body "{user_input}"
  ```
- If no: done.

### What This Mode Does NOT Do

- No investigation or systematic debugging
- No duplicate check
- No severity/priority recommendation
- No stabilization ticket association
- No milestone assignment
- No agent spawning
