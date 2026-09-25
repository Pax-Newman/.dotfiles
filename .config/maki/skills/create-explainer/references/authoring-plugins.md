# Authoring a new plugin

A plugin is one HTML block — a single `<script>` calling the template's built-in
`Explainer.plugin(…)` host — that pulls in a CDN library and initialises it.
The host (in the template's DO-NOT-EDIT runtime) solves dependency loading,
load order, SRI wiring, and DOM-ready timing **once**, so each plugin stays a
small declaration.

## The `Explainer.plugin` contract

```js
Explainer.plugin({
  css: [ { href, integrity?, media? }, … ],  // stylesheets to add to <head>
  js:  [ { src,  integrity? }, … ],          // scripts, loaded IN ORDER
  init: () => { /* run after all js loaded AND DOM ready */ }
});
```

- **`css`** — each entry becomes a `<link rel="stylesheet">`. If `integrity` is
  given, the host also sets `crossorigin="anonymous"`. Use `media` for
  conditional sheets (e.g. a dark-mode theme: `media: "(prefers-color-scheme: dark)"`).
- **`js`** — each entry becomes a `<script>`, loaded **sequentially** (the next
  starts only after the previous fires `onload`). Order matters: list a library
  before the plugin/extension that depends on it. `integrity` sets
  `crossorigin` automatically.
- **`init`** — optional. Runs once **after** every `js` entry has loaded and the
  DOM is parsed, so it can safely scan `document.body`. If there's no `js`, it
  runs as soon as the DOM is ready. If any `js` asset **fails** to load, `init`
  is skipped (the library isn't there to initialise).

All fields are optional; a CSS-only plugin can omit `js` and `init`.

## Failure handling (automatic)

The host wires `onerror` on every asset. If a stylesheet or script fails to load
(offline, blocked CDN, SRI mismatch), the host:

- logs `[explainer] plugin asset failed to load: <url>` to the console, and
- shows a single dismissible banner at the top of the page with **one row per
  failed asset** (styled from `--warning` / `--surface` tokens).

You get this for free — plugins don't implement any error handling. Because the
libraries the kit uses degrade gracefully (KaTeX leaves `$…$` as text,
highlight.js leaves code unstyled), a failed load never breaks the page.

## Recipe

1. **Find the CDN URLs** for the library (js + any css). Pin an exact version.
2. **Compute SRI hashes** for each `https` asset (recommended for integrity):
   ```sh
   curl -sL <url> | openssl dgst -sha384 -binary | openssl base64 -A
   ```
   Prefix the result with `sha384-`. (cdnjs also lists SRI on the file page.)
3. **Write the block** in `assets/plugins/<name>.html`:
   - A leading HTML comment: what it adds, “paste below the PLUGINS marker,
     delete to remove,” and a short **usage example** of the markup it enables.
   - One `<script>` calling `Explainer.plugin({ css, js, init })`.
4. **Verify** the URLs return 200 and the hashes match (see command above).
5. **Add a catalog row** to [plugins.md](./plugins.md) so agents can discover it.

## Conventions

- **One block, self-contained, deletable as a unit.** No edits outside the block
  should be required to add or remove it.
- **Never touch `<head>` or the runtime.** Dependencies go through `css`/`js`.
- **Pin versions and prefer SRI** for reproducible, tamper-evident output.
- **Keep `init` light DOM-aware** — remember CDN libs can't see into shadow
  roots; process `document.body` (see [rich-content.md](./rich-content.md)).
- **Start the file with a usage comment** so pasting the plugin also shows how
  to use it.

## Template to copy

```html
<!-- PLUGIN: <name> <version> — <what it adds>. Paste below the PLUGINS marker.
     Delete this block to remove. Usage:
       <…example markup…>
-->
<script>
Explainer.plugin({
  css: [{ href: "…", integrity: "sha384-…" }],
  js:  [{ src:  "…", integrity: "sha384-…" }],
  init: () => { /* initialise against document.body */ }
});
</script>
```
