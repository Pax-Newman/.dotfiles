# Styling, themes and layout

## House style

Defaults for diagrams produced by this skill. Deviate deliberately, and say why
in a comment when you do.

- **Always set the layout engine explicitly** via `d2-config` (see below).
  Pick by graph shape: `dagre` for flows with a clear beginning and end (DAGs,
  pipelines, state machines, flowcharts), `tala` for architecture and other
  peer-to-peer graphs. Full guidance below.
- **Default theme is `0` (Neutral Default).** Only pick another when the user
  asks or the context demands it.
- **`snake_case` IDs, human labels** — `order_svc: Order Service`. Never put
  spaces in an ID.
- **Group with containers first.** Reach for `layers` only when the sub-diagram
  would make sense on its own.
- **Labels belong on connections** (`a -> b: publishes`), not on floating text
  nodes.
- **Define a `class` rather than repeating a `style.*` more than twice.**
- **Cap a board at roughly 20 nodes.** Past that, drill down with `layers`
  instead of growing the board.
- **No icons unless asked**, or unless the icon carries information the label
  does not.

## In-file configuration: `vars.d2-config`

Prefer configuring the diagram in the file over relying on CLI flags, so that a
plain `d2 file.d2 file.svg` reproduces the intended output for anyone.

```d2
vars: {
  d2-config: {
    layout-engine: tala
    theme-id: 0
    dark-theme-id: 200
    sketch: false
    pad: 20
    center: true
  }
}
```

CLI flags override the file, so a user can still experiment without editing.

## Layout engines — choose by graph shape

`d2 layout` lists the engines. As of **d2 v0.9 all three are bundled**: TALA is
no longer a separate `d2plugin-tala` binary and needs no licence key. Do not go
looking for a plugin to install; older documentation on this is out of date.

The choice is driven by the *shape of the graph*, not by taste:

| Graph shape | Engine |
|-------------|--------|
| A flow with a clear beginning and end — DAGs, pipelines, state machines, decision flowcharts, build/deploy sequences | **`dagre`** |
| A web of peers with no single entry point — service maps, system architecture, network topologies | **`tala`** |
| Very large and dense, where the above still comes out crossing-heavy | **`elk`** |

**`dagre` — for directed flows.** When the graph is a DAG with a distinguished
start and end, dagre's rank-based layout puts the entry point at the top and
flows consistently downward, which matches how the diagram will be read. TALA's
freer placement can park the start node off to one side: in
[`assets/state-machine.d2`](../assets/state-machine.d2) TALA places the initial
state to the *right* of the second state, so the eye enters the diagram in the
wrong place. Reading order matters more than compactness for a flow.

**`tala` — for architecture.** D2's native engine, built for software
architecture diagrams, doing its own edge routing rather than inheriting a
generic graph layout. It excels when there is no canonical direction to impose
and the goal is a balanced, readable arrangement of peers — and it uses
horizontal space well, where dagre tends to produce tall narrow columns.

**`elk`** — orthogonal routing for very large, dense graphs.

If a diagram is genuinely both (a service map that also has a clear
front-to-back request flow), prefer `dagre` and set `direction` explicitly.

Grid containers position their own children, and sequence diagrams are laid out
by D2 directly, so the engine choice is irrelevant for both.

### When a TALA layout looks bad, re-seed before giving up on it

TALA tries several random seeds and keeps the best complete result. Change them
with:

```sh
d2 --layout tala --tala-seeds=4,5,6 in.d2 out.svg
```

`--tala-seeds` is a **CLI flag only** — it is not a valid `d2-config` key, and
writing `tala-seeds:` at the top level of a diagram silently creates a shape
called "tala-seeds" instead. Verified against d2 v0.9.0.

Per-engine options: `d2 layout tala`, `d2 layout elk`, `d2 layout dagre`.

## Themes

`d2 themes` lists them. Light: `0` Neutral Default, `1` Neutral Grey, `3`
Flagship Terrastruct, `4` Cool Classics, `5` Mixed Berry Blue, `6` Grape Soda,
`7` Aubergine, `8` Colorblind Clear, `100`–`105` (Vanilla Nitro Cola, Orange
Creamsicle, Shirley Temple, Earth Tones, Everglade Green, Buttered Toast), `300`
Terminal, `301` Terminal Grayscale, `302` Origami, `303` C4. Dark: `200` Dark
Mauve, `201` Dark Flagship Terrastruct.

Set a separate dark-mode theme with `dark-theme-id` / `--dark-theme`; the SVG
then responds to the viewer's browser preference. Explicit `style.*` values in
the D2 source still apply in both modes, which can look wrong — prefer themes
and classes over hardcoded colours if you care about dark mode.

Docs: https://d2lang.com/tour/themes/

## Style keys

Docs: https://d2lang.com/tour/style/

`style.fill`, `style.fill-pattern`, `style.stroke`, `style.stroke-width`,
`style.stroke-dash`, `style.opacity`, `style.border-radius`, `style.font`,
`style.font-size`, `style.font-color`, `style.bold`, `style.italic`,
`style.underline`, `style.shadow`, `style.3d`, `style.multiple`,
`style.double-border`, `style.animated` (connections), `style.filled`
(arrowheads).

Colours accept hex (`"#e6f2ff"`, quoted because of the `#`) or CSS names.

## Classes

Docs: https://d2lang.com/tour/classes/

```d2
classes: {
  db: {
    shape: cylinder
    style.fill: "#e6f2ff"
  }
  critical: {
    style.stroke: red
    style.stroke-width: 3
  }
}

orders_db.class: db
payments.class: [db; critical]
```

Classes can be imported from a shared file, which is the cleanest way to keep a
house palette across many diagrams.

## Positioning

Docs: https://d2lang.com/tour/positions/

- `near: top-left | top-center | top-right | center-left | center-right |
  bottom-left | bottom-center | bottom-right` pins titles and legends to the
  viewport.
- `near: <object-id>` anchors one object beside another.
- `direction: up | down | left | right` sets flow direction per container.
- Spacing: `grid-gap`, `vertical-gap`, `horizontal-gap` on grid containers.

## Sketch mode

`d2 --sketch` (or `sketch: true` in `d2-config`) renders hand-drawn. Good for
"this is a proposal, not a decision" diagrams.
Docs: https://d2lang.com/tour/sketch/

## Icons

```d2
db: {
  shape: image
  icon: https://icons.terrastruct.com/dev%2Fpostgresql.svg
}
```

Catalogue: https://icons.d2lang.com. With `shape: image` the icon replaces the
shape; on any other shape it sits alongside the label.
