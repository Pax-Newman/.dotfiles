#!/usr/bin/env python3
"""Jira integration for the report-bug skill (Jira Cloud REST v3).

Subcommands:
  check                               verify credentials (preflight)
  export TICKET.md [options]          create or update an issue from markdown; upload + embed images
  import KEY [--out DIR]              print the issue as markdown; download attachments
  comment KEY (--file F | --text T)   add a markdown comment
  transition KEY [--to NAME]          list transitions, or apply one
  sync [NNN ...]                      report Jira state for local bugs with a **Jira:** link

Credentials come from ATLASSIAN_SITE_NAME, ATLASSIAN_USER_EMAIL and
ATLASSIAN_API_TOKEN. They are never printed. Only the standard library is used.
"""
from __future__ import annotations

import argparse
import base64
import datetime as _dt
import json
import mimetypes
import os
import re
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path

ENV = ("ATLASSIAN_SITE_NAME", "ATLASSIAN_USER_EMAIL", "ATLASSIAN_API_TOKEN")


def die(msg: str, code: int = 1) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


# ================================================================ HTTP

class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a, **k):
        return None


_OPEN = urllib.request.build_opener()
_OPEN_NOREDIRECT = urllib.request.build_opener(_NoRedirect)


def base_url() -> str:
    site = os.environ.get("ATLASSIAN_SITE_NAME", "").strip()
    return site.rstrip("/") if site.startswith("http") else f"https://{site}.atlassian.net"


def require_env() -> None:
    missing = [v for v in ENV if not os.environ.get(v)]
    if missing:
        die("missing environment variables: " + ", ".join(missing)
            + " (ask the user to set them; never ask for the values)")


def _auth() -> str:
    raw = f"{os.environ['ATLASSIAN_USER_EMAIL']}:{os.environ['ATLASSIAN_API_TOKEN']}"
    return "Basic " + base64.b64encode(raw.encode()).decode()


def _error_text(e: urllib.error.HTTPError) -> str:
    try:
        body = json.loads(e.read().decode(errors="ignore") or "{}")
        parts = list(body.get("errorMessages") or []) + [f"{k}: {v}" for k, v in (body.get("errors") or {}).items()]
        return "; ".join(parts) or e.reason
    except (ValueError, AttributeError):
        return str(e.reason)


class ApiError(Exception):
    def __init__(self, code: int, msg: str):
        super().__init__(msg)
        self.code = code


def api(method: str, path: str, body=None, *, data: bytes | None = None,
        headers: dict | None = None, follow: bool = True, auth: bool = True, fatal: bool = True):
    """Returns parsed JSON (or None). With follow=False returns the Location header of a redirect.
    With fatal=False, HTTP errors raise ApiError instead of exiting."""
    url = path if path.startswith("http") else base_url() + path
    req = urllib.request.Request(url, method=method)
    if auth:
        req.add_header("Authorization", _auth())
    req.add_header("Accept", "application/json")
    if body is not None:
        data = json.dumps(body).encode()
        req.add_header("Content-Type", "application/json")
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    try:
        with (_OPEN if follow else _OPEN_NOREDIRECT).open(req, data=data, timeout=120) as r:
            raw = r.read()
            if not follow:
                return None
            return json.loads(raw) if raw and "json" in r.headers.get("Content-Type", "") else raw
    except urllib.error.HTTPError as e:
        if not follow and e.code in (301, 302, 303, 307, 308):
            return e.headers.get("Location")
        msg = f"{method} {urllib.parse.urlsplit(url).path} -> HTTP {e.code}: {_error_text(e)}"
        if not fatal:
            raise ApiError(e.code, msg)
        die(msg)
    except urllib.error.URLError as e:
        die(f"{method} {urllib.parse.urlsplit(url).path} failed: {e.reason}")


def preflight() -> dict:
    require_env()
    return api("GET", "/rest/api/3/myself")


# ================================================================ markdown -> ADF

_INLINE = re.compile(
    r"(?P<code>`+)(?P<code_t>.+?)(?P=code)"
    r"|!\[(?P<img_alt>[^\]]*)\]\((?P<img_src>[^)\s]+)\)"
    r"|\[(?P<link_t>[^\]]+)\]\((?P<link_href>[^)\s]+)\)"
    r"|\*\*(?P<b1>.+?)\*\*|__(?P<b2>.+?)__"
    r"|~~(?P<s>.+?)~~"
    r"|(?<![\w*])\*(?![\s*])(?P<i1>.+?)(?<![\s*])\*(?![\w*])"
    r"|(?<![\w_])_(?![\s_])(?P<i2>.+?)(?<![\s_])_(?![\w_])"
    r"|(?P<url>https?://[^\s)>\]]+)"
)


def _text(t: str, marks: list) -> list:
    if not t:
        return []
    n = {"type": "text", "text": t}
    if marks:
        n["marks"] = [dict(m) for m in marks]
    return [n]


def inline(s: str, marks: list | None = None) -> list:
    marks = marks or []
    out, pos = [], 0
    for m in _INLINE.finditer(s):
        out += _text(s[pos:m.start()], marks)
        g = m.groupdict()
        if g["code"]:
            out += _text(g["code_t"].strip() if g["code_t"].strip() else g["code_t"],
                         [x for x in marks if x["type"] == "link"] + [{"type": "code"}])
        elif g["img_src"] is not None:
            out += _text(g["img_alt"] or g["img_src"], marks)
        elif g["link_t"] is not None:
            out += inline(g["link_t"], marks + [{"type": "link", "attrs": {"href": g["link_href"]}}])
        elif g["b1"] or g["b2"]:
            out += inline(g["b1"] or g["b2"], marks + [{"type": "strong"}])
        elif g["s"]:
            out += inline(g["s"], marks + [{"type": "strike"}])
        elif g["i1"] or g["i2"]:
            out += inline(g["i1"] or g["i2"], marks + [{"type": "em"}])
        elif g["url"]:
            out += _text(g["url"], marks + [{"type": "link", "attrs": {"href": g["url"]}}])
        pos = m.end()
    out += _text(s[pos:], marks)
    return out


_FENCE = re.compile(r"^\s*(`{3,}|~{3,})\s*([\w+#.-]*)")
_HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
_RULE = re.compile(r"^\s*([-*_])(\s*\1){2,}\s*$")
_IMAGE = re.compile(r"^\s*!\[([^\]]*)\]\(([^)\s]+)\)\s*$")
_LIST = re.compile(r"^(\s*)([-*+]|\d+[.)])\s+(.*)$")
_QUOTE = re.compile(r"^\s*>\s?(.*)$")
_TABLE_SEP = re.compile(r"^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$")


def _is_table(lines, i) -> bool:
    return "|" in lines[i] and i + 1 < len(lines) and bool(_TABLE_SEP.match(lines[i + 1]))


def _block_start(lines, i) -> bool:
    l = lines[i]
    return bool(_FENCE.match(l) or _HEADING.match(l) or _RULE.match(l) or _IMAGE.match(l)
                or _LIST.match(l) or _QUOTE.match(l) or _is_table(lines, i))


def _paragraph(lines: list[str]) -> dict:
    content = []
    for k, l in enumerate(lines):
        if k:
            content.append({"type": "hardBreak"})
        content += inline(l.strip())
    return {"type": "paragraph", "content": content}


def _cells(row: str) -> list[str]:
    row = row.strip()
    if row.startswith("|"):
        row = row[1:]
    if row.endswith("|"):
        row = row[:-1]
    return [c.strip() for c in re.split(r"(?<!\\)\|", row)]


def _list(lines, i):
    first = _LIST.match(lines[i])
    indent = len(first.group(1))
    ordered = first.group(2)[0].isdigit()
    node = {"type": "orderedList" if ordered else "bulletList", "content": []}
    if ordered:
        node["attrs"] = {"order": int(re.match(r"\d+", first.group(2)).group())}
    while i < len(lines):
        m = _LIST.match(lines[i])
        if not m or len(m.group(1)) != indent or m.group(2)[0].isdigit() != ordered:
            break
        offset = len(m.group(0)) - len(m.group(3))
        item = [m.group(3)]
        i += 1
        while i < len(lines):
            l = lines[i]
            lead = len(l) - len(l.lstrip())
            if not l.strip():
                j = i
                while j < len(lines) and not lines[j].strip():
                    j += 1
                if j < len(lines) and len(lines[j]) - len(lines[j].lstrip()) > indent:
                    item += [""] * (j - i)
                    i = j
                    continue
                break
            if lead <= indent:
                break
            item.append(l[min(lead, offset):])
            i += 1
        node["content"].append({"type": "listItem",
                                "content": blocks(item) or [{"type": "paragraph", "content": []}]})
    return node, i


def blocks(lines: list[str]) -> list:
    out, i = [], 0
    while i < len(lines):
        l = lines[i]
        if not l.strip():
            i += 1
            continue
        if m := _FENCE.match(l):
            fence, lang, body = m.group(1), m.group(2), []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith(fence):
                body.append(lines[i])
                i += 1
            i += 1
            n = {"type": "codeBlock", "attrs": {"language": lang} if lang else {}}
            if body:
                n["content"] = [{"type": "text", "text": "\n".join(body)}]
            out.append(n)
        elif m := _HEADING.match(l):
            out.append({"type": "heading", "attrs": {"level": len(m.group(1))}, "content": inline(m.group(2))})
            i += 1
        elif _RULE.match(l):
            out.append({"type": "rule"})
            i += 1
        elif m := _IMAGE.match(l):
            out.append({"type": "_image", "alt": m.group(1), "src": m.group(2)})
            i += 1
        elif _is_table(lines, i):
            header = _cells(l)
            i += 2
            rows = [{"type": "tableRow", "content": [
                {"type": "tableHeader", "content": [{"type": "paragraph", "content": inline(c)}]} for c in header]}]
            while i < len(lines) and "|" in lines[i] and lines[i].strip():
                cells = (_cells(lines[i]) + [""] * len(header))[:len(header)]
                rows.append({"type": "tableRow", "content": [
                    {"type": "tableCell", "content": [{"type": "paragraph", "content": inline(c)}]} for c in cells]})
                i += 1
            out.append({"type": "table", "content": rows})
        elif _QUOTE.match(l):
            body = []
            while i < len(lines) and (m := _QUOTE.match(lines[i])):
                body.append(m.group(1))
                i += 1
            out.append({"type": "blockquote", "content": blocks(body)})
        elif _LIST.match(l):
            node, i = _list(lines, i)
            out.append(node)
        else:
            para = [l]
            i += 1
            while i < len(lines) and lines[i].strip() and not _block_start(lines, i):
                para.append(lines[i])
                i += 1
            out.append(_paragraph(para))
    return out


def md_to_adf(md: str) -> dict:
    md = re.sub(r"<!--.*?-->", "", md, flags=re.S)
    return {"type": "doc", "version": 1, "content": blocks(md.splitlines())}


def resolve_images(node, media: dict[str, str | None]):
    """Replace _image placeholders. media maps src -> media id (None = not available)."""
    if isinstance(node, list):
        return [resolve_images(n, media) for n in node]
    if not isinstance(node, dict):
        return node
    if node.get("type") == "_image":
        src, alt = node["src"], node["alt"]
        mid = media.get(src)
        if mid:
            attrs = {"type": "file", "id": mid, "collection": ""}
            if alt:
                attrs["alt"] = alt
            return {"type": "mediaSingle", "attrs": {"layout": "center"},
                    "content": [{"type": "media", "attrs": attrs}]}
        if src.startswith("http"):
            return {"type": "paragraph", "content": _text(alt or src, [{"type": "link", "attrs": {"href": src}}])}
        return {"type": "paragraph", "content": _text("See attached ", []) + _text(Path(src).name, [{"type": "code"}])
                + (_text(f" ({alt})", []) if alt else [])}
    if "content" in node:
        node = dict(node, content=resolve_images(node["content"], media))
    return node


def image_srcs(node) -> list[str]:
    if isinstance(node, list):
        return [s for n in node for s in image_srcs(n)]
    if not isinstance(node, dict):
        return []
    if node.get("type") == "_image":
        return [node["src"]]
    return image_srcs(node.get("content", []))


# ================================================================ ADF -> markdown

def _md_inline(nodes) -> str:
    out = []
    for n in nodes or []:
        t = n.get("type")
        a = n.get("attrs", {})
        if t == "text":
            s, link = n.get("text", ""), None
            for mk in n.get("marks", []):
                mt = mk.get("type")
                if mt == "code":
                    s = f"`{s}`"
                elif mt == "strong":
                    s = f"**{s}**"
                elif mt == "em":
                    s = f"*{s}*"
                elif mt == "strike":
                    s = f"~~{s}~~"
                elif mt == "link":
                    link = mk.get("attrs", {}).get("href")
            out.append(f"[{s}]({link})" if link and link != n.get("text") else s)
        elif t == "hardBreak":
            out.append("\n")
        elif t == "mention":
            out.append(a.get("text") or "@user")
        elif t == "emoji":
            out.append(a.get("text") or a.get("shortName", ""))
        elif t in ("inlineCard", "blockCard", "embedCard"):
            out.append(a.get("url", ""))
        elif t == "status":
            out.append(f"[{a.get('text', '')}]")
        elif t == "date":
            out.append(str(a.get("timestamp", "")))
        elif t == "mediaInline":
            out.append(f"[attachment: {a.get('alt') or a.get('id', '')}]")
        else:
            out.append(_md_inline(n.get("content")))
    return "".join(out)


def _indent(text: str, prefix: str, first: str | None = None) -> str:
    lines = text.split("\n")
    return "\n".join(((first if k == 0 and first is not None else prefix) + l) if l else l
                     for k, l in enumerate(lines))


def _md_block(n) -> str:
    t = n.get("type")
    a = n.get("attrs", {}) or {}
    c = n.get("content", [])
    if t == "paragraph":
        return _md_inline(c)
    if t == "heading":
        return "#" * a.get("level", 2) + " " + _md_inline(c)
    if t in ("bulletList", "orderedList"):
        items, start = [], a.get("order", 1)
        for k, item in enumerate(c):
            marker = f"{start + k}. " if t == "orderedList" else "- "
            body = "\n\n".join(_md_block(x) for x in item.get("content", []))
            items.append(_indent(body, " " * len(marker), marker))
        return "\n".join(items)
    if t == "codeBlock":
        return f"```{a.get('language', '')}\n{_md_inline(c)}\n```"
    if t == "blockquote":
        return _indent(adf_to_md_blocks(c), "> ")
    if t == "panel":
        return _indent(f"**{a.get('panelType', 'note')}:** " + adf_to_md_blocks(c), "> ")
    if t == "rule":
        return "---"
    if t in ("mediaSingle", "mediaGroup"):
        return "\n".join(f"[attachment: {m.get('attrs', {}).get('alt') or m.get('attrs', {}).get('id', '')}]"
                         for m in c if m.get("type") == "media")
    if t in ("expand", "nestedExpand"):
        return f"**{a.get('title', '')}**\n\n" + adf_to_md_blocks(c)
    if t == "table":
        rows = [[" ".join(_md_block(x) for x in cell.get("content", [])).replace("\n", " ").replace("|", "\\|")
                 for cell in row.get("content", [])] for row in c]
        if not rows:
            return ""
        width = max(len(r) for r in rows)
        rows = [r + [""] * (width - len(r)) for r in rows]
        lines = ["| " + " | ".join(rows[0]) + " |", "|" + "---|" * width]
        lines += ["| " + " | ".join(r) + " |" for r in rows[1:]]
        return "\n".join(lines)
    if t in ("text", "hardBreak", "mention", "emoji", "inlineCard", "status", "date"):
        return _md_inline([n])
    return adf_to_md_blocks(c)


def adf_to_md_blocks(nodes) -> str:
    return "\n\n".join(s for s in (_md_block(n) for n in nodes or []) if s.strip())


def adf_to_md(doc) -> str:
    if not doc:
        return ""
    if isinstance(doc, str):
        return doc
    return adf_to_md_blocks(doc.get("content", []))


# ================================================================ local-reference lint

LEAKS = [
    (re.compile(r"bugs/(open|closed)"), "bug-directory path"),
    (re.compile(r"\bnote\.md\b"), "note.md reference"),
    (re.compile(r"\bcheck\.<ext>"), "template placeholder"),
    (re.compile(r"\breport-bug\b"), "skill name"),
    (re.compile(r"\b[Bb]ug \d{3}\b"), "local bug number"),
    (re.compile(r"\b\d{3}-[a-z0-9]+(?:-[a-z0-9]+)+\b"), "local bug directory name"),
    (re.compile(r"^\*\*(Status|Jira):\*\*", re.M), "local header line"),
]


def lint(md: str) -> list[str]:
    visible = re.sub(r"<!--.*?-->", "", md, flags=re.S)
    problems = []
    for n, line in enumerate(visible.splitlines(), 1):
        for rx, what in LEAKS:
            if rx.search(line):
                problems.append(f"  line {n}: {what}: {line.strip()[:100]}")
    return problems


# ================================================================ helpers

def split_ticket(md: str) -> tuple[str, str]:
    lines = md.splitlines()
    for k, l in enumerate(lines):
        if l.strip():
            m = re.match(r"^#\s+(.*?)\s*$", l)
            if not m:
                die("TICKET.md must start with '# <summary>'")
            return m.group(1), "\n".join(lines[k + 1:])
    die("TICKET.md is empty")


def pick(names: list[str], wanted: str, what: str) -> str:
    for n in names:
        if n.lower() == wanted.lower():
            return n
    die(f"{what} '{wanted}' not found; available: {', '.join(names)}", 2)


def priorities() -> list[str]:
    res = api("GET", "/rest/api/3/priority")
    if isinstance(res, dict):
        res = res.get("values", [])
    return [p["name"] for p in res or []]


def issue_types(project: str) -> list[str]:
    res = api("GET", f"/rest/api/3/issue/createmeta/{urllib.parse.quote(project)}/issuetypes")
    items = res.get("issueTypes") or res.get("values") or []
    return [t["name"] for t in items]


def upload(key: str, path: Path) -> dict:
    boundary = uuid.uuid4().hex
    ctype = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    body = (f"--{boundary}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"{path.name}\"\r\n"
            f"Content-Type: {ctype}\r\n\r\n").encode() + path.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    res = api("POST", f"/rest/api/3/issue/{key}/attachments", data=body,
              headers={"X-Atlassian-Token": "no-check", "Content-Type": f"multipart/form-data; boundary={boundary}"})
    return res[0]


def media_id(attachment_id: str) -> str | None:
    loc = api("GET", f"/rest/api/3/attachment/content/{attachment_id}", follow=False)
    m = re.search(r"/file/([0-9a-f-]{36})/", loc or "")
    return m.group(1) if m else None


def update_note(note: Path, key: str) -> None:
    line = f"**Jira:** [{key}]({base_url()}/browse/{key})"
    text = note.read_text()
    if re.search(r"^\*\*Jira:\*\*.*$", text, flags=re.M):
        text = re.sub(r"^\*\*Jira:\*\*.*$", line, text, count=1, flags=re.M)
    elif re.search(r"^<!-- \*\*Jira:\*\*.*-->$", text, flags=re.M):
        text = re.sub(r"^<!-- \*\*Jira:\*\*.*-->$", line, text, count=1, flags=re.M)
    else:
        lines = text.splitlines()
        at = max((k for k, l in enumerate(lines[:15]) if re.match(r"^\*\*\w+:\*\*", l)), default=0)
        lines.insert(at + 1, line)
        text = "\n".join(lines) + "\n"
    note.write_text(text)


def find_local(key: str) -> list[Path]:
    cwd = Path.cwd().resolve()
    for p in (cwd, *cwd.parents):
        b = p / "bugs"
        if (b / "open").is_dir():
            rx = re.compile(rf"\b{re.escape(key)}\b")
            return [n.parent for n in sorted(b.glob("*/*/note.md")) if rx.search(n.read_text(errors="ignore"))]
    return []


def bugs_root() -> Path:
    cwd = Path.cwd().resolve()
    for p in (cwd, *cwd.parents):
        if (p / "bugs" / "open").is_dir():
            return p / "bugs"
    die("bugs/open not found; run from inside the repo")


def _header(note: str, name: str) -> str | None:
    m = re.search(rf"^\*\*{name}:\*\*\s*(.*?)\s*$", note, flags=re.M)
    return m.group(1) if m else None


def linked_bugs(numbers: list[str]) -> list[dict]:
    b = bugs_root()
    wanted = {n.zfill(3) for n in numbers}
    found, out = set(), []
    for note_f in sorted(b.glob("*/*/note.md")):
        d = note_f.parent
        num = d.name[:3]
        if d.parent.name not in ("open", "closed") or not num.isdigit() or (wanted and num not in wanted):
            continue
        found.add(num)
        note = note_f.read_text(errors="ignore")
        jira = _header(note, "Jira") or ""
        key = re.search(r"\b([A-Z][A-Z0-9]+-\d+)\b", jira)
        if not key:
            if wanted:
                die(f"bug {num} has no **Jira:** link")
            continue
        title = re.search(r"^# (.*)$", note, flags=re.M)
        out.append({"num": num, "state": d.parent.name, "key": key.group(1),
                    "title": title.group(1).split("—", 1)[-1].strip() if title else d.name,
                    "priority": _header(note, "Priority") or "?",
                    "synced": _header(note, "Jira synced")})
    missing = wanted - found
    if missing:
        die("bug(s) not found: " + ", ".join(sorted(missing)))
    return out


def _snippet(adf, limit: int) -> str:
    s = re.sub(r"\s+", " ", adf_to_md(adf)).strip()
    return s if len(s) <= limit else s[:limit].rstrip() + "…"


# ================================================================ commands

def cmd_check(args) -> None:
    me = preflight()
    print(f"ok  {base_url()}  as {me.get('displayName', '?')}")


def cmd_export(args) -> None:
    ticket = Path(args.ticket).resolve()
    md = ticket.read_text()
    problems = lint(md)
    if problems and not args.allow_local_refs:
        die("ticket contains local references (fix them, or pass --allow-local-refs):\n" + "\n".join(problems), 3)
    summary, body = split_ticket(md)
    adf = md_to_adf(body)
    images = list(dict.fromkeys(s for s in image_srcs(adf["content"]) if not s.startswith("http")))
    files: dict[str, Path] = {}
    for s in images:
        files[s] = (ticket.parent / s).resolve()
    extra = [Path(a).resolve() for a in args.attach or []]
    missing = [str(p) for p in [*files.values(), *extra] if not p.is_file()]
    if missing:
        die("missing files: " + ", ".join(missing))

    if args.dry_run:
        print(f"summary: {summary}")
        print(f"images:  {', '.join(p.name for p in files.values()) or 'none'}")
        print(f"attach:  {', '.join(p.name for p in extra) or 'none'}")
        print(f"blocks:  {len(adf['content'])}")
        if args.print_adf:
            print(json.dumps(resolve_images(adf, {}), indent=1))
        return

    preflight()
    fields = {"summary": summary, "description": resolve_images(adf, {})}
    if args.priority:
        fields["priority"] = {"name": pick(priorities(), args.priority, "priority")}
    if args.update:
        key = args.update
        api("PUT", f"/rest/api/3/issue/{key}", {"fields": fields})
        print(f"updated {key}")
    else:
        project = args.project or os.environ.get("JIRA_PROJECT_KEY")
        if not project:
            die("no project: pass --project or set JIRA_PROJECT_KEY", 2)
        fields["project"] = {"key": project}
        fields["issuetype"] = {"name": pick(issue_types(project), args.type, "issue type")}
        key = api("POST", "/rest/api/3/issue", {"fields": fields})["key"]
        print(f"created {key}")

    media: dict[str, str | None] = {}
    uploaded: dict[Path, dict] = {}
    for p in [*files.values(), *extra]:
        if p not in uploaded:
            uploaded[p] = upload(key, p)
            print(f"attached {p.name}")
    for src, p in files.items():
        media[src] = media_id(uploaded[p]["id"])
        if not media[src]:
            print(f"warning: no media id for {p.name}; left as 'See attached' text")
    if files:
        api("PUT", f"/rest/api/3/issue/{key}", {"fields": {"description": resolve_images(adf, media)}})
        print(f"embedded {sum(1 for v in media.values() if v)}/{len(media)} images")

    for other in args.link or []:
        api("POST", "/rest/api/3/issueLink",
            {"type": {"name": "Relates"}, "inwardIssue": {"key": key}, "outwardIssue": {"key": other}})
        print(f"linked {key} relates to {other}")

    if args.note:
        update_note(Path(args.note), key)
        print(f"noted in {args.note}")
    print(f"{base_url()}/browse/{key}")


def cmd_import(args) -> None:
    preflight()
    key = args.key.upper()
    fields = "summary,description,priority,status,issuetype,attachment,comment,issuelinks,labels,components"
    issue = api("GET", f"/rest/api/3/issue/{key}?fields={fields}")
    f = issue["fields"]
    name = lambda x: (x or {}).get("name", "?")
    out = [f"# {key} — {f.get('summary', '')}", "",
           f"**URL:** {base_url()}/browse/{key}",
           f"**Type:** {name(f.get('issuetype'))}  **Status:** {name(f.get('status'))}  "
           f"**Priority:** {name(f.get('priority'))}"]
    if f.get("labels"):
        out.append("**Labels:** " + ", ".join(f["labels"]))
    if f.get("components"):
        out.append("**Components:** " + ", ".join(c["name"] for c in f["components"]))
    local = find_local(key)
    if local:
        out.append("**Existing local bug:** " + ", ".join(str(p) for p in local))
    out += ["", "## Description", "", adf_to_md(f.get("description")) or "_(empty)_"]

    links = f.get("issuelinks") or []
    if links:
        out += ["", "## Links", ""]
        for l in links:
            if "outwardIssue" in l:
                rel, other = l["type"]["outward"], l["outwardIssue"]
            else:
                rel, other = l["type"]["inward"], l["inwardIssue"]
            of = other.get("fields", {})
            out.append(f"- {rel} {other['key']} — {of.get('summary', '')} ({name(of.get('status'))})")

    atts = f.get("attachment") or []
    if atts:
        dest = Path(args.out or Path(tempfile.gettempdir()) / f"bugimport-{key}")
        out += ["", "## Attachments", ""]
        if not args.no_download:
            dest.mkdir(parents=True, exist_ok=True)
        for a in atts:
            size = a.get("size", 0)
            label = f"- {a['filename']} ({a.get('mimeType', '?')}, {size // 1024} KB)"
            if args.no_download or size > args.max_mb * 1024 * 1024:
                out.append(label + ("" if args.no_download else " — skipped (too large)"))
                continue
            target = dest / a["filename"]
            if target.exists():
                target = dest / f"{a['id']}-{a['filename']}"
            loc = api("GET", f"/rest/api/3/attachment/content/{a['id']}", follow=False)
            if loc:
                data = api("GET", urllib.parse.urljoin(base_url(), loc), auth=False)
            else:
                data = api("GET", f"/rest/api/3/attachment/content/{a['id']}")
            target.write_bytes(data if isinstance(data, bytes) else json.dumps(data).encode())
            out.append(f"{label} → {target}")

    comments = (f.get("comment") or {}).get("comments") or []
    if comments:
        out += ["", "## Comments"]
        for c in comments:
            who = (c.get("author") or {}).get("displayName", "?")
            out += ["", f"### {who} — {c.get('created', '')[:10]}", "", adf_to_md(c.get("body"))]
    print("\n".join(out))


def cmd_sync(args) -> None:
    bugs = linked_bugs(args.bugs)
    if not bugs:
        print("no bugs with a **Jira:** link")
        return
    preflight()
    fields = ["summary", "status", "priority", "resolution", "updated", "comment"]
    issues: dict[str, dict] = {}
    keys = sorted({b["key"] for b in bugs})
    try:
        for i in range(0, len(keys), 50):
            body = {"jql": f"key in ({','.join(keys[i:i + 50])})", "fields": fields, "maxResults": 50}
            while True:
                res = api("POST", "/rest/api/3/search/jql", body, fatal=False)
                for it in res.get("issues", []):
                    issues[it["key"]] = it
                if not res.get("nextPageToken"):
                    break
                body["nextPageToken"] = res["nextPageToken"]
    except ApiError:
        issues = {}
        for k in keys:
            try:
                issues[k] = api("GET", f"/rest/api/3/issue/{k}?fields={','.join(fields)}", fatal=False)
            except ApiError as e:
                issues[k] = {"error": str(e)}

    name = lambda x: (x or {}).get("name") or "none"
    for b in bugs:
        it = issues.get(b["key"])
        print(f"{b['num']}  local {b['state']}  {b['key']}  {base_url()}/browse/{b['key']}")
        if not it or "error" in it:
            print(f"     jira: not found or not accessible ({(it or {}).get('error', 'no result')})")
            continue
        f = it.get("fields", {})
        st = f.get("status") or {}
        cat = (st.get("statusCategory") or {}).get("name")
        print(f"     jira status: {st.get('name', '?')}" + (f" (category: {cat})" if cat else "")
              + f"; resolution: {name(f.get('resolution'))}; updated: {(f.get('updated') or '?')[:10]}")
        print(f"     priority: local {b['priority']}; jira {name(f.get('priority'))}")
        if (f.get("summary") or "").strip() != b["title"]:
            print(f"     summary differs: jira \"{f.get('summary', '')}\"")
        cm = f.get("comment") or {}
        comments = cm.get("comments") or []
        total = cm.get("total", len(comments))
        line = f"     comments: {total}"
        if b["synced"] and comments:
            new = sum(1 for c in comments if (c.get("created") or "")[:10] >= b["synced"][:10])
            line += f" ({'≥' if len(comments) < total else ''}{new} on/after last sync {b['synced']})"
        elif not b["synced"]:
            line += " (never synced)"
        print(line)
        if comments:
            last = max(comments, key=lambda c: c.get("created") or "")
            who = (last.get("author") or {}).get("displayName", "?")
            print(f"     latest: {who} {(last.get('created') or '')[:10]}: \"{_snippet(last.get('body'), args.chars)}\"")
    print(f"today: {_dt.date.today().isoformat()}")


def cmd_comment(args) -> None:
    md = Path(args.file).read_text() if args.file else args.text
    problems = lint(md)
    if problems and not args.allow_local_refs:
        die("comment contains local references (fix them, or pass --allow-local-refs):\n" + "\n".join(problems), 3)
    preflight()
    adf = resolve_images(md_to_adf(md), {})
    res = api("POST", f"/rest/api/3/issue/{args.key}/comment", {"body": adf})
    print(f"commented on {args.key} (id {res.get('id')})")


def cmd_transition(args) -> None:
    preflight()
    ts = api("GET", f"/rest/api/3/issue/{args.key}/transitions")["transitions"]
    if not args.to:
        for t in ts:
            print(f"{t['id']}: {t['name']} -> {t.get('to', {}).get('name', '?')}")
        return
    want = args.to.lower()
    match = [t for t in ts if want in (t["name"].lower(), t.get("to", {}).get("name", "").lower(), t["id"])]
    if not match:
        die(f"no transition '{args.to}'; available: " + ", ".join(t["name"] for t in ts), 2)
    api("POST", f"/rest/api/3/issue/{args.key}/transitions", {"transition": {"id": match[0]["id"]}})
    print(f"{args.key} -> {match[0].get('to', {}).get('name', match[0]['name'])}")


def main() -> None:
    p = argparse.ArgumentParser(prog="jira.py", description=__doc__.split("\n\n")[0])
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("check", help="verify credentials")
    s.set_defaults(fn=cmd_check)

    s = sub.add_parser("export", help="create/update an issue from a markdown ticket")
    s.add_argument("ticket", help="markdown file; first line '# <summary>'; images resolved relative to it")
    s.add_argument("--project", help="project key (default: JIRA_PROJECT_KEY)")
    s.add_argument("--update", metavar="KEY", help="update this issue instead of creating one")
    s.add_argument("--type", default="Bug", help="issue type (default: Bug)")
    s.add_argument("--priority", help="Jira priority name, e.g. High")
    s.add_argument("--attach", action="append", help="extra file to attach (repeatable)")
    s.add_argument("--link", action="append", metavar="KEY", help="add a 'Relates' link (repeatable)")
    s.add_argument("--note", help="note.md to update with the **Jira:** line")
    s.add_argument("--dry-run", action="store_true", help="validate and summarise; no network")
    s.add_argument("--print-adf", action="store_true", help="with --dry-run, print the ADF")
    s.add_argument("--allow-local-refs", action="store_true", help="skip the local-reference lint")
    s.set_defaults(fn=cmd_export)

    s = sub.add_parser("import", help="print an issue as markdown and download attachments")
    s.add_argument("key")
    s.add_argument("--out", help="attachment directory (default: $TMPDIR/bugimport-KEY)")
    s.add_argument("--no-download", action="store_true")
    s.add_argument("--max-mb", type=int, default=20, help="skip attachments larger than this")
    s.set_defaults(fn=cmd_import)

    s = sub.add_parser("comment", help="add a markdown comment")
    s.add_argument("key")
    g = s.add_mutually_exclusive_group(required=True)
    g.add_argument("--file")
    g.add_argument("--text")
    s.add_argument("--allow-local-refs", action="store_true")
    s.set_defaults(fn=cmd_comment)

    s = sub.add_parser("transition", help="list or apply transitions")
    s.add_argument("key")
    s.add_argument("--to", help="transition or target status name (or id)")
    s.set_defaults(fn=cmd_transition)

    s = sub.add_parser("sync", help="report Jira state for linked local bugs (read-only)")
    s.add_argument("bugs", nargs="*", help="bug numbers (default: all open and closed bugs with a Jira link)")
    s.add_argument("--chars", type=int, default=200, help="max characters of the latest comment")
    s.set_defaults(fn=cmd_sync)

    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
