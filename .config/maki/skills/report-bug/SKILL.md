---
name: report-bug
description: Use when the user wants to report/file/log/write up a bug, close or resolve bug NNN, export a bug to Jira, import a Jira ticket as a local bug report, or sync local bugs with Jira.
---

# Report Bug

Bugs live as self-contained directories in the repo root:

```
bugs/
  <test guard>                 # keeps bug checks out of normal test runs
  open/
    001-short-kebab-name/
      note.md                  # always
      diagram_01_<topic>.d2    # optional, 0..N, each with a rendered .svg beside it
      diagram_01_<topic>.svg
      reproduction.http        # optional, API-visible bugs, for humans
      check.<ext>              # optional-but-expected, one file, may hold several checks
  closed/
    ...
```

## Conventions

- **Numbering.** Next number = highest `NNN` across `bugs/open/` and `bugs/closed/` + 1, zero-padded to 3 digits, starting at `001`. Never reuse numbers. `bug.py new` does this.
- **Directory name.** `NNN-short-kebab-name`: a short, high-level description of the bug (`003-assignment-skips-ownership-check`).
- **Diagrams.** `diagram_NN_<snake_topic>.d2` with a rendered `.svg` beside it, numbered in note order.
- **Checks** fail while the bug exists and pass once it is fixed. They run only when targeted.
- **Templates** are in `assets/`: `note.md`, `diagram.d2`, `reproduction.http`, `check_pytest.py`, `check_standalone.py`, `bugs-conftest.py`.

## Scripts

Use these instead of doing the steps by hand. Python 3, standard library only; run from anywhere in the repo. `<skill>` is the directory containing this file.

| Command | Does |
|---|---|
| `python3 <skill>/scripts/bug.py init` | Create `bugs/open`, `bugs/closed`; detect test tools; install the pytest guard; print TODOs for other tools |
| `python3 <skill>/scripts/bug.py new "<title>" --priority P [--check pytest\|standalone] [--http] [--area A] [--jira KEY]` | Next number, directory, `note.md` header, check/.http templates with run commands filled in |
| `python3 <skill>/scripts/bug.py list [--all]` | Number, state, priority, title, Jira key |
| `python3 <skill>/scripts/bug.py render [NNN ...] [--force]` | Render each `.d2` to `.svg` with its `# render:` flags (skips fresh ones) |
| `python3 <skill>/scripts/bug.py close NNN` | Requires a `## Resolution` section; sets Status, moves to `closed/`, rewrites paths |
| `python3 <skill>/scripts/bug.py reopen NNN` | Sets Status Open, moves back to `open/`, rewrites paths |
| `python3 <skill>/scripts/jira.py ...` | `check`, `export`, `import`, `comment`, `transition`, `sync`; see `references/jira-common.md` |

Each prints a short summary; exit code non-zero means stop and read the error.

## Router

Load only the reference files the task needs.

| Task | Read |
|---|---|
| `bugs/` does not exist yet | `references/init.md`, then continue with the task |
| Report / file / log a bug | `references/create-report.md` (it routes to `reproduction.md`) |
| Write or fix a reproduction or check, set up the test guard | `references/reproduction.md` |
| Close / resolve bug NNN | `references/resolve.md` |
| Export bug NNN to Jira | `references/jira-common.md`, then `references/jira-export.md` |
| Import a Jira ticket | `references/jira-common.md`, then `references/jira-import.md` |
| Sync local bugs with Jira | `references/jira-common.md`, then `references/jira-sync.md` |
