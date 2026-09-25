#!/usr/bin/env python3
"""Local bug-report scaffolding for the report-bug skill.

Subcommands:
  init                          create bugs/open, bugs/closed and install the pytest guard
  new TITLE [options]           create bugs/open/NNN-slug/ from the templates
  list [--all]                  list bugs with number, priority, status, title
  render [NNN ...] [--force]    render every .d2 to .svg, honouring '# render:' flags
  close NNN [--force]           set Status: Closed, move to bugs/closed/, rewrite paths
  reopen NNN                    set Status: Open, move back to bugs/open/, rewrite paths

Run from anywhere inside the repo; the root is the nearest ancestor containing
bugs/ (or the git top level, or the current directory). Override with --root.
Only the standard library is used.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

ASSETS = Path(__file__).resolve().parent.parent / "assets"
PRIORITIES = ("Low", "Medium", "High", "Critical")
NUM_RE = re.compile(r"^(\d{3})-")
TEXT_SUFFIXES = {".md", ".py", ".http", ".ts", ".js", ".mjs", ".go", ".rs", ".sh", ".d2", ".txt", ".json", ".yaml", ".yml", ".toml"}


def die(msg: str, code: int = 1) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def git_toplevel(start: Path) -> Path | None:
    try:
        out = subprocess.run(["git", "-C", str(start), "rev-parse", "--show-toplevel"],
                             capture_output=True, text=True, check=True).stdout.strip()
        return Path(out) if out else None
    except (OSError, subprocess.CalledProcessError):
        return None


def find_root(explicit: str | None) -> Path:
    if explicit:
        return Path(explicit).resolve()
    cwd = Path.cwd().resolve()
    for p in (cwd, *cwd.parents):
        if (p / "bugs" / "open").is_dir():
            return p
    return git_toplevel(cwd) or cwd


def bugs_dir(root: Path, must_exist: bool = True) -> Path:
    b = root / "bugs"
    if must_exist and not (b / "open").is_dir():
        die(f"{b}/open not found; run `bug.py init` first (or pass --root)")
    return b


def bug_dirs(b: Path, include_closed: bool = True):
    for state in ("open", "closed") if include_closed else ("open",):
        d = b / state
        if d.is_dir():
            for p in sorted(d.iterdir()):
                if p.is_dir() and NUM_RE.match(p.name):
                    yield state, p


def next_number(b: Path) -> int:
    nums = [int(NUM_RE.match(p.name).group(1)) for _, p in bug_dirs(b)]
    return max(nums, default=0) + 1


def locate(b: Path, ident: str) -> tuple[str, Path]:
    ident = ident.strip().rstrip("/")
    num = ident.split("/")[-1].split("-")[0]
    if not num.isdigit():
        die(f"not a bug number: {ident}")
    num = num.zfill(3)
    hits = [(s, p) for s, p in bug_dirs(b) if p.name.startswith(num + "-")]
    if not hits:
        die(f"bug {num} not found under {b}")
    if len(hits) > 1:
        die(f"bug {num} is ambiguous: " + ", ".join(str(p) for _, p in hits))
    return hits[0]


def slugify(title: str, max_len: int = 50) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
    if len(s) > max_len:
        s = s[:max_len].rsplit("-", 1)[0]
    return s or "bug"


def rel(root: Path, p: Path) -> str:
    try:
        return str(p.relative_to(root))
    except ValueError:
        return str(p)


# ---------------------------------------------------------------- init

def detect_tools(root: Path) -> list[str]:
    tools = []

    def read(name: str) -> str:
        f = root / name
        try:
            return f.read_text(errors="ignore") if f.is_file() else ""
        except OSError:
            return ""

    pyproject = read("pyproject.toml")
    if (root / "pytest.ini").is_file() or "[tool.pytest" in pyproject or "pytest" in pyproject \
            or "[tool:pytest]" in read("setup.cfg") or "[pytest]" in read("tox.ini") \
            or (root / "conftest.py").is_file():
        tools.append("pytest")
    pkg = read("package.json")
    if list(root.glob("vitest.config.*")) or '"vitest"' in pkg:
        tools.append("vitest")
    if list(root.glob("jest.config.*")) or '"jest"' in pkg:
        tools.append("jest")
    if (root / "go.mod").is_file():
        tools.append("go")
    if (root / "Cargo.toml").is_file():
        tools.append("cargo")
    return tools


GUARD_HINTS = {
    "jest": "jest: add \"<rootDir>/bugs/\" to testPathIgnorePatterns in the Jest config (see reproduction.md#jest)",
    "vitest": "vitest: add \"bugs/**\" to test.exclude and create bugs/vitest.config.ts (see reproduction.md#vitest)",
    "go": "go: no config change; put //go:build bugcheck at the top of each check_test.go",
    "cargo": "cargo: no config change; bugs/ is outside src/ and tests/ (use standalone checks)",
}


def cmd_init(args) -> None:
    root = find_root(args.root)
    b = root / "bugs"
    for state in ("open", "closed"):
        d = b / state
        created = not d.exists()
        d.mkdir(parents=True, exist_ok=True)
        keep = d / ".gitkeep"
        if not any(d.iterdir()):
            keep.touch()
        print(f"{'created' if created else 'exists '} {rel(root, d)}/")

    tools = args.tool or detect_tools(root)
    print("detected test tools: " + (", ".join(tools) if tools else "none"))
    todo = []
    for t in tools:
        if t == "pytest":
            dst = b / "conftest.py"
            if dst.exists():
                print(f"exists  {rel(root, dst)} (pytest guard)")
            else:
                shutil.copyfile(ASSETS / "bugs-conftest.py", dst)
                print(f"created {rel(root, dst)} (pytest guard)")
            print("verify: pytest -q --collect-only | grep bugs/   # expect nothing")
        elif t in GUARD_HINTS:
            todo.append(GUARD_HINTS[t])
    if not tools:
        todo.append("no test tool detected: use standalone checks, or install a guard per reproduction.md#other-tools")
    for line in todo:
        print("TODO " + line)


# ---------------------------------------------------------------- new

def fill_template(text: str, *, num: str, title: str, run_cmd: str | None, check_name: str | None) -> str:
    text = text.replace("Bug NNN — <title>", f"Bug {num} — {title}")
    if run_cmd:
        text = re.sub(r"^Run:  .*$", f"Run:  {run_cmd}", text, count=1, flags=re.M)
    if check_name:
        text = text.replace("see check.<ext>", f"see {check_name}")
    return text


def cmd_new(args) -> None:
    root = find_root(args.root)
    b = bugs_dir(root)
    title = args.title.strip()
    if not title:
        die("title must not be empty")
    priority = args.priority.capitalize()
    if priority not in PRIORITIES:
        die(f"priority must be one of {', '.join(PRIORITIES)}")
    num = f"{next_number(b):03d}"
    slug = slugify(args.slug or title)
    d = b / "open" / f"{num}-{slug}"
    if d.exists():
        die(f"{d} already exists")
    d.mkdir(parents=True)
    rel_dir = rel(root, d)

    check_name = run_cmd = None
    if args.check == "pytest":
        check_name, run_cmd = "check.py", f"pytest {rel_dir}/check.py -v"
        src = ASSETS / "check_pytest.py"
    elif args.check == "standalone":
        check_name, run_cmd = "check.py", f"python {rel_dir}/check.py"
        src = ASSETS / "check_standalone.py"
    if check_name:
        out = d / check_name
        out.write_text(fill_template(src.read_text(), num=num, title=title, run_cmd=run_cmd, check_name=None))
        if args.check == "standalone":
            out.chmod(0o755)

    if args.http:
        (d / "reproduction.http").write_text(
            fill_template((ASSETS / "reproduction.http").read_text(), num=num, title=title,
                          run_cmd=None, check_name=check_name))

    note = (ASSETS / "note.md").read_text()
    note = re.sub(r"^# NNN — .*$", f"# {num} — {title}", note, count=1, flags=re.M)
    note = re.sub(r"^\*\*Priority:\*\* .*$", f"**Priority:** {priority}", note, count=1, flags=re.M)
    if args.area:
        note = re.sub(r"^\*\*Area:\*\* .*$", f"**Area:** {args.area}", note, count=1, flags=re.M)
    if args.jira:
        url = args.jira_url or jira_url(args.jira)
        link = f"[{args.jira}]({url})" if url else args.jira
        note = re.sub(r"^<!-- \*\*Jira:\*\*.*-->$", f"**Jira:** {link}", note, count=1, flags=re.M)
    if not args.http:
        note = re.sub(r"^Manual API requests: `reproduction.http`\.\n\n", "", note, flags=re.M)
    if run_cmd:
        note = note.replace("<exact command to run check.<ext>>", run_cmd)
    if check_name:
        note = note.replace("`check.<ext>` passes.", f"`{check_name}` passes.")
    (d / "note.md").write_text(note)

    print(rel_dir)
    for f in sorted(d.iterdir()):
        print(f"  {f.name}")
    if run_cmd:
        print(f"run: {run_cmd}")


def jira_url(key: str) -> str | None:
    site = os.environ.get("ATLASSIAN_SITE_NAME", "").strip()
    if not site:
        return None
    base = site.rstrip("/") if site.startswith("http") else f"https://{site}.atlassian.net"
    return f"{base}/browse/{key}"


# ---------------------------------------------------------------- list

def header_field(note: str, name: str) -> str:
    m = re.search(rf"^\*\*{name}:\*\*\s*(.*)$", note, flags=re.M)
    return m.group(1).strip() if m else "?"


def cmd_list(args) -> None:
    root = find_root(args.root)
    b = bugs_dir(root)
    rows = 0
    for state, d in bug_dirs(b, include_closed=args.all):
        note_f = d / "note.md"
        note = note_f.read_text(errors="ignore") if note_f.is_file() else ""
        m = re.search(r"^# (.*)$", note, flags=re.M)
        title = m.group(1).split("—", 1)[-1].strip() if m else d.name
        jira = re.search(r"^\*\*Jira:\*\*\s*\[?([A-Z][A-Z0-9]+-\d+)", note, flags=re.M)
        extra = f"  [{jira.group(1)}]" if jira else ""
        print(f"{d.name[:3]}  {state:<6}  {header_field(note, 'Priority'):<8}  {title}{extra}")
        rows += 1
    if not rows:
        print("no bugs")


# ---------------------------------------------------------------- render

def render_flags(d2: Path) -> list[str]:
    first = d2.read_text(errors="ignore").split("\n", 1)[0]
    m = re.match(r"^#\s*render:\s*(.*)$", first)
    if not m or m.group(1).lstrip().startswith("("):
        return []
    return shlex.split(m.group(1))


def cmd_render(args) -> None:
    if not shutil.which("d2"):
        die("d2 not found on PATH (https://d2lang.com)")
    root = find_root(args.root)
    b = bugs_dir(root)
    dirs = [locate(b, i)[1] for i in args.bugs] if args.bugs else [p for _, p in bug_dirs(b, include_closed=args.all)]
    failed = 0
    for d in dirs:
        for src in sorted(d.glob("*.d2")):
            out = src.with_suffix(".svg")
            if not args.force and out.exists() and out.stat().st_mtime >= src.stat().st_mtime:
                print(f"fresh   {rel(root, out)}")
                continue
            flags = render_flags(src)
            r = subprocess.run(["d2", *flags, str(src), str(out)], capture_output=True, text=True)
            if r.returncode == 0:
                print(f"render  {rel(root, out)}" + (f"  ({' '.join(flags)})" if flags else ""))
            else:
                failed += 1
                print(f"FAILED  {rel(root, src)}\n{(r.stderr or r.stdout).strip()}")
    sys.exit(1 if failed else 0)


# ---------------------------------------------------------------- close

def move_bug(root: Path, b: Path, d: Path, to: str) -> None:
    src_state = d.parent.name
    dst = b / to / d.name
    if dst.exists():
        die(f"{dst} already exists")
    note_f = d / "note.md"
    in_git = git_toplevel(root) is not None and subprocess.run(
        ["git", "-C", str(root), "ls-files", "--error-unmatch", str(note_f)],
        capture_output=True).returncode == 0
    if in_git:
        subprocess.run(["git", "-C", str(root), "mv", str(d), str(dst)], check=True)
    else:
        shutil.move(str(d), str(dst))

    old, new = f"bugs/{src_state}/{d.name}", f"bugs/{to}/{d.name}"
    changed = []
    for f in dst.rglob("*"):
        if f.is_file() and f.suffix in TEXT_SUFFIXES:
            t = f.read_text(errors="ignore")
            if old in t:
                f.write_text(t.replace(old, new))
                changed.append(f.name)
    print(f"moved   {rel(root, d)} -> {rel(root, dst)} ({'git mv' if in_git else 'mv'})")
    if changed:
        print("paths   updated in " + ", ".join(sorted(changed)))


def set_status(note_f: Path, status: str) -> None:
    note = note_f.read_text()
    note_f.write_text(re.sub(r"^\*\*Status:\*\* .*$", f"**Status:** {status}", note, count=1, flags=re.M))
    print(f"status  {status}")


def cmd_close(args) -> None:
    root = find_root(args.root)
    b = bugs_dir(root)
    state, d = locate(b, args.bug)
    if state == "closed":
        die(f"{rel(root, d)} is already closed")
    visible = re.sub(r"<!--.*?-->", "", (d / "note.md").read_text(), flags=re.S)
    if not re.search(r"^## Resolution\s*$", visible, flags=re.M) and not args.force:
        die("note.md has no ## Resolution section; write it first (or pass --force)")
    set_status(d / "note.md", "Closed")
    move_bug(root, b, d, "closed")


def cmd_reopen(args) -> None:
    root = find_root(args.root)
    b = bugs_dir(root)
    state, d = locate(b, args.bug)
    if state == "open":
        die(f"{rel(root, d)} is already open")
    set_status(d / "note.md", "Open")
    move_bug(root, b, d, "open")


# ---------------------------------------------------------------- main

def main() -> None:
    p = argparse.ArgumentParser(prog="bug.py", description=__doc__.split("\n\n")[0])
    p.add_argument("--root", help="repo root (default: auto-detect)")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("init", help="create bugs/ and install the pytest guard")
    s.add_argument("--tool", action="append", choices=["pytest", "jest", "vitest", "go", "cargo"],
                   help="override detection (repeatable)")
    s.set_defaults(fn=cmd_init)

    s = sub.add_parser("new", help="scaffold a new bug directory")
    s.add_argument("title")
    s.add_argument("--priority", default="Medium", help="Low | Medium | High | Critical")
    s.add_argument("--slug", help="directory name after NNN- (default: from title)")
    s.add_argument("--area", help="affected routes / modules / components")
    s.add_argument("--check", choices=["pytest", "standalone", "none"], default="none")
    s.add_argument("--http", action="store_true", help="add reproduction.http")
    s.add_argument("--jira", metavar="KEY", help="linked Jira key (e.g. on import)")
    s.add_argument("--jira-url", help="ticket URL (default: from ATLASSIAN_SITE_NAME)")
    s.set_defaults(fn=cmd_new)

    s = sub.add_parser("list", help="list bugs")
    s.add_argument("--all", action="store_true", help="include closed bugs")
    s.set_defaults(fn=cmd_list)

    s = sub.add_parser("render", help="render .d2 diagrams to .svg")
    s.add_argument("bugs", nargs="*", help="bug numbers (default: all open bugs)")
    s.add_argument("--all", action="store_true", help="include closed bugs when no numbers given")
    s.add_argument("--force", action="store_true", help="re-render even if the .svg is newer")
    s.set_defaults(fn=cmd_render)

    s = sub.add_parser("close", help="mark closed and move to bugs/closed/")
    s.add_argument("bug")
    s.add_argument("--force", action="store_true", help="skip the Resolution-section check")
    s.set_defaults(fn=cmd_close)

    s = sub.add_parser("reopen", help="mark open and move back to bugs/open/")
    s.add_argument("bug")
    s.set_defaults(fn=cmd_reopen)

    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
