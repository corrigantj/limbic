# PR Body Template

Used by pm-implementer agents when creating pull requests. Replace placeholders.

---

Resolves #{issue_number}
**Target branch:** `{target_branch}`

## Summary

{1-3 sentences describing what was implemented and why.}

## Acceptance Criteria Verification

| Scenario | Status |
|---|---|
| {scenario name from issue} | {PASS/FAIL} |
| {scenario name from issue} | {PASS/FAIL} |

## Test Results

```
{paste test output here}
```

## Definition of Done

- [ ] All scenarios passing
- [ ] Tests written for each scenario
- [ ] No regressions in existing tests
- [ ] Self-reviewed diff before submitting

## Changes

- `{path/to/file1}` — {what changed}
- `{path/to/file2}` — {what changed}

## Lessons Learned

- **Estimated size:** {size_label}
- **Actual tokens:** ~{N}K
- **Surprises:** {what differed from expectations}
- **Patterns:** {reusable insights}
- **Pitfalls:** {what to avoid next time}
