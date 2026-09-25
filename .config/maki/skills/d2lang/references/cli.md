# CLI reference and verification

`d2 v0.9.0`. Check with `d2 --version`; older versions lack bundled TALA,
`d2 validate`, and some flags below.

## The verify loop (mandatory)

Never hand back D2 that has not been compiled.

```sh
d2 fmt diagram.d2 \
  && d2 validate diagram.d2 \
  && d2 diagram.d2 diagram.svg
```

Fix every error and re-run until all three pass. `d2 validate` catches syntax
errors; only a real render catches layout errors (a diagram can be valid D2 and
still fail to lay out).

If `d2` is not on `PATH`, say so explicitly in the reply and mark the output as
unverified. Do not skip the step silently.

## Core usage

```sh
d2 in.d2                 # writes in.svg
d2 in.d2 out.svg
d2 --watch in.d2         # live-reloading local server
d2 fmt in.d2             # format in place
d2 fmt --check in.d2     # non-zero exit if unformatted (CI)
d2 validate in.d2
d2 play in.d2            # open in the online playground
d2 themes                # list theme ids
d2 layout                # list layout engines
d2 layout tala           # options for one engine
```

Use `-` for stdin/stdout: `cat in.d2 | d2 - - > out.svg`, with
`--stdout-format` to pick the format when writing to stdout.

## Output formats

| Extension | Interactive | Animated | Notes |
|-----------|-------------|----------|-------|
| `.svg` | yes | with `--animate-interval` | the default; best choice |
| `.png` | no | no | max 32768px per dimension; gets a tooltip/link appendix |
| `.gif` | no | yes | `--animate-interval` defaults to 1000ms |
| `.pdf` | no | no | multi-page for multi-board |
| `.pptx` | no | no | one slide per board |
| `.txt` | no | no | ASCII art; `--ascii-mode standard\|extended` |

## Flags by purpose

**Rendering**
`-t, --theme <id>`, `--dark-theme <id>`, `-s, --sketch`, `--pad <px>`,
`-c, --center`, `--scale <n>`, `--font-regular/-bold/-italic/-mono <ttf>`.

**Layout**
`-l, --layout <dagre|elk|tala>`, `--tala-seeds <n,n,n>`, `--timeout <secs>`
(raise it for large diagrams; default 120).

**Boards**
`--target <path>` (`''` for root only, `'layers.x.*'` for a board and its
children, `'*'` for everything), `--animate-interval <ms>`,
`--force-appendix` (tooltip/link appendix on SVG too).

**Embedding in HTML**
`--no-xml-tag` (drop the `<?xml?>` prolog), `--salt <str>` (unique element IDs
so several diagrams can share one HTML document), `-b, --bundle` (inline
assets, on by default), `--omit-version`, `-c, --center`, `--scale`.

**Iteration**
`-w, --watch` with `--host`/`--port`/`--browser`, `--img-cache`, `-d, --debug`.

Most flags have an environment-variable equivalent (`D2_LAYOUT`, `D2_THEME`,
`D2_SKETCH`, …). Prefer `vars.d2-config` in the file over environment variables
so output is reproducible — see [styling](./styling.md).

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Half a URL disappears | `#` starts a comment | quote the URL: `link: "https://x/y#z"` |
| `"..." needs a value` | keyword used with no/invalid value | check the key is valid for that context |
| `invalid position with infinity value` | usually a sequence-diagram span written as a block | use the endpoint form `actor.span -> other` |
| A key rendered as a shape named after itself | the key is not valid there | e.g. `tala-seeds` is CLI-only, not a `d2-config` key |
| Connection silently creates a new node | endpoint id typo, or missing container path | use the full dotted path `a.b.c` |
| Object appears twice | same label, different ids | give an explicit shared id |
| Tooltips missing in PNG | static formats cannot hover | expected: read the numbered appendix |
| Animation missing | non-SVG/GIF output, or no `--animate-interval` | render to `.svg`/`.gif` with the flag |
| Only one board exported | default `--target` behaviour for static formats | pass `--target` per board |
| Dense, crossing edges | layout | on `tala` try `--tala-seeds`, then `--layout elk` |
| Flow does not start at the top, or reads sideways | `tala` on a graph with a clear start/end | switch to `--layout dagre` |
| Times out on a big diagram | default 120s | raise `--timeout` |
| Diagram sprawls off-screen | too many nodes on one board | split with `layers` |
