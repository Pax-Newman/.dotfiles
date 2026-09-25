# Jira: credentials and the `jira.py` script

Load this before any Jira read or write. All Jira access goes through `python3 <skill>/scripts/jira.py` (standard library only, Jira Cloud REST v3). Do not call the Jira API with curl or MCP tools directly.

## Credentials

Read from environment variables only:

| Variable | Purpose |
|---|---|
| `ATLASSIAN_SITE_NAME` | Site. If not a full URL, the base is `https://$ATLASSIAN_SITE_NAME.atlassian.net` |
| `ATLASSIAN_USER_EMAIL` | Basic-auth user |
| `ATLASSIAN_API_TOKEN` | Basic-auth token |
| `JIRA_PROJECT_KEY` | Optional default project for export |

Rules:
- Never print, echo, log, or write these values to files, notes, or memory. The script reads them itself and never prints them.
- Never ask the user to paste a secret into chat. If something is missing, ask them to set it.
- The Jira ticket key and URL are **not** secrets and are recorded in `note.md`.

## Preflight

`python3 <skill>/scripts/jira.py check` → `ok <site> as <name>`. Every other subcommand also runs the preflight itself. On any error, tell the user which step failed and ask how to proceed.

## Subcommands

| Command | Does |
|---|---|
| `check` | Verify credentials |
| `export TICKET.md [--project P \| --update KEY] [--priority NAME] [--attach F]... [--link KEY]... [--note PATH] [--dry-run]` | Markdown → ADF, create/update, upload + embed images, links, write `**Jira:**` line (see `jira-export.md`) |
| `import KEY [--out DIR] [--no-download]` | Print the issue as markdown (fields, description, links, comments); download attachments; report any local bug already linked |
| `comment KEY --file F` | Add a markdown comment |
| `transition KEY [--to NAME]` | List transitions, or apply one by name, target status, or id |
| `sync [NNN ...] [--chars N]` | Read-only report of Jira status, priority, summary, and comments for linked local bugs (see `jira-sync.md`) |

Exit codes: `0` ok, `1` error, `2` a value needs a decision (unknown priority, issue type, project, or transition; the message lists the choices, so ask the user), `3` local references found in the text.

Supported markdown: headings, paragraphs (line breaks are kept), bullet/numbered lists (nested), fenced code with language, tables, blockquotes, rules, `**bold**`, `*em*`, `~~strike~~`, `` `code` ``, links, and images on their own line.
