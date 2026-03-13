# Agile System Design for GitHub
## A Lightweight, Surgically Rigorous Framework for AI-Agent Development

---

## 1. Architecture Overview

This system maps your full product lifecycle onto GitHub's native tooling. The hierarchy:

```
Meta Wiki (GitHub Wiki page — canonical feature state)
  └── Versioned PRD (GitHub Wiki page — requirements for one epic version)
        ↕ bi-directional link
Roadmap (GitHub Project - Board view)
  └── Epic v[X] (Milestone, lower-kebab-case)
        └── Product Ticket (Issue, Issue Type: story)
              ├── Dev Task (Issue, Issue Type: task — sub-issue)
              └── Bug (Issue, Issue Type: bug — sub-issue)
```

### GitHub Feature Mapping

| Concept | GitHub Primitive | Why |
|---|---|---|
| **Roadmap** | Project (Board view, grouped by Epic label) | Filterable, drag-and-drop, custom fields |
| **Backlog** | Project (Table view, filtered: no milestone) | Same project, different view |
| **Epic** | Milestone + Label (e.g., `epic:auth`) | Milestones give % complete + deadline; labels enable cross-cutting queries |
| **Epic Version** | Milestone naming: `auth-v1.0`, `auth-v2.0` (lower-kebab-case) | Milestones are cheap to create; versions are just new milestones |
| **Meta Wiki** | Wiki page (naming: bare epic name, e.g., `Auth`) | Canonical current state of a feature; primer + version history; what agents read first |
| **PRD** | Wiki page (naming: `PRD-[epic-name]-v[X]`) | Living reference doc; supports TOC, tables, narrative; bi-directionally linked to milestones + issues |
| **Product Ticket** | Issue (Issue Type: `story`) | Your BDD-style acceptance criteria live here |
| **Dev Task** | Sub-issue (Issue Type: `task`) under product ticket | GitHub's native sub-issues feature |
| **Bug** | Sub-issue (Issue Type: `bug`) under product ticket | Linked to parent scenario that failed |
| **Sprint** | Iteration field on Project (built-in) | GitHub Projects has native iteration/sprint support |
| **Retrospective** | Wiki page (e.g., `Retro-auth-v1.0`) | Created at milestone completion; accumulates lessons from all stories |

---

## 2. Label Taxonomy

Labels are your system's connective tissue. Keep them namespaced and tight.

### Required Labels

```
# Epic labels (color: #1D76DB blue)
epic:auth          # Authentication + Authorization
epic:calendar      # Calendar management
epic:onboarding    # User onboarding
epic:billing       # Billing + subscriptions

# Type labels — DEPRECATED: Use GitHub Issue Types (story, task, bug) instead.
# If your repo does not support Issue Types, fall back to these labels:
# type:story         # Product-level ticket
# type:task          # Dev task
# type:bug           # Bug report

# Priority labels (color: gradient)
priority:critical  # (#B60205) Blocks release
priority:high      # (#D93F0B) Must-have for sprint
priority:medium    # (#FBCA04) Should-have
priority:low       # (#0E8A16) Nice-to-have

# Agent labels (color: #7057FF purple)
agent:ready        # Ticket is fully spec'd for AI agent pickup
agent:blocked      # Agent hit a blocker, needs human input
agent:review       # Agent work complete, needs human review

# Meta labels (color: #BFDADC teal)
meta:ignore        # Exclude from agent context queries — any artifact with this label is hidden from agents

# Size labels (color: #C5DEF5 light blue) — based on estimated token consumption
size:xs            # Minimal token cost (~1K-10K tokens)
size:s             # Low token cost (~10K-50K tokens)
size:m             # Moderate token cost (~50K-200K tokens)
size:l             # High token cost (~200K-500K tokens)
size:xl            # Very high token cost (500K+ tokens — should be broken down further)
```

> **Token calibration:** At task completion, agents should record estimated vs. actual token consumption. Over time, this data enables increasingly accurate sizing. The retrospective aggregates calibration data across all stories in a milestone.

---

## 3. Project Configuration (GitHub Projects v2)

Create one Project for the product. Use **views** to slice it.

### Custom Fields

| Field | Type | Purpose |
|---|---|---|
| `Sprint` | Iteration (2-week cycles) | Sprint assignment |
| `Epic` | Single select (mirrors epic labels) | Grouping in board view |
| `Priority` | Single select | Sorting |
| `Points` | Number | Optional — complexity estimate for velocity |
| `Agent Assignable` | Checkbox | Can an AI agent pick this up autonomously? |
| `PRD Link` | Text (URL) | Link to Wiki PRD page (e.g., `wiki/PRD-Auth-v1`) |

### Views

| View | Type | Filter / Group | Purpose |
|---|---|---|---|
| **Roadmap** | Board | Group by: Epic | High-level epic progress |
| **Sprint Board** | Board | Filter: current Sprint; Group by: Status | Active sprint work |
| **Backlog** | Table | Filter: no Sprint assigned | Grooming + prioritization |
| **Agent Queue** | Table | Filter: `agent:ready`, no assignee | AI agent work queue |
| **Bug Triage** | Table | Filter: Issue Type `bug`, sorted by priority | Bug review |

---

## 4. Issue Templates

### 4a. PRD — GitHub Wiki Page

PRDs are **living reference documents**, not work items. They have narrative structure, scope matrices, design links, analytics plans, and strategy context that don't fit in an Issue body. They live in the **GitHub Wiki**.

#### Why Wiki, Not Issues

| Concern | Issue | Wiki |
|---|---|---|
| Table of Contents | ❌ No native TOC | ✅ Auto-generated sidebar |
| Long-form narrative | ⚠️ Cramped, no page structure | ✅ Full markdown pages |
| Revision history | ⚠️ Edit history only | ✅ Full git-backed versioning |
| Scope matrices / tables | ⚠️ Renders but hard to maintain | ✅ First-class markdown tables |
| Discoverability | ⚠️ Buried in issue list | ✅ Wiki sidebar navigation |
| Linkable from Issues | ✅ Native | ✅ Via URL convention |
| Appears in Project views | ✅ Native | ❌ Not a work item |

The tradeoff is clear: Wiki loses Project board visibility but gains everything a reference doc needs. The linking strategy below bridges the gap.

#### Naming Convention

```
Wiki page:    PRD-[epic-name]-v[Major]
Milestone:    [epic-name]-v[Major].[Minor]     (lower-kebab-case, always include minor)
Label:        epic:[name]
```

**Examples:**
```
PRD-auth-v1          ↔  Milestone: auth-v1.0, auth-v1.1
PRD-auth-v2          ↔  Milestone: auth-v2.0, auth-v2.1
PRD-calendar-v1      ↔  Milestone: calendar-v1.0
```

PRD titles can be human-friendly (e.g., "Auth with Google v1"); the decomposition skill handles conversion to lower-kebab-case for milestone names.

A PRD covers a **major version** of an epic. Minor versions (v1.0 → v1.1) share the same PRD with a changelog section. A new major version (v1 → v2) gets a new PRD page. Always include the minor version number (v1.0, not v1) to simplify parsing.

#### Bi-Directional Linking Strategy

GitHub Wiki has no native backlink support, so you engineer bi-directionality through convention across three layers:

**Layer 1: Wiki → Issues (downstream — PRD links to its children)**

Every wiki PRD page has a standardized `Traceability` footer:

```markdown
## Traceability

| Artifact | Link |
|----------|------|
| Epic Milestone(s) | [auth-v1.0](../../milestone/3) · [auth-v1.1](../../milestone/7) |
| Product Tickets | #10 · #11 · #12 · #14 |
| Design | [Figma: Auth Flows](https://figma.com/...) |
| Analytics | [Tagging Plan](https://docs.google.com/...) |
| Strategy | [Forward-Looking Strategy](https://docs.google.com/...) |
```

**Layer 2: Milestone → Wiki (epic links up to its PRD)**

Each milestone's **description field** (supports markdown) opens with:

```markdown
📋 PRD: [auth-v1.0 Product Brief](../../wiki/PRD-auth-v1)

Login, registration, and email/password authentication.
Ships baseline funnel metrics + telemetry.
```

**Layer 3: Issues → Wiki (tickets link up to their PRD)**

Three redundant mechanisms ensure agents always find the PRD:

1. **Project custom field** — `PRD Link` (URL) on every story → `../../wiki/PRD-auth-v1`
2. **Story template field** — Required `PRD` input at the top of every product ticket (see 4b below)
3. **Issue body convention** — First line of Context section references the PRD

#### Wiki PRD Page Template

Save this as a template page in your wiki (e.g., `_PRD-Template`). Copy it when starting a new epic.

> **Wiki page:** `PRD-[epic-name]-v[Major]`
>
> **Note:** The sections below are recommendations, not all required for every PRD. Let the brainstorming/LLM process determine which sections are necessary for each specific feature. The only mandatory sections are Background, Functional Requirements, and Traceability.

```markdown
# [Epic Name] v[Major] — Product Brief

> **Epic:** `epic:[name]` · **Milestone(s):** [epic-name-vX.0](../../milestone/N)
> **Author:** @handle · **Last Updated:** YYYY-MM-DD
> **Status:** 🟡 Draft | 🟢 Approved | 🔵 In Progress | ✅ Shipped

---

## Table of Contents
- [Background](#background)
- [Objectives](#objectives)
- [Target Users](#target-users)
- [Scope Matrix](#scope-matrix)
- [Functional Requirements](#functional-requirements)
- [Non-Functional Requirements](#non-functional-requirements)
- [Flows & Designs](#flows--designs)
- [Analytics Requirements](#analytics-requirements)
- [Dependencies & Risks](#dependencies--risks)
- [Open Questions](#open-questions)
- [Related ADRs](#related-adrs)
- [Changelog](#changelog)
- [Traceability](#traceability)

---

## Background

[Why are we building this? What's broken today? Include user research,
data, failed experiments, and business context. An AI agent reading this
section should understand the *intent* behind every product ticket in
this epic without needing to ask follow-up questions.]

**Core Issues:**
- [Issue 1 — with supporting evidence / links]
- [Issue 2 — with supporting evidence / links]

**Sources:**
- [User Research Report](link) — @author, date
- [Competitive Analysis](link) — @author, date

---

## Objectives

The objectives of this release are:

1. **[Objective 1]** — [Brief description of what success looks like]
2. **[Objective 2]** — [Brief description]
3. **[Objective 3]** — [Brief description]

**Success Metrics:**

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| [Metric 1] | [baseline or N/A] | [target] | [how measured] |
| [Metric 2] | [baseline or N/A] | [target] | [how measured] |

---

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary | [who + context] | [what they need from this epic] |
| Secondary | [who + context] | [what they need] |

---

## Scope Matrix

[This section is critical for AI agents building auth guards, route
protection, conditional rendering, and feature flags. Be exhaustive.]

| Capability / Page | Visitor | Registered | Subscribed | Unsubscribed | Admin |
|-------------------|---------|------------|------------|--------------|-------|
| Home | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard | ❌ | Preview | Full | Read-only | ❌ |
| Settings | ❌ | ❌ | ✅ | Limited | ❌ |
| ... | ... | ... | ... | ... | ... |

**In scope for this version:**
- [Feature / capability A]
- [Feature / capability B]

**Explicitly out of scope (deferred to v[Next]):**
- [Feature C — reason for deferral]
- [Feature D — reason for deferral]

---

## Functional Requirements

Each requirement maps to one or more product tickets (issues).

| ID | Requirement | Product Ticket(s) |
|----|-------------|-------------------|
| FR-1 | [Users must be able to...] | #10, #11 |
| FR-2 | [System must... when...] | #12 |
| FR-3 | [...] | #14 |

---

## Non-Functional Requirements

- **Performance:** [e.g., Page load < 2s on 3G]
- **Security:** [e.g., All PII encrypted at rest, OWASP Top 10]
- **Accessibility:** [e.g., WCAG 2.1 AA]
- **Scalability:** [e.g., Support 10K concurrent users]
- **Compliance:** [e.g., GDPR, SOC2]

---

## Flows & Designs (optional)

Include necessary flow definitions if required to clarify the feature.
Format is flexible — Mermaid, digraph, flowchart, or any format the agent
finds useful. Only include what is needed to remove ambiguity.

---

## Analytics Requirements (optional)

Include if the feature requires event tracking, tagging, or telemetry.
Not every project needs an analytics plan — omit if not applicable.

---

## Dependencies & Risks

| Dependency / Risk | Type | Owner | Status | Mitigation |
|-------------------|------|-------|--------|------------|
| [External API availability] | Dependency | @handle | 🟡 | [fallback plan] |
| [Email deliverability] | Risk | @handle | 🔴 | [use commercial ESP] |

---

## Open Questions

- [ ] [Question 1] — @owner · Due: YYYY-MM-DD
- [ ] [Question 2] — @owner · Due: YYYY-MM-DD
- [x] [Resolved question] — Decision: [what was decided] · @owner · YYYY-MM-DD

---

## Related ADRs

Reference any Architecture Decision Records (stored in GitHub Discussions)
that were created or consulted during this PRD's development.

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-NNN](link-to-discussion) | [Decision title] | Accepted / Proposed / Superseded |

---

## Changelog

Track what changed between minor versions so agents and team members
understand how scope evolved.

| Date | Version | Change | Author |
|------|---------|--------|--------|
| YYYY-MM-DD | v1.0 | Initial PRD | @handle |
| YYYY-MM-DD | v1.1 | Added password reset to scope | @handle |
| YYYY-MM-DD | v1.1 | Deferred "remember me" to v1.2 | @handle |

---

## Traceability

| Artifact | Link |
|----------|------|
| Meta Wiki Page | [EpicName](./EpicName) |
| Epic Milestone(s) | [epic-name-vX.0](../../milestone/N) · [epic-name-vX.1](../../milestone/M) |
| Product Tickets | #10 · #11 · #12 · #14 |
| Design | [Figma link] |
| Analytics | [Tagging plan link] |
| Strategy | [Strategy deck link] |
| Previous Version PRD | [PRD-EpicName-v(X-1)](./PRD-EpicName-v0) or N/A |
```

#### Wiki Sidebar Organization

GitHub Wiki sorts the sidebar alphabetically by page name. Use bare epic names for meta pages and the `PRD-` prefix for versioned PRDs — they naturally group together:

```
Home                        ← wiki landing page (links to all meta pages + project tracker)
Auth                        ← meta page (canonical current state)
  PRD-auth-v1               ← versioned PRD (shipped)
  PRD-auth-v2               ← versioned PRD (in progress)
  Retro-auth-v1.0           ← retrospective for auth-v1.0 milestone
Billing                     ← meta page
  PRD-billing-v1            ← versioned PRD
Calendar                    ← meta page
  PRD-calendar-v1           ← versioned PRD
  Retro-calendar-v1.0       ← retrospective for calendar-v1.0 milestone
Onboarding                  ← meta page
  PRD-onboarding-v1         ← versioned PRD
_Meta-Template              ← underscore prefix hides from sidebar
_PRD-Template               ← underscore prefix hides from sidebar
_Retro-Template             ← retrospective template
_Wiki-Conventions           ← team reference, not a PRD
```

#### Meta Wiki Pages — Canonical Feature State

The PRDs answer "what are we building next?" and tickets answer "what's the work?" But neither answers **"what IS this feature today?"** — which is exactly what an agent needs when it picks up a ticket in Auth v3 and has to understand the accumulated decisions from v1 and v2.

Meta wiki pages fill this gap. One per epic. Updated once per shipped version (~10 minutes).

**Relationship to PRDs:**

```
Meta Page (Auth)              ← "What does auth look like in production today?"
  ├── PRD-auth-v2             ← "What are we building next for auth?"
  ├── PRD-auth-v1             ← "What did we build before? What decisions were made?"
  └── (future: PRD-auth-v3)
```

The meta page is a **pointer + primer**, not a duplicate. It doesn't restate PRD content — it synthesizes the cumulative result of all shipped versions and points to each PRD for the details.

**Agent reading chain (full context hierarchy):**

```
1. Meta page (Auth)       → What exists today? Scope matrix? Locked-in decisions?
2. Current PRD (v2)       → Full requirements for this version. What's in/out of scope?
3. Product ticket (#87)   → What exactly am I building? Acceptance criteria?
4. Dev task (#87.1)       → What do I implement in this session?
```

Each layer adds specificity. No layer duplicates another.

**Meta Wiki Page Template:**

Save as `_Meta-Template` in the wiki. Copy when creating a new epic.

> **Wiki page:** `[EpicName]` (bare name, no prefix)

```markdown
# [Epic Name]

> **Current Version:** [epic-name-vX.Y](./PRD-epic-name-vX) · **Status:** ✅ Shipped | 🔵 In Progress
> **Epic Label:** `epic:[name]` · **Active Milestone:** [epic-name-vX.Y](../../milestone/N)

---

## What This Feature Does Today

[2-3 paragraph narrative. What can users do RIGHT NOW in production?
Not what's being built — what's live. An agent reading this should
understand the current system well enough to avoid breaking it
while implementing new work.]

---

## Architecture Summary

[High-level technical reality. Key services, data models, primary flows.
This is what an agent checks before writing code to ensure compatibility.]

- **Primary service / provider:** [e.g., Firebase Auth, Stripe, custom]
- **Key patterns:** [e.g., magic link → JWT, event sourcing, CQRS]
- **Data models:** [e.g., User, Session, Role — or link to schema]
- **Key files / directories:** [e.g., `src/auth/`, `src/middleware/authGuard.ts`]
- **API endpoints:** [e.g., `POST /auth/login`, `POST /auth/verify`]
- **Environment / config:** [e.g., env vars, feature flags]

---

## Scope Matrix (Current Production State)

[Evolved from the most recent shipped PRD. This is the canonical
"who can access what" — agents building route guards or conditional
UI reference THIS, not individual PRDs.]

| Capability | Visitor | Registered | Subscribed | Admin |
|------------|---------|------------|------------|-------|
| Home | ✅ | ✅ | ✅ | ✅ |
| Dashboard | ❌ | Preview | Full | ❌ |
| Settings | ❌ | ❌ | ✅ | ❌ |
| ... | ... | ... | ... | ... |

---

## Version History

| Version | Status | Milestone | Summary |
|---------|--------|-----------|---------|
| [vX.Y](./PRD-epic-name-vX) | 🔵 In Progress | [Milestone](../../milestone/N) | [one-line summary] |
| [vX.0](./PRD-epic-name-vX) | ✅ Shipped | [Milestone](../../milestone/M) | [one-line summary] |
| [v(X-1).0](./PRD-epic-name-v(X-1)) | ✅ Shipped | [Milestone](../../milestone/L) | [one-line summary] |

---

## Key Decisions Log

[Accumulated architectural decisions that span versions. Agents need
this to avoid relitigating settled debates or making incompatible choices.]

| Decision | Date | Version | Context | Alternatives Considered |
|----------|------|---------|---------|------------------------|
| [Decision 1] | YYYY-MM | vX.0 | [Why this was decided] | [What else was considered] |
| [Decision 2] | YYYY-MM | vX.1 | [Why] | [Alternatives] |

---

## Dependencies on Other Epics

| Epic | Relationship | Direction |
|------|-------------|-----------|
| [Other Epic](./OtherEpic) | [e.g., Subscribed role depends on Stripe webhook] | This → Other |
| [Other Epic](./OtherEpic) | [e.g., Registration hands off to onboarding] | This → Other |

---

## Known Limitations & Tech Debt

[What's knowingly imperfect in the current production state?
Agents should know these exist so they don't try to "fix" them
as part of unrelated work — or so they DO fix them if it's in scope.]

- [Limitation 1 — e.g., "No MFA yet. Scoped for v2."]
- [Limitation 2 — e.g., "JWT expiry is hardcoded to 24hr, not configurable."]
- [Tech debt — e.g., "Auth middleware has no unit tests. Added to v2 scope."]
```

**Maintenance cadence:**

| Event | Update Required |
|-------|----------------|
| Epic version ships | Update: "What This Feature Does Today", Scope Matrix, Version History. ~10 min. |
| Major architecture decision | Add row to Key Decisions Log. ~2 min. |
| New epic dependency discovered | Add row to Dependencies. ~2 min. |
| New PRD created for next version | Add row to Version History (status: 🔵). ~1 min. |

**Wiki Home page:**

The wiki `Home` page acts as the top-level index — link to every meta page:

```markdown
# [Product Name] — Wiki

> **GitHub Project Tracker:** [View Milestones & Issues](../../milestones)

## Feature Areas

| Feature | Current Version | Status |
|---------|----------------|--------|
| [Auth](./Auth) | [v2.0](./PRD-auth-v2) | 🔵 In Progress |
| [Calendar](./Calendar) | [v1.0](./PRD-calendar-v1) | ✅ Shipped |
| [Onboarding](./Onboarding) | [v1.0](./PRD-onboarding-v1) | 🔵 In Progress |
| [Billing](./Billing) | [v1.0](./PRD-billing-v1) | 🟡 Draft |

## Templates
- [_Meta-Template](./_Meta-Template)
- [_PRD-Template](./_PRD-Template)
- [_Retro-Template](./_Retro-Template)

## Conventions
- [_Wiki-Conventions](./_Wiki-Conventions)
```

---

### 4b. Product Ticket (Story) Template

This is your BDD-style ticket, adapted for AI-agent consumption. Key adaptations from your original format:

- **Structured context block** so agents understand scope without ambiguity
- **Machine-parseable acceptance criteria** with explicit Given/When/Then
- **Agent instructions section** with constraints, references, and exit criteria

#### Scenario-to-Task/Bug Relationship

Scenarios have a **one-to-many** relationship with both dev tasks and bugs:

- **One scenario → many dev tasks:** A single scenario (e.g., S1) may require multiple dev tasks to implement (e.g., UI component, API endpoint, state management).
- **One scenario → many bugs:** A single scenario can trigger multiple bugs during testing (e.g., visual regression, data validation failure, edge case error).

When decomposing stories into dev tasks, agents should reference which scenario(s) each task addresses. When filing bugs, agents should reference the failing scenario to maintain traceability.

> **File:** `.github/ISSUE_TEMPLATE/story.yml`

```yaml
name: "🎯 Product Ticket (Story)"
description: "A user-facing feature with BDD acceptance criteria"
type: "story"
body:
  - type: markdown
    attributes:
      value: "## Product Ticket"

  - type: input
    id: prd
    attributes:
      label: "PRD"
      description: "Link to the versioned Wiki PRD page (agent can find the meta page from the PRD's traceability section)"
      placeholder: "../../wiki/PRD-Calendar-v1"
    validations:
      required: true

  - type: input
    id: meta-wiki
    attributes:
      label: "Feature Wiki"
      description: "Link to the meta wiki page for this feature area (canonical current state)"
      placeholder: "../../wiki/Calendar"
    validations:
      required: true

  - type: input
    id: user-story
    attributes:
      label: "User Story"
      description: "As a [persona], I want to [action] so that [outcome]."
      placeholder: "As a user, I want to swipe on calendar slots to create events with family members."
    validations:
      required: true

  - type: textarea
    id: context
    attributes:
      label: "Context"
      description: |
        Why does this matter? What's the user's pain point?
        Include enough background that an AI agent can understand
        the intent without asking follow-up questions.
      placeholder: |
        Creating calendar events with family is difficult because...
    validations:
      required: true

  - type: textarea
    id: definition-of-done
    attributes:
      label: "Definition of Done"
      description: "What must be true for this ticket to be considered complete?"
      placeholder: |
        - [ ] UI matches approved designs (link to Figma/comps)
        - [ ] All acceptance criteria scenarios pass
        - [ ] Unit tests cover all scenarios
        - [ ] No regressions in related features
        - [ ] Accessibility audit passes
    validations:
      required: true

  - type: textarea
    id: acceptance-criteria
    attributes:
      label: "Acceptance Criteria"
      description: |
        BDD scenarios using Given/When/Then.
        Be explicit — AI agents will use these as their source of truth.
        Number each scenario (S1, S2, etc.) for traceability.
      placeholder: |
        ### S1: [Descriptive scenario name]

        ```gherkin
        GIVEN [precondition]
          AND [additional precondition if needed]
        WHEN [action the user takes]
        THEN [expected outcome]
          AND [additional expected outcome]
        ```

        **Verification:** [How to confirm — e.g., visual check, API response, state change]

        ---

        ### S2: [Next scenario]

        ```gherkin
        GIVEN [precondition]
        WHEN [action]
        THEN [outcome]
        ```

        **Verification:** [How to confirm]
    validations:
      required: true

  - type: textarea
    id: agent-instructions
    attributes:
      label: "Agent Instructions"
      description: |
        Specific instructions for AI agents picking up this ticket.
        Include technical constraints, file paths, and references.
      placeholder: |
        **Tech Stack:** React Native, TypeScript, Zustand
        **Key Files:**
        - `src/components/Calendar/` — calendar grid components
        - `src/stores/eventStore.ts` — event state management

        **Constraints:**
        - Do NOT modify the shared CalendarDay component API
        - Gesture handling must use react-native-gesture-handler
        - All new components must have Storybook stories

        **Design Reference:** [Figma link]
        **API Contract:** [OpenAPI spec link or inline]

        **Edge Cases to Handle:**
        - What if no family members have availability?
        - What if the user's session expires mid-gesture?
        - What if timezone differs between family members?
    validations:
      required: false

  - type: textarea
    id: scenario-tracker
    attributes:
      label: "Scenario Acceptance Tracker"
      description: "Track pass/fail status of each scenario."
      placeholder: |
        | Scenario | Status | Date | Notes |
        |----------|--------|------|-------|
        | S1 | ⬜ | — | — |
        | S2 | ⬜ | — | — |
        | S3 | ⬜ | — | — |

        Status: ⬜ Untested · ✅ Pass · 🐛 Bug (link to bug ticket)
    validations:
      required: false

```

---

### 4c. Dev Task Template

Dev tasks are sub-issues under a product ticket. They should be small, atomic, and completable by an AI agent in a single session.

> **File:** `.github/ISSUE_TEMPLATE/task.yml`

```yaml
name: "🔧 Dev Task"
description: "An atomic development task — child of a product ticket"
type: "task"
body:
  - type: markdown
    attributes:
      value: "## Dev Task"

  - type: input
    id: parent
    attributes:
      label: "Parent Product Ticket"
      description: "Link to the parent story issue"
      placeholder: "#42"
    validations:
      required: true

  - type: input
    id: scenarios
    attributes:
      label: "Scenarios Addressed"
      description: "Which parent scenarios does this task implement?"
      placeholder: "S1, S2a"
    validations:
      required: true

  - type: textarea
    id: objective
    attributes:
      label: "Objective"
      description: |
        One clear sentence: what does this task produce?
        An AI agent should be able to read this and know exactly what to build.
      placeholder: "Implement the horizontal swipe gesture handler on the CalendarGrid component that highlights selected time slot bubbles."
    validations:
      required: true

  - type: textarea
    id: implementation-notes
    attributes:
      label: "Implementation Notes"
      description: |
        Specific technical guidance. Include file paths, function signatures,
        library references, and any architectural decisions already made.
      placeholder: |
        - Add `useSwipeSelection` hook in `src/hooks/`
        - Use `PanGestureHandler` from react-native-gesture-handler
        - Emit selected slot IDs to `eventStore.setSelectedSlots()`
        - Highlight logic: toggle `isSelected` on each `TimeSlotBubble`
        - Reference: existing `useSwipeNavigation` hook for gesture patterns
    validations:
      required: true

  - type: textarea
    id: done-criteria
    attributes:
      label: "Done When"
      description: "Concrete, verifiable checklist."
      placeholder: |
        - [ ] `useSwipeSelection` hook created and exported
        - [ ] Swipe gesture selects/deselects time slot bubbles
        - [ ] Selected bubbles receive `isSelected` visual state
        - [ ] Family member avatars highlight when their slot is selected
        - [ ] Cancel/Next buttons appear after first selection
        - [ ] Unit tests for hook: select, deselect, clear
        - [ ] Storybook story showing interaction
    validations:
      required: true

  - type: textarea
    id: test-guidance
    attributes:
      label: "Test Guidance"
      description: "How should this be tested? Include edge cases."
      placeholder: |
        **Unit:** Test `useSwipeSelection` with mock gesture events
        **Integration:** Verify slot selection propagates to eventStore
        **Edge cases:**
        - Rapid swipe across many slots
        - Swipe starting outside the grid area
        - Single tap (should not trigger swipe selection)
    validations:
      required: false
```

---

### 4d. Bug Ticket Template

Bugs are sub-issues under a product ticket. They trace directly to a failing scenario.

> **File:** `.github/ISSUE_TEMPLATE/bug.yml`

```yaml
name: "🐛 Bug Report"
description: "A defect — child of a product ticket, tied to a failing scenario"
type: "bug"
body:
  - type: markdown
    attributes:
      value: "## Bug Report"

  - type: input
    id: parent
    attributes:
      label: "Parent Product Ticket"
      description: "Link to the parent story issue"
      placeholder: "#42"
    validations:
      required: true

  - type: input
    id: scenario
    attributes:
      label: "Failing Scenario"
      description: "Which acceptance scenario is failing?"
      placeholder: "S2"
    validations:
      required: true

  - type: textarea
    id: environment
    attributes:
      label: "Environment"
      description: "Where was this observed?"
      placeholder: |
        - **Platform:** iOS 17.2 / iPhone 15 Pro simulator
        - **Browser/App:** N/A (native)
        - **Branch:** `feature/calendar-swipe`
        - **Commit:** `a1b2c3d`
    validations:
      required: true

  - type: textarea
    id: observed
    attributes:
      label: "Observed Behavior"
      description: |
        What actually happens? Include screenshots, screen recordings,
        console logs, or error messages. Loom links are great.
      placeholder: |
        Tapping "Next" does nothing. No navigation occurs.
        Console shows: `TypeError: undefined is not an object (evaluating 'navigation.navigate')`
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: "Expected Behavior"
      description: |
        What SHOULD happen? Copy the relevant scenario from the parent ticket
        so the agent has the full spec inline.
      placeholder: |
        Per parent ticket S2:

        ```gherkin
        GIVEN user is on the family calendar
          AND user has selected time slots (per S1)
        WHEN user taps "Next"
        THEN navigate to "Event Details" screen
          AND pre-fill: invitees, start time, end time, duration, date
        ```
    validations:
      required: true

  - type: textarea
    id: repro-steps
    attributes:
      label: "Reproduction Steps"
      description: "Numbered steps an AI agent can follow to reproduce."
      placeholder: |
        1. Open app on family calendar view
        2. Swipe across 2+ available time slots (bubbles highlight)
        3. Tap the "Next" button at bottom of screen
        4. Observe: nothing happens (expected: navigate to Event Details)
    validations:
      required: true

  - type: textarea
    id: root-cause
    attributes:
      label: "Suspected Root Cause (optional)"
      description: "If you have a hypothesis, share it."
      placeholder: |
        `CalendarScreen` is missing the `navigation` prop because it was
        converted to a function component but not wrapped in
        `withNavigation()` or given `useNavigation()`.
    validations:
      required: false

  - type: textarea
    id: fix-guidance
    attributes:
      label: "Fix Guidance for Agent"
      description: "Point the agent in the right direction."
      placeholder: |
        **Key Files:**
        - `src/screens/CalendarScreen.tsx` — missing navigation
        - `src/navigation/CalendarStack.tsx` — screen registration

        **Likely Fix:**
        - Add `const navigation = useNavigation()` to CalendarScreen
        - Wire `onNext` handler to `navigation.navigate('EventDetails', { ... })`

        **Regression Risk:** Check that back-navigation from EventDetails still works
    validations:
      required: false
```

---

---

## 5. Versioned Epics — How It Works

Each epic is a **major area of your app** that evolves over multiple versions. Each version is a discrete, shippable milestone.

### Naming Convention

```
[epic-name]-v[Major].[Minor]     (lower-kebab-case, always include minor)
```

- **Major:** Breaking scope change or new capability area
- **Minor:** Incremental additions within the same scope
- **Format:** Always lower-kebab-case. Always include the minor version (v1.0, not v1).
- **Conversion:** PRD titles can be human-friendly. The decomposition skill handles conversion to lower-kebab-case milestone names.

### Example: Auth Epic

```
Milestone: "auth-v1.0"    → Login + registration (email/password)
Milestone: "auth-v1.1"    → Password reset + remember me
Milestone: "auth-v2.0"    → OAuth (Google, Apple) + MFA
Milestone: "auth-v2.1"    → Role-based access control (RBAC)
```

### How Versioning Maps to GitHub

| Concern | Implementation |
|---|---|
| Epic identity | Label `epic:auth` on ALL auth tickets, all versions |
| Canonical feature state | Meta wiki page `Auth` — updated once per shipped version |
| Version requirements | Versioned PRD `PRD-auth-v1` — one per major version |
| Version boundary | Milestone `auth-v1.0` — has due date + description with PRD link |
| Roadmap ordering | Project custom field `Epic` + milestone due dates |
| Cross-version query | Filter by label `epic:auth` to see full history |
| Single-version query | Filter by milestone `auth-v1.0` for that release |
| Full feature history | Meta wiki page → Version History table → links all PRDs |

### Promoting Work Across Versions

When a ticket is deferred:
1. Remove it from the current milestone
2. Add it to the next version's milestone
3. Add a comment: `Deferred from auth-v1.0 → auth-v1.1. Reason: [blocked by X / out of scope for launch]`

---

## 6. Sprint Workflow

### Work Cadence

> **Note:** Time-based sprint cadence (e.g., 2-week cycles) is a human construct. For AI-agent-only workflows, work is better organized around **milestone completion** rather than fixed time intervals. The cadence below is optional guidance for teams with human participants.

| Phase | Activity |
|---|---|
| **Planning** | Pull from backlog, groom tickets, assign to milestone |
| **Execution** | Agents pick up `agent:ready` tickets |
| **Review** | PRs reviewed, scenarios validated |
| **Retrospective** | Wiki retro page created at milestone completion |

### Sprint Planning Checklist

```markdown
- [ ] Review velocity from last sprint
- [ ] Groom top-priority backlog items
- [ ] Ensure all stories have acceptance criteria
- [ ] Break stories into dev tasks (max size:m per task)
- [ ] Verify all tasks have agent instructions if agent-assignable
- [ ] Assign sprint iteration field on Project
- [ ] Set sprint goal
```

### Agent Workflow

```
1. Agent checks "Agent Queue" view for `agent:ready` tickets
2. Agent reads full context chain:
   a. Meta wiki page (e.g., Auth) → current state, scope matrix, decisions
   b. Versioned PRD (e.g., PRD-auth-v2) → requirements for this version
   c. Product ticket → user story, BDD scenarios, agent instructions
   d. Dev task → specific implementation scope
3. Agent creates branch: `[type]/[issue-number]-[short-description]`
   e.g., `feat/42-calendar-swipe-gesture`
4. Agent implements against "Done When" checklist
5. Agent runs tests, commits, opens PR referencing the issue
6. Agent moves ticket to `agent:review`
7. PR review cycle (see Section 6b: PR Review Workflow)
8. Sub-agent updates Scenario Acceptance Tracker on parent story
9. Agent appends lessons learned as a comment on the parent story before closing
10. If bug found → file bug sub-issue, link to failing scenario
```

**Lessons (step 9):** Before closing a story, the agent appends a structured comment summarizing what was learned — implementation surprises, calibration data (estimated vs. actual tokens), patterns discovered, or pitfalls encountered. These lessons accumulate at the story level and feed into the milestone retrospective.

### 6b. PR Review Workflow

PRs are reviewed by humans on github.com, not in the terminal. The agent facilitates this loop:

```
1. Agent pushes branch, creates PR on GitHub referencing the issue
2. Agent spawns a polling sub-agent (cheapest model, e.g., Haiku) that watches for PR review activity
3. Human reviews on github.com — adds inline comments, requests changes
4. Polling sub-agent detects review activity via GitHub API, pulls comments
5. Agent addresses feedback, pushes updated commits
6. Repeat steps 2-5 until CODEOWNERS approval received
7. Agent merges PR
```

**Key design decisions:**
- **GitHub.com is the review surface** — humans review diffs and leave inline comments on github.com, not in the terminal
- **Polling, not push** — GitHub cannot push back to a local Claude session; the sub-agent polls the GitHub API at regular intervals (e.g., every 60 seconds) for changes
- **Cheapest model for polling** — the polling sub-agent only needs to detect changes, not reason about code
- **CODEOWNERS gates merge** — the PR cannot merge until the required reviewers (per CODEOWNERS) approve
- **Do NOT use Claude GitHub Actions** for this workflow — they are a separate system and not suited for this loop
- **Leverage superpowers skills** — use the `requesting-code-review` and `receiving-code-review` skills for structuring the review interaction

### 6c. Artifact Validation (Lint Gate)

Before moving on after creating or updating any artifact (issues, PRDs, templates), agents must run a **synchronous, blocking, client-side validation** step. This is not GitHub Actions (too slow/async) — it runs locally.

**What gets validated:**
- Issue bodies have all required fields per their template
- PRD wiki pages include mandatory sections (Background, Functional Requirements, Traceability)
- Milestone descriptions include PRD link
- Labels follow the namespace taxonomy

**Behavior:**
- Validation runs immediately after artifact creation/update
- If validation fails, the agent must fix the issue before proceeding
- The agent loops until a clean validation pass is achieved
- This prevents drift and noise in artifacts caused by variance in model instruction-following

### 6d. Ownership via CODEOWNERS

Agents should consult the repository's `CODEOWNERS` file to determine ownership. CODEOWNERS designates who owns which parts of the codebase using file path patterns.

**When to consult CODEOWNERS:**
- Assigning PR reviewers — CODEOWNERS approvals gate merge
- Routing open questions or risks to the right human
- Determining who should be notified about architectural changes

**Owners are GitHub users** (humans by default, though robot accounts can also be designated).

---

## 7. Backlog Management

### Backlog Grooming (Weekly, 30 min)

The backlog is a **table view** in your Project filtered to items with no Sprint assigned.

**Grooming checklist per item:**
- Does it have a clear user story?
- Does it link to its Wiki PRD? (via `PRD` field)
- Are acceptance criteria written in Given/When/Then?
- Is it sized? (Use `size:` labels)
- Is it prioritized? (Use `priority:` labels)
- Does it belong to an epic + milestone?
- If agent-assignable, does it have agent instructions?

### Backlog Tiers

Use a custom **"Backlog Tier"** single-select field:

| Tier | Meaning |
|---|---|
| **Now** | Ready for next sprint — fully groomed |
| **Next** | Targeted for 1-2 sprints out — needs grooming |
| **Later** | On the roadmap but not yet scoped |
| **Icebox** | Ideas parked — revisit quarterly |

---

## 8. Architecture Decision Records (ADRs)

ADRs capture cross-cutting architectural decisions in a lightweight, sequentially numbered format. They are **not scoped to a single PRD** — they exist as a shared ledger that any PRD can reference.

### Storage

ADRs live in **GitHub Discussions** (category: Decisions or ADR). This keeps them searchable, commentable, and separate from the issue/PR workflow.

### Format (Nygaard)

Use the Nygaard ADR format — lightweight and sufficient:

```markdown
# ADR-NNN: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-NNN]

## Context
[What is the issue that we're seeing that is motivating this decision or change?]

## Decision
[What is the change that we're proposing and/or doing?]

## Consequences
[What becomes easier or more difficult to do because of this change?]
```

### Numbering

Sequential: `ADR-001`, `ADR-002`, `ADR-003`, etc. Numbers are never reused.

### Referencing ADRs

- PRDs link to relevant ADRs in their "Related ADRs" section
- A PRD may **introduce** a new ADR during development
- ADRs are a reverse index — you point to the ones you care about from wherever you are

### When to Create an ADR

- Technology or framework selection (e.g., "Use PostgreSQL over MongoDB")
- Architectural patterns (e.g., "Adopt event sourcing for audit trail")
- Cross-cutting concerns (e.g., "All errors use structured logging")
- Decisions that would otherwise be re-debated by future agents

---

## 9. Putting It All Together — End-to-End Example

### Phase 1: PRD + Meta Wiki

If this is the **first version** of the epic, create both:

1. **Meta wiki page** `Calendar`:
   - "What This Feature Does Today" → "N/A — new feature area"
   - Architecture Summary → planned stack/patterns
   - Version History → one row: `calendar-v1.0 | 🔵 In Progress`

2. **Versioned PRD** `PRD-calendar-v1`:
   - Contains: background, objectives, scope matrix, functional requirements
   - Traceability footer links to meta page `Calendar`, Milestone `calendar-v1.0`, and all product tickets

3. **Milestone** `calendar-v1.0`:
   - Description opens with: `📋 PRD: [calendar-v1.0 Brief](../../wiki/PRD-calendar-v1)`
   - Due date set

If this is a **subsequent version** (e.g., calendar-v2.0), you only create the new PRD and update the existing meta page's Version History table.

### Phase 2: Product Tickets

From the PRD, you break out stories:

**Issue #10**: `🎯 Swipe to create calendar event`
- PRD: `../../wiki/PRD-calendar-v1`
- Issue Type: `story` · Labels: `epic:calendar`, `priority:high`, `size:m`, `agent:ready`
- Milestone: `calendar-v1.0`
- Contains: User story, BDD scenarios (S1, S2, S2a), agent instructions
- Sub-issues link here (see Phase 3)

**Issue #11**: `🎯 Event details pre-fill from selection`
- PRD: `../../wiki/PRD-calendar-v1`
- Issue Type: `story` · Labels: `epic:calendar`, `priority:high`, `size:s`
- Milestone: `calendar-v1.0`

### Phase 3: Dev Tasks (sub-issues of #10)

**Issue #10.1**: `🔧 Implement swipe gesture handler`
- Issue Type: `task` · Labels: `epic:calendar`, `size:s`, `agent:ready`
- Parent: #10 (sub-issue)
- Scenarios: S1

**Issue #10.2**: `🔧 Wire "Next" button navigation to Event Details`
- Issue Type: `task` · Labels: `epic:calendar`, `size:xs`, `agent:ready`
- Parent: #10 (sub-issue)
- Scenarios: S2, S2a

**Issue #10.3**: `🔧 Implement bubble-tap navigation shortcut`
- Issue Type: `task` · Labels: `epic:calendar`, `size:xs`, `agent:ready`
- Parent: #10 (sub-issue)
- Scenarios: S2a

### Phase 4: Bug Surfaces

During review, S2 fails:

**Issue #10.4**: `🐛 Tapping "Next" does not navigate to Event Details`
- Issue Type: `bug` · Labels: `epic:calendar`, `priority:critical`
- Parent: #10 (sub-issue)
- Failing scenario: S2
- Contains: repro steps, observed vs. expected, fix guidance

On the parent ticket (#10), update the tracker:

| Scenario | Status | Date | Notes |
|----------|--------|------|-------|
| S1 | ✅ | 02/19/26 | — |
| S2 | 🐛 | 02/19/26 | #10.4 |
| S2a | ✅ | 02/19/26 | — |

### Phase 5: Milestone Completion + Retro + Ship

**When the milestone closes (epic version ships):**

1. **Gather lessons** — all story-level lesson comments have been written during execution (agent workflow step 9)

2. **Create retrospective wiki page** (`Retro-calendar-v1.0`):
   - Accumulates lessons from all product tickets in the milestone
   - Reviews estimated vs. actual token consumption for calibration
   - Captures agent performance notes, systemic issues, and action items
   - This is a wiki page, not a GitHub issue (see wiki sidebar for placement)

3. **Update the meta wiki page** `Calendar` (~10 min):
   - "What This Feature Does Today" → describe what's now live in production
   - Scope Matrix → update to reflect the new production reality
   - Version History → mark `calendar-v1.0` as ✅ Shipped
   - Key Decisions → add any architectural decisions made during this version
   - Known Limitations → note anything deferred or knowingly imperfect

---

## 10. Quick Reference: GitHub CLI Shortcuts

For rapid ticket creation from the terminal (handy for Claude Code workflows):

```bash
# Clone the wiki repo (wiki is a separate git repo)
git clone https://github.com/{owner}/{repo}.wiki.git
cd {repo}.wiki

# Create a meta wiki page from template
cp _Meta-Template.md Calendar.md
# Edit Calendar.md with your content

# Create a versioned PRD page from template
cp _PRD-Template.md PRD-calendar-v1.md
# Edit PRD-calendar-v1.md with your content

# Push both
git add Calendar.md PRD-calendar-v1.md
git commit -m "Add Calendar meta page + v1 PRD"
git push

# Create a milestone with PRD link in description
gh api repos/{owner}/{repo}/milestones \
  --method POST \
  -f title="calendar-v1.0" \
  -f due_on="2026-03-31T00:00:00Z" \
  -f description="📋 PRD: [calendar-v1.0 Brief](../../wiki/PRD-calendar-v1)

Swipe-based calendar event creation with family availability."

# Create a product ticket (use Issue Types, not type: labels)
gh issue create \
  --title "🎯 Swipe to create calendar event" \
  --label "epic:calendar,priority:high,size:m,agent:ready" \
  --milestone "calendar-v1.0" \
  --body-file ./tickets/calendar-swipe.md

# Create a dev task as sub-issue
gh issue create \
  --title "🔧 Implement swipe gesture handler" \
  --label "epic:calendar,size:s,agent:ready" \
  --milestone "calendar-v1.0" \
  --body "Parent: #10 | Scenarios: S1"

# Add sub-issue relationship (requires GitHub CLI extension or API)
gh api repos/{owner}/{repo}/issues/10/sub_issues \
  --method POST -f sub_issue_id=10.1

# Create a milestone
gh api repos/{owner}/{repo}/milestones \
  --method POST \
  -f title="auth-v1.0" \
  -f due_on="2026-03-31T00:00:00Z" \
  -f description="Login, registration, email/password auth"

# Sprint planning: assign iteration
# (Iterations are managed via GitHub Projects UI or GraphQL API)
```

---

## 11. What This System Intentionally Omits

Staying lightweight means knowing what NOT to do:

- **No separate tracker for sprints** — GitHub Projects' iteration field IS your sprint
- **No Gantt charts** — the Roadmap board view + milestone due dates are enough
- **No story points debates** — use token-based `size:` labels; track estimated vs. actual token consumption for calibration over time
- **No JIRA-style workflows with 8 statuses** — keep it to: `Todo → In Progress → In Review → Done`
- **No PRDs crammed into Issues** — PRDs are living reference docs; they belong in the Wiki with narrative structure, scope matrices, and TOCs. Bi-directional linking bridges the gap.
- **No daily standups** — for AI-agent teams, the Agent Queue view IS your standup
