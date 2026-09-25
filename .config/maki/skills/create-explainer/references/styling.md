# Styling: design tokens & theming

The whole document restyles from a `:root` custom-property token set in the
template's `<style>`. Components consume these tokens; because custom properties
pierce shadow DOM via inheritance, changing a token restyles everything —
including the interactive components.

## Tokens

```css
:root {
  --font-sans: system-ui, …;   /* body font stack */
  --font-mono: ui-monospace, …;/* code font stack */

  --bg: #ffffff;               /* page background */
  --surface: #f7f7f8;          /* cards, callouts, code blocks */
  --surface-2: #eeeef0;        /* insets, tracks, inline code */
  --text: #1a1a1e;             /* body text */
  --text-muted: #5c5c66;       /* secondary text, captions */
  --border: #e0e0e4;           /* hairlines */
  --accent: #3b5bdb;           /* links, focus, highlight */
  --accent-contrast: #ffffff;  /* text on accent fills */

  --note/--tip/--warning/--danger; /* call-out colours */
  --correct/--incorrect;           /* quiz feedback colours */

  --radius: 10px; --radius-sm: 6px;
  --space: 1rem; --maxw: 55rem;    /* content column width */
  --figw: min(72rem, 92vw);  /* default figure width (wider than text) */
  --figw-wide: 80vw;         /* figures with the `wide` attribute */
  --shadow: …;
}
```

## Dark mode

A `@media (prefers-color-scheme: dark)` block overrides the same tokens with
dark values. It's automatic — no toggle. To force one mode, delete the dark
block (always light) or move its values into `:root` (always dark).

## Re-theming

- **Change the accent:** set `--accent` (and `--accent-contrast` if the accent
  is light). Links, quiz focus, step bars, and diagram highlights all follow.
- **Widen/narrow the column:** change `--maxw` (keep `--figw` larger so
  figures stay wider than text).
- **Rounder/sharper:** adjust `--radius` / `--radius-sm`.
- **Different fonts:** change `--font-sans` / `--font-mono`. To use a web font,
  add its `<link>` in `<head>` and reference it here.

Keep edits to the `:root` tokens rather than per-element rules — that's the
design-system contract and keeps the components consistent.

## Visual intent

Clean and neutral: system fonts, a restrained neutral palette with a single
accent, generous whitespace, subtle borders and radius. Avoid heavy theming or
branding unless the user asks.
