# Component reference

Every block is a custom element defined in the template's runtime script. All
consume the CSS design tokens (see [styling.md](./styling.md)) and inherit
light + dark mode automatically.

---

## `<call-out>`

Styled admonition with an icon and coloured left border.

- **Attributes:** `type` = `note` | `tip` | `warning` | `danger` (default
  `note`); `title` (optional, defaults to the capitalised type).
- **Content:** default slot — light-DOM body, so `code` and `$math$` render.

```html
<call-out type="warning" title="Careful">
  Don't run this in production.
</call-out>
```

---

## `<reveal-block>`

Click-to-expand disclosure (native `<details>` under the hood).

- **Attributes:** `summary` — the clickable label (default `Reveal`).
- **Content:** default slot.

```html
<reveal-block summary="Show the derivation">
  Because $a^2 + b^2 = c^2$ …
</reveal-block>
```

---

## `<flip-card>`

Two-sided card; click to flip with a 3D transition.

- **Slots:** `front` and `back` (use `<span slot="front">` / `slot="back">`).

```html
<flip-card>
  <span slot="front">Capital of France?</span>
  <span slot="back">Paris</span>
</flip-card>
```

---

## `<quiz-mc>` + `<quiz-option>`

Multiple-choice question. Locks after the first answer and shows feedback.

- **`<quiz-mc>` attributes:** `question` — the prompt text.
- **`<quiz-option>`:** one child per choice; add the boolean `correct`
  attribute to exactly one.
- **Event:** emits `quiz-answered` (bubbles, composed) with
  `detail.correct: boolean` when first answered. `<progress-tracker>` listens
  for it.

```html
<quiz-mc question="2 + 2 = ?">
  <quiz-option>3</quiz-option>
  <quiz-option correct>4</quiz-option>
  <quiz-option>5</quiz-option>
</quiz-mc>
```

Option inner HTML is copied into the rendered button, so inline markup is fine.
(Note: options render into shadow DOM buttons, so put `$math$`/code needing CDN
processing in prose, not inside options.)

---

## `<step-through>` + `<step-item>`

Next/prev walkthrough with a progress bar and arrow-key support (focus it, then
`←` / `→`).

- **Content:** one `<step-item>` per step; inner HTML is shown one at a time.

```html
<step-through>
  <step-item>Parse the tokens.</step-item>
  <step-item>Build the AST.</step-item>
  <step-item>Emit code.</step-item>
</step-through>
```

---

## `<progress-tracker>`

Sticky score bar. Place **one** instance (usually near the end of `<main>`).
Listens page-wide for `quiz-answered` and renders a running `correct / total`
score and completion bar. Zero attributes.

```html
<progress-tracker></progress-tracker>
```

---

## `<d2-figure>` + `<d2-step>`

Interactive diagram over an inlined, pre-rendered D2 SVG. See
[diagrams.md](./diagrams.md) for the full workflow. Summary:

- **Content:** an inline `<svg>` (the rendered D2 output) plus zero or more
  `<d2-step>` children.
- **`<d2-step>` attribute:** `highlight` — comma-separated D2 shape IDs to
  spotlight for that step; other shapes dim. The step's inner HTML becomes the
  caption.
- **Static mode:** omit `<d2-step>`s to show a plain figure with no controls.
- Author writes **zero** JS; the component owns highlight/dim/step navigation.

```html
<d2-figure>
  <svg>…pre-rendered D2…</svg>
  <d2-step highlight="server, db">The server hits the database.</d2-step>
  <d2-step highlight="db -> cache">Then the cache is filled.</d2-step>
</d2-figure>
```

The SVG lives in light DOM, so the component toggles a `.d2-hi` class directly
on elements with those `id`s — no shadow-DOM barrier.

---

## Figure sizing & click-to-zoom (automatic)

Applies to `<d2-figure>`, and to `<img>`, `<svg>` and `<figure>` placed
directly in `<main>`. No markup needed.

- **Size:** figures are wider than the text column (`--figw`,
  `min(72rem, 92vw)`) and centred on it.
- **`wide` attribute:** `<d2-figure wide>` / `<img wide>` / `<figure wide>`
  goes up to `--figw-wide` (80vw) for very dense figures.
- **Click to expand:** every `<img>`/`<svg>` in `<main>` opens a modal zoom
  view (native `<dialog>`): − / + / Reset buttons, Ctrl/⌘+wheel and `+ - 0`
  keys zoom (50–400%), drag or scroll to pan, Esc / × / backdrop closes.
  Keyboard: figures are focusable; Enter/Space opens.
- The zoom view shows the diagram's **current step** (highlights and caption).
  For images it shows the `<figcaption>`, or `alt` if there isn't one.
- **`no-zoom` attribute:** add it to an element (or any ancestor) to opt out.

```html
<figure wide>
  <img src="arch.png" alt="System architecture">
  <figcaption>Everything talks to the queue.</figcaption>
</figure>
<img src="logo.svg" alt="" no-zoom>
```
