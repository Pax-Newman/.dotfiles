---
name: d2lang
description: Use when the user wants to create, edit, or explain a diagram in D2 (d2lang.com) — architecture diagrams, sequence diagrams, flowcharts, ER/SQL schemas, grid dashboards, or animated/interactive multi-board diagram compositions.
---

# D2 Diagrams

D2 (https://d2lang.com) is a declarative diagram-as-code language. Write a `.d2`
file, render it with the `d2` CLI. Prefer a real `.d2` file over inline ASCII
art whenever the user wants a reusable, renderable diagram.

Reference files live beside this one under
`~/.config/maki/skills/d2lang/`; read them with the read tool as directed below.

## Core syntax

```d2
# a comment
x -> y: label       # connection with a label
x -> y -> z         # chained
a <-> b             # bidirectional
a.b.c               # nested containers

server: {
  shape: cylinder
  style.fill: "#e6f2ff"
}

server -> client: response
```

Common shapes: `rectangle` (default), `cylinder`, `queue`, `package`, `person`,
`diamond`, `oval`, `circle`, `hexagon`, `cloud`, `document`, `text`, `class`,
`sql_table`, `sequence_diagram`, `image`.

Common keys: `shape`, `label`, `icon`, `style.*`, `class`, `near`, `link`,
`tooltip`.

That is enough for a simple diagram. For anything more, open a reference.

## Workflow

1. **Clarify what kind of diagram it is** — architecture, sequence, ER schema,
   state machine, grid. This picks the shape vocabulary and the reference to
   read. Check [examples](./references/examples.md) first: starting from a
   working asset is usually faster than writing from scratch.

2. **Decide on structure.** Static single board, or multiple boards for a
   walkthrough (`steps`) or drilldown (`layers`)? Do tooltips and links add
   information, or just clutter? Set the layout engine by graph shape: `dagre`
   for flows with a clear beginning and end, `tala` for architecture and other
   peer graphs.

3. **Write the `.d2` file**, following the house style in
   [styling](./references/styling.md). In short: `snake_case` ids with human
   labels, containers before layers, labels on connections, a `class` instead
   of a repeated style, and roughly 20 nodes maximum per board.

4. **Verify — this is not optional.**
   ```sh
   d2 fmt diagram.d2 && d2 validate diagram.d2 && d2 diagram.d2 diagram.svg
   ```
   Fix every error and re-run. A diagram can be valid D2 and still fail to lay
   out, so the render must actually succeed. Never present D2 you have not
   compiled. If `d2` is not installed, say so explicitly and mark the output
   unverified rather than skipping this silently.

5. **Report** the output path and how to re-render, plus `d2 --watch file.d2`
   if the user is likely to iterate.

## References

| Read | When |
|------|------|
| [examples](./references/examples.md) | starting any diagram — catalogue of ready-made assets to copy and adapt |
| [syntax](./references/syntax.md) | you need anything beyond the core syntax above: containers, scoping, vars, globs, imports, arrowheads, markdown/code/LaTeX blocks, SQL tables, UML classes, grids |
| [composition](./references/composition.md) | the diagram needs multiple boards — `layers`/`scenarios`/`steps`, animation, `--target`, tooltips and drilldown links |
| [sequence-diagrams](./references/sequence-diagrams.md) | writing a `sequence_diagram` — it has its own scoping and ordering rules |
| [styling](./references/styling.md) | choosing a layout engine or theme, styling, classes, `d2-config`, positioning, icons — **and the house style** |
| [cli](./references/cli.md) | rendering, output formats, flags, embedding SVG in HTML, or something failed and you need the troubleshooting table |

Ready-made diagrams are in [`assets/`](./assets/). They are templates to copy
and adapt — never edit them in place.
