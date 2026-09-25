# Example catalogue

Ready-made, verified diagrams in [`../assets/`](../assets/). Every file renders
cleanly and is `d2 fmt` clean.

| Asset | Use when | Demonstrates |
|-------|----------|--------------|
| [`architecture.d2`](../assets/architecture.d2) | showing how services, stores and external systems fit together | containers, classes, shape vocabulary, TALA layout |
| [`sequence.d2`](../assets/sequence.d2) | showing an ordered exchange of messages between participants | `sequence_diagram`, actor ordering, spans, groups, async messages, notes |
| [`er-schema.d2`](../assets/er-schema.d2) | documenting database tables and their relationships | `sql_table`, constraints, cardinality via arrowhead labels |
| [`steps-walkthrough.d2`](../assets/steps-walkthrough.d2) | explaining a process one stage at a time | `steps` boards, cumulative inheritance, highlighting the active node |
| [`drilldown.d2`](../assets/drilldown.d2) | an overview that links through to detail | `layers` boards, `link` to a board path, tooltips |
| [`state-machine.d2`](../assets/state-machine.d2) | states and transitions, or a branching decision flow | diamonds, self-loops, labelled transitions, terminal states |
| [`grid-dashboard.d2`](../assets/grid-dashboard.d2) | cards in a tidy matrix rather than a connected graph | `grid-columns`/`grid-rows`/`grid-gap`, nested grids |

## How to use one

1. Read the asset. Its header comment states what it is for and the exact
   command to render it.
2. Copy it to the user's target path. **Never edit files in `assets/` in
   place** — they are templates.
3. Rename ids and labels to the user's domain, and delete everything not
   needed. The examples share one order/payment domain so that the ids are
   obviously placeholders.
4. Run the verify loop from [cli](./cli.md).

The assets demonstrate the engine-by-graph-shape rule from
[styling](./styling.md), and each header says why it picked what it did:

- `architecture.d2`, `er-schema.d2`, `drilldown.d2` use **`tala`** — peer
  graphs with no single entry point.
- `state-machine.d2`, `steps-walkthrough.d2` use **`dagre`** — flows with a
  clear beginning and end, where the entry point belongs at the top.
- `sequence.d2` and `grid-dashboard.d2` set **no engine at all**, because
  sequence diagrams are laid out by D2 itself and a grid positions its own
  children. Configuring one would be misleading.
