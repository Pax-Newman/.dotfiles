# Import a Jira ticket (`import KEY-123`)

Requires `jira-common.md`. **Never write to Jira during import.**

1. Run `python3 <skill>/scripts/jira.py import KEY-123`. It prints the issue as markdown (type, status, priority, labels, description, links, comments) and downloads attachments to `$TMPDIR/bugimport-KEY-123/` (`--no-download` to skip; larger than 20 MB are skipped).
2. If the output has an **Existing local bug** line, offer to refresh that bug directory instead of creating a new one.
3. **Investigate:**
   - Read the description and comments for context. View downloaded images and logs. Do not keep downloads in the repo unless they are needed as evidence.
   - Map every claim to code and collect `file:line` evidence. Try to reproduce the bug.
   - Ask the user about gaps: missing steps, environment, expected behaviour, priority disagreements.
4. Follow `create-report.md` from step 2 (scaffolding onward), with these differences:
   - Pass `--jira KEY-123` to `bug.py new` so the note gets the `**Jira:**` line.
   - Title: use the ticket summary (rephrase only if it is misleading).
   - Priority: map it from Jira, and flag it if the investigation suggests otherwise.
5. If the investigation contradicts the ticket (cannot reproduce, different root cause, already fixed), say so plainly in the note's Summary and tell the user.
