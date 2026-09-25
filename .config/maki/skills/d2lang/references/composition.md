# Composition: layers, scenarios and steps

Docs: https://d2lang.com/tour/composition/

A single `.d2` file can hold multiple **boards**. Declare extra boards by
nesting them under one of three keywords. They differ only in what they
inherit.

| Keyword | Inherits from | Use for |
|---------|---------------|---------|
| `layers` | nothing (fresh board) | independent sub-diagrams, drilldown targets |
| `scenarios` | the root board | "what if" variants of the same diagram |
| `steps` | the *previous* step | animated walkthroughs, build-up sequences |

If in doubt: use `steps` to tell a story over time, `scenarios` to show
variations of one system, and `layers` when the sub-diagram would still make
sense in its own file.

```d2
local -> aws.builders: commit
aws.builders -> aws.s3: upload binaries

scenarios: {
  hotfix: {
    aws.workflows -> aws.builders: merge trigger
  }
}

steps: {
  step1: {
    local -> aws.builders: commit
  }
  step2: {
    aws.builders -> aws.s3: upload binaries
  }
}
```

Boards nest: a `steps` board can itself contain `steps`, `scenarios` or
`layers`.

Worked examples: [`assets/steps-walkthrough.d2`](../assets/steps-walkthrough.d2),
[`assets/drilldown.d2`](../assets/drilldown.d2).

## Rendering multi-board diagrams

- **SVG** with `--animate-interval=<ms>` packages every board into one file that
  cycles between them.
- **GIF** does the same; `--animate-interval` defaults to 1000ms for GIF.
- **PNG / PDF / PPTX** cannot animate. They render a single board.

Pick a board with `--target`:

```sh
d2 --target=''                 in.d2 out.png   # root board only
d2 --target='layers.auth'      in.d2 out.png   # just that board
d2 --target='layers.auth.*'    in.d2 out.svg   # that board and all its children
d2 --target='*'                in.d2 out.svg   # everything (the default)
```

To get one static image per step, loop over the board paths with `--target`.

## Interactive: tooltips and links

Docs: https://d2lang.com/tour/interactive/

```d2
x: {
  tooltip: Total abstinence is easier than perfect moderation.
}

homepage: {
  link: "https://example.com"
}
```

- `tooltip` shows on hover in SVG. Keep it to plain text — rich markdown is not
  reliably rendered in the hover box.
- `link` makes the shape clickable. **Quote URLs containing `#`**, or D2 treats
  the rest of the line as a comment.
- Static exports cannot hover or click, so D2 numbers each interactive shape and
  appends a legend mapping numbers to tooltip/link text. Force that appendix on
  SVG too with `--force-appendix`.

## Linking between boards

Docs: https://d2lang.com/tour/linking/

A `link` can point at a board path instead of a URL, producing clickable
drilldown. Board paths are written from the root:

```d2
auth_service: {
  link: layers.auth_detail
}

layers: {
  auth_detail: {
    login -> token_service -> db
  }
}
```

Links between boards only work in SVG viewed in a browser. Note that D2
generates the navigation itself — you do not need to host anything.
