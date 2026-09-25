# Resolve (close) a bug

1. **Verify.** Run the check. It must pass; if it fails, stop and tell the user. Also run the project's full test suite. If anything fails, run the suite again without the fix (e.g. `git stash`) to separate failures that already existed from regressions the fix introduced. Report both.
2. **Record.** Append a `## Resolution` section to `note.md` (template in `assets/note.md`): date, fixing commit/PR, short description of the fix, passing check output.
3. **Promotion decision.** Ask: does this check guard against a regression that could plausibly recur and is not already covered by the suite?
   - Yes → offer to move a cleaned-up version into the project's test suite following its conventions (no bug numbers in names, reuse existing fixtures). Only do it with the user's agreement.
   - No → leave it in the bug directory.
   - Record the decision and the reason in Resolution. Never add to the test suite by default.
4. **Jira.** If the note has a `**Jira:**` link, ask whether to do either of the following. Default: do nothing to Jira.
   - Add a comment (fix summary + commit/PR; no local paths or skill references): write it to a temp markdown file, then `python3 <skill>/scripts/jira.py comment KEY --file /tmp/comment.md`.
   - Transition the ticket: `python3 <skill>/scripts/jira.py transition KEY` lists the options; let the user pick, then `... transition KEY --to "<name>"`.
5. **Close.** `python3 <skill>/scripts/bug.py close NNN`. It refuses if there is no `## Resolution` section. It sets `**Status:** Closed`, moves the directory to `bugs/closed/` (`git mv` when tracked), and rewrites `bugs/open/...` paths inside it.
