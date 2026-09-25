# Create a bug report

If `bugs/` does not exist, run `init.md` first.

1. **Investigate.** Understand the bug before writing. Find the code responsible and collect `file:line` evidence. Try to trigger it. Ask the user about anything you cannot determine (expected behaviour, environment, data preconditions).
2. **Scaffold.** Pick the title, priority, and which artefacts you need, then run:
   ```bash
   python3 <skill>/scripts/bug.py new "<short title>" --priority High --check pytest [--http] [--area "<routes/modules>"] [--slug <kebab-name>]
   ```
   `--check pytest|standalone` copies the check template with the run command filled in (default: no check; write your own for other frameworks). It prints the new directory. Never create bug directories or number them by hand.
3. **Write `note.md`**: replace the template placeholders in the scaffolded file. See [Writing the note](#writing-the-note).
4. **Diagrams**, only if they help explain the bug. See [Diagrams](#diagrams).
5. **Reproduction.** Follow `reproduction.md`: written steps, optional `reproduction.http`, `check.<ext>` run and seen failing, with the output pasted into the note.
6. **Self-review** before reporting back:
   - The Summary alone lets a newcomer grasp the bug.
   - Every `.d2` has an up-to-date `.svg` and is linked from the note.
   - The check was run and fails for the reason described (not an import error or missing fixture).
   - The check observes the bug where users or callers would see it, not only through internals.
   - Each acceptance criterion is objectively testable.
   - No padding: every paragraph, excerpt, and diagram earns its place.

## Writing the note

- Lead with the Summary: what is wrong, who/what is affected, impact. 2–3 sentences.
- Write for someone new to the codebase. Define non-obvious terms once.
- Description explains the mechanism. Support prose with short code excerpts headed by `file:line`. Keep only the lines that prove the point.
- Priority: `Low | Medium | High | Critical`, judged by impact × likelihood. Ask the user if unsure.
- Suggested Fix is direction, not a patch.
- Acceptance Criteria always include "`check.<ext>` passes" when a check exists.
- Related links other bugs by number (`see 004`), or Jira keys if known.

## Diagrams

- Use the `d2lang` skill for syntax if available. Template: `assets/diagram.d2`.
- If the diagram needs render flags (e.g. animation), put them on the first line so every re-render and the Jira export reproduce them:
  ```
  # render: --animate-interval=1500
  ```
- Render after every edit with `python3 <skill>/scripts/bug.py render NNN`. It applies the `# render:` flags and skips diagrams whose `.svg` is already newer.
- Embed in the note where it helps the prose: `![Request flow: auth passes, ownership never checked](./diagram_01_request_flow.svg)`. Alt text should describe what the diagram shows.
- Good diagram subjects: the faulty control/data flow with the failure point highlighted, expected vs actual paths, state transitions.
