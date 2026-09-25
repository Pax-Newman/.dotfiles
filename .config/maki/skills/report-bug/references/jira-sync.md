# Sync local bugs with Jira

Requires `jira-common.md`. The script is **read-only**: it reports, you decide and edit. Never write to Jira during a sync without the user's go-ahead.

1. Run `python3 <skill>/scripts/jira.py sync [NNN ...]`. With no numbers it covers every open and closed bug that has a `**Jira:**` line. Per bug it prints:
   - local state and Jira key/URL
   - Jira status name, status category, resolution, and last-updated date, exactly as Jira reports them
   - local vs Jira priority
   - the Jira summary, if it differs from the local title
   - comment count (and how many are on/after `**Jira synced:**`), plus the first 200 characters of the latest comment (`--chars N` to change)
   - `today: YYYY-MM-DD` at the end
2. **Interpret each bug.** Status names are project-specific, so judge from the name, category, and resolution together. Local status is only ever `Open` or `Closed`.

   | What you see | Do |
   |---|---|
   | Jira looks finished, local open | Tell the user. If they agree it is fixed, follow `resolve.md` (the check must pass; if it still fails, report that instead of closing). |
   | Jira looks active or reopened, local closed | Tell the user. If they agree, run `python3 <skill>/scripts/bug.py reopen NNN` and add a line under Resolution saying why it was reopened. Alternatively offer to comment on / transition the ticket (see `resolve.md` step 4). |
   | Priority or summary differs | Report it and ask whether to update the note. Do not change it silently. |
   | New comments | Read the snippet. If it may matter (new repro info, a fix, a disagreement), fetch the full thread with `jira.py import KEY --no-download` and summarise what is relevant to the user. Update the note only with the user's agreement. |
   | Not found / not accessible | Report it; the key may be wrong, moved, or restricted. |
   | Nothing differs | No action. |

3. **Record the sync.** For every bug that was successfully fetched, set these header lines under `**Jira:**` in `note.md` (add them if missing, replacing the commented template lines):
   ```
   **Jira status:** <status name exactly as reported>
   **Jira synced:** <today from the script output>
   ```
4. **Report** a short summary to the user: which bugs changed, what you did, and what needs their decision.
