# Diagrams: `<d2-figure>`

Diagrams are **pre-rendered D2 inlined as SVG**. There is no diagram runtime in
the browser — the `<d2-figure>` component only toggles highlight classes on the
SVG's shape IDs. This keeps the final file self-contained.

For D2 **syntax and authoring**, use the separate `d2lang` skill. This page
covers only the render-and-inline workflow and the component's interactivity.

## Workflow

1. **Author a `.d2` file** — follow the `d2lang` skill for syntax and house
   style. Give shapes meaningful ids; you'll reference them in steps.

   ```d2
   client -> server -> db
   ```

2. **Render to SVG with the `d2` CLI:**

   ```sh
   d2 diagram.d2 -        # SVG to stdout
   d2 diagram.d2 out.svg  # or to a file
   ```

   Always validate/render (never present uncompiled D2):

   ```sh
   d2 fmt diagram.d2 && d2 validate diagram.d2 && d2 diagram.d2 out.svg
   ```

3. **Inline the SVG** inside a `<d2-figure>` (paste the whole `<svg>…</svg>`).

4. **Add `<d2-step>` children** that spotlight shape IDs. Omit steps for a
   plain static figure.

## Finding shape IDs

D2 gives every shape and connection a stable `id` in the SVG output. Open the
rendered SVG and look for `<g id="…">` / element `id` attributes. A shape named
`server` typically has `id="server"`; a connection `client -> server` gets an id
derived from its endpoints. When unsure, grep the SVG:

```sh
grep -o 'id="[^"]*"' out.svg
```

Use those exact strings in the `highlight` attribute.

## Stepping

```html
<d2-figure>
  <svg>…pre-rendered D2…</svg>
  <d2-step highlight="client, server">The client calls the server.</d2-step>
  <d2-step highlight="server, db">The server reads from the database.</d2-step>
</d2-figure>
```

- `highlight` is a comma-separated list of IDs. Listed shapes get the accent
  outline; everything else dims. An empty/absent `highlight` dims nothing.
- The step's inner HTML is the caption shown beneath the diagram.
- The component adds `‹ / ›` navigation and a step counter automatically.

## Size & legibility

- Figures render **wider than the text column** by default (`--figw`,
  `min(72rem, 92vw)`). For very dense diagrams add `wide` (80vw):
  `<d2-figure wide>…</d2-figure>`.
- Every diagram is **click-to-expand**: readers get a zoom view with
  zoom in/out/reset and drag-to-pan, showing the current step's highlights.
  Nothing to author; add `no-zoom` to opt out.
- Keep the SVG's `viewBox` (D2 emits one). The inline SVG and zoom view scale
  to width, so 100% zoom = fit to the view.

## Multi-layout sequences

If steps need genuinely different layouts (not just highlighting), use D2's
native `steps` / `scenarios` / `layers` to pre-render **multiple boards**
(`d2 --target '*' …` or animated SVG), then either inline several `<svg>`s and
swap them, or use one animated SVG. See the `d2lang` skill's composition
reference for producing those boards.

## Styling note

The rendered D2 SVG carries its own fills/strokes. To make diagrams track the
explainer's light/dark theme, render with a neutral/transparent D2 theme, or
post-edit the SVG to use `var(--surface)`, `var(--border)`, `var(--text)` (as
the template's example figure does). Highlight styling always uses
`var(--accent)`.
