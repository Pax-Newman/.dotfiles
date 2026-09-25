# NNN — Short descriptive title

**Priority:** Low | Medium | High | Critical
**Status:** Open
**Area:** affected routes / modules / components
<!-- **Jira:** [KEY-123](https://site.atlassian.net/browse/KEY-123)  (added on export/import) -->
<!-- **Jira status:** <status name exactly as Jira reports it>  (added on sync) -->
<!-- **Jira synced:** YYYY-MM-DD  (added on sync) -->

## Summary

Two or three sentences: what is wrong, who or what is affected, and why it matters.

## Description

Explain the mechanism in plain prose for someone new to the codebase.

![What this diagram shows](./diagram_01_topic.svg)

**`path/to/file.py:120-128`**

```python
# only the lines that prove the point
```

## How to Reproduce

**Preconditions:** data, config, or identity needed.

1. Step one
2. Step two

**Expected:** what should happen.
**Actual:** what happens.

Manual API requests: `reproduction.http`.

### Automated check

```bash
<exact command to run check.<ext>>
```

Current output (fails while the bug is present):

```
<pasted failing output>
```

<!-- If no check is feasible, replace the above with a sentence explaining why. -->

## Suggested Fix

High-level direction, not a patch.

## Acceptance Criteria

- `check.<ext>` passes.
- Observable, testable statement of correct behaviour.

## Related

- Other bug numbers or Jira keys, with one line on how they relate.

<!-- Added on close:
## Resolution

**Closed:** YYYY-MM-DD
**Fixed in:** commit / PR
**Fix:** one or two sentences.
**Check promoted to test suite:** yes (path) | no — reason

```
<passing check output>
```
-->
