# Gherkin Quick Reference for PM Issues

## Structure

```gherkin
Feature: {Name matching the issue title}

  Background:
    Given {shared precondition across all scenarios}

  Scenario: {Descriptive name — happy path first}
    Given {precondition / system state}
    And {additional precondition if needed}
    When {user action or system event}
    And {additional action if needed}
    Then {expected observable outcome}
    And {additional assertion if needed}

  Scenario: {Edge case or error path}
    Given {precondition}
    When {action that triggers edge case}
    Then {expected error handling behavior}
```

## Rules

1. **Each scenario must be independently testable** — no shared state between scenarios
2. **Given = preconditions** — system state before the action
3. **When = action** — exactly one user action or system event per scenario
4. **Then = assertions** — observable outcomes that can be verified
5. **Background** — shared preconditions, used sparingly
6. **Use And/But** — for multiple steps within a section

## Writing Good Scenarios

**Do:**
- Write from the user's perspective, not implementation details
- Include both happy path and error scenarios
- Make assertions specific and measurable
- Keep scenarios focused — one behavior per scenario

**Don't:**
- Reference code, functions, or implementation details
- Write "Then the database is updated" — write "Then the user sees confirmation"
- Combine multiple behaviors in one scenario
- Write scenarios that can't fail (tautologies)

## Size Guidance

| Issue Size | Scenarios |
|---|---|
| `size:xs` | ~1-10K tokens, 1-2 scenarios |
| `size:s` | ~10-50K tokens, 2-3 scenarios |
| `size:m` | ~50-200K tokens, 3-5 scenarios |
| `size:l` | ~200-500K tokens, 5-8 scenarios (consider splitting) |
| `size:xl` | 500K+ tokens, 8+ scenarios (must split) |
