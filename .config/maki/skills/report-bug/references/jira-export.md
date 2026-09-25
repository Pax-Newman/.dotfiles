# Export a bug to Jira (`export bug NNN`)

Requires `jira-common.md`. You write the ticket text; `jira.py export` does all API work.

1. Locate the bug directory in `bugs/open/` or `bugs/closed/`. If `note.md` has a `**Jira:**` line, ask: update the existing ticket or create a new one?
2. Run `python3 <skill>/scripts/bug.py render NNN` so every `.svg` is current.
3. Build a **standalone** ticket in `/tmp/bugexport-NNN/`:
   - Copy each diagram `.svg` there under a neutral name (drop the `NN_` numbering if it reads oddly; keep the topic, e.g. `diagram_request_flow.svg`). Copy the check file as `check_<topic>.<ext>`.
   - Write `ticket.md`. It must contain no mention of this skill, `bugs/`, directory or file names from the bug directory, local bug numbers, or `note.md`. The script lints for these and refuses (exit 3) if it finds any.
     - **First line:** `# <note title without the "NNN — " prefix>` (becomes the Summary field).
     - **Sections:** Summary, Description, How to Reproduce, Suggested Fix, Acceptance Criteria.
     - Code excerpts: fenced code with a language. Keep `file:line` headers (source paths are fine; bug-directory paths are not).
     - Diagrams: `![alt text](./diagram_request_flow.svg)` on its own line where it appears in the note. The script uploads it and embeds it inline; Jira renders SVGs, including animated ones.
     - `.http` requests → `curl` commands in How to Reproduce (see [Converting .http to curl](#converting-http-to-curl)).
     - Automated check: "Attached `check_<topic>.py` fails while the bug is present and passes once fixed. Run: `<command>`", with the command rewritten for the attached file name.
     - Acceptance criterion "`check.<ext>` passes" → "The attached `check_<topic>.py` passes."
     - Drop the pasted local check output unless it is useful evidence. If you keep it, strip local paths.
     - Omit Status, Resolution, the `**Jira:**` line, and the Related section (use `--link` instead).
4. Validate: `python3 <skill>/scripts/jira.py export /tmp/bugexport-NNN/ticket.md --attach /tmp/bugexport-NNN/check_<topic>.py --dry-run`. Fix any lint errors or missing files.
5. **Preview.** Show the user `ticket.md` and the attachment list. Wait for confirmation.
6. Export:
   ```bash
   python3 <skill>/scripts/jira.py export /tmp/bugexport-NNN/ticket.md \
     [--project KEY | --update KEY-123] --priority <Jira priority> \
     --attach /tmp/bugexport-NNN/check_<topic>.py \
     [--link KEY-9 ...] --note bugs/open/NNN-name/note.md
   ```
   - Map Low/Medium/High/Critical to the site's priority names. On exit code 2, the error lists the valid names or issue types; ask the user.
   - Without `--project`, `JIRA_PROJECT_KEY` is used. If neither is set, ask for the key and suggest exporting `JIRA_PROJECT_KEY`.
   - `--link` only for related bugs that already have Jira keys ("Relates" links).
   - `--note` writes `**Jira:** [KEY](url)` into the note.
   - If an image cannot be embedded, the script leaves "See attached …" text and warns; tell the user.
7. Delete `/tmp/bugexport-NNN/`.

## Converting .http to curl

- One `curl` per request, in file order, preceded by the request's `###` title as a sentence.
- Resolve `@VAR=value` file variables into the command. Keep environment-specific hosts as `$BASE_URL`, with a line explaining what it is.
- Replace tokens/secrets with placeholders (`$TOKEN`). Turn `< {% ... %}` script blocks into a one-line instruction for obtaining the value (e.g. "`TOKEN=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)`").
- Carry over headers (`-H`), method (`-X`), and body (`--data '...'`). Include `# Expected/Actual` comments as prose after the command.
