# D2 syntax reference

Full language reference. For layout/theming see [styling](./styling.md), for
multi-board diagrams see [composition](./composition.md), for sequence diagrams
see [sequence-diagrams](./sequence-diagrams.md).

Docs: https://d2lang.com/tour/intro/

## Shapes and connections

```d2
# a comment
x
y: A label      # id `y`, label "A label"
x -> y: calls   # connection with a label
x -> y -> z     # chained
a <-> b         # bidirectional
a <- b          # reverse
a -- b          # undirected line
```

Declaring a connection declares its endpoints implicitly, so `x -> y` alone is
a valid diagram.

### Containers and scope

```d2
aws.region.vpc.subnet        # nested containers, created implicitly
aws: {
  region: {
    vpc
  }
}
aws.region.vpc -> onprem     # reference across containers with dotted paths
```

Inside a container, `_` refers to the parent scope:

```d2
cluster: {
  node
  node -> _.gateway          # connects to `gateway` at the level above
}
gateway
```

Connections cannot cross into a container from outside using a bare id — always
use the full dotted path.

### Identifiers, labels and quoting

- IDs are what you reference; labels are what is drawn. `id: Label` sets both.
- Prefer `snake_case` IDs with a human label rather than spaces in the ID.
- Quote any ID containing spaces or punctuation: `"my node"`.
- **`#` starts a comment.** A URL containing a fragment must be quoted, or
  everything after `#` is silently dropped:
  ```d2
  docs.link: "https://example.com/page#section"
  ```
- Reserved keywords (`shape`, `label`, `style`, `link`, `class`, `layers`,
  `steps`, `scenarios`, `grid-rows`, `vars`, `classes`, `near`, `width`,
  `height`, `icon`, `tooltip`, `direction`, `constraint`) cannot be used as
  bare IDs. Quote them if you need them as names.
- `;` separates declarations on one line: `a; b; c`.

## Shape catalogue

`rectangle` (default), `square`, `page`, `parallelogram`, `document`,
`cylinder`, `queue`, `package`, `step`, `callout`, `stored_data`, `person`,
`diamond`, `oval`, `circle`, `hexagon`, `cloud`, `text`, `code`, `image`,
`class`, `sql_table`, `sequence_diagram`.

## Object keys

| Key | Meaning |
|-----|---------|
| `shape` | one of the catalogue above |
| `label` | drawn text (defaults to the ID) |
| `icon` | image URL; with `shape: image` the icon *is* the shape |
| `style.*` | see [styling](./styling.md) |
| `class` | apply a named class, or `[a; b]` for several |
| `near` | `top-left`…`bottom-right`, or another object's id |
| `width` / `height` | fixed pixel size |
| `link` | URL, or a board path for drilldown |
| `tooltip` | hover text in SVG |
| `constraint` | `sql_table` column constraint |
| `direction` | `up`/`down`/`left`/`right`, per container |

## Connection details

Connections take the same style keys as shapes, plus arrowheads:

```d2
svc -> store: query {
  source-arrowhead.label: 1
  target-arrowhead: {
    shape: diamond
    style.filled: true
  }
}
```

Arrowhead shapes: `triangle`, `arrow`, `diamond`, `circle`, `box`, `cf-one`,
`cf-many`, `cf-one-required`, `cf-many-required` (the `cf-*` set is crow's foot,
for ER diagrams).

Repeated connections between the same pair are addressed by index:

```d2
a -> b: first
a -> b: second
(a -> b)[0].style.stroke-dash: 3
```

## Text, markdown, code and LaTeX

```d2
explanation: |md
  ## Heading
  - bullet
  - **bold**
|

formula: |latex
  \sum_{i=0}^n i^2
|

snippet: |go
  func main() {}
|

caption: {shape: text; label: Free-floating text}
```

The block delimiter can be widened (`|||md ... |||`) when the content itself
contains a `|`.

## Variables and substitution

```d2
vars: {
  env: production
  primary: "#4a90d9"
}

api: ${env} API
api.style.fill: ${primary}
```

Variables are lexically scoped; a `vars` block inside a container shadows the
outer one. `vars.d2-config` is special — see [styling](./styling.md).

## Globs

Globs apply a key to many objects at once:

```d2
*.style.fill: "#eeeeee"     # every object at this level
**.style.stroke: black      # every object, recursively
(* -> *)[*].style.stroke-width: 2   # every connection
```

Filters restrict a glob to objects that already have a given key/value:

```d2
*: {
  &shape: circle            # only objects whose shape is circle
  style.fill: red
}
*: {
  !&shape: circle           # only objects whose shape is NOT circle
  style.fill: blue
}
```

**Globs are applied to everything declared after them**, including objects
created later in the file and objects created by imports. Put them near the top
if you want them to catch everything, or after a block to scope them.

## Removing and suspending

```d2
z: {a; b}
z.a: null       # delete `a` from the diagram

heavy: {suspend}   # declared but not rendered
heavy: {unsuspend} # bring it back (useful across boards/imports)
```

## Imports

```d2
# lib.d2
shared: {shape: cylinder}
```

```d2
...@lib          # spread: merge lib.d2's contents into this scope
other: @lib      # value: nest lib.d2 under `other`
one: @lib.shared # import a single object
```

The `.d2` extension is omitted. Imports are resolved relative to the importing
file. Use imports to keep large diagrams and shared style/class definitions in
separate files.

## Special diagram types

- **Sequence diagrams** — `shape: sequence_diagram`. Different scoping and
  ordering rules; see [sequence-diagrams](./sequence-diagrams.md).
- **SQL tables** — `shape: sql_table`, columns as `name: type {constraint: …}`
  with `primary_key`, `foreign_key`, `unique`. Connect columns directly:
  `orders.customer_id -> customers.id`. Worked example:
  [`assets/er-schema.d2`](../assets/er-schema.d2).
  Docs: https://d2lang.com/tour/sql-tables/
- **UML classes** — `shape: class`, fields as `name: type`, methods as
  `name(args): return`. Visibility prefixes `+ - #`.
  Docs: https://d2lang.com/tour/uml-classes/
- **Grids** — `grid-rows` / `grid-columns` / `grid-gap` on a container lays its
  children out as a matrix and ignores connections between them. Worked
  example: [`assets/grid-dashboard.d2`](../assets/grid-dashboard.d2).
  Docs: https://d2lang.com/tour/grid-diagrams/

## Cheat sheet

Official one-page PDF: https://d2lang.com/tour/cheat-sheet/
