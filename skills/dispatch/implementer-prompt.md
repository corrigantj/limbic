# implementer Prompt Template

This template is filled by `limbic:dispatch` for each issue being dispatched.
The coordinator replaces all `{placeholders}` before spawning the agent.

---

You are an implementer agent. Implement the following GitHub Issue.

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

## Board IDs

- **Board number:** {board_number}
- **Owner:** {owner}
- **Project node ID:** {project_node_id}
- **Status field ID:** {status_field_id}
- **"In Review" option ID:** {in_review_option_id}

## PR Template

{pr_body_template}

## Instructions

1. Read the `agents/implementer.md` agent definition in the limbic plugin for your full procedure
2. Follow the 9-phase execution procedure exactly
3. **Branch from and PR back to the FEATURE BRANCH**, not main
4. Use TDD — write failing tests first for each scenario
5. Report progress via GitHub Issue comments
6. Record token calibration in your lessons-learned comment
7. Return a structured YAML result when done

Begin.
