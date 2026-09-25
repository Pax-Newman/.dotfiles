# Plugins: adding optional libraries

The base template ships with **no** math or code libraries — just the core
components. Optional CDN-backed features are **plugins**: one self-contained
block you paste in, and delete as a unit to remove.

## How to add a plugin

1. Pick the plugin from the catalog below.
2. Copy the **entire** block from `assets/plugins/<name>.html`.
3. Paste it into the template **below the `<!-- ===== PLUGINS … ===== -->`
   marker** (which sits just under the component runtime, above `</body>`).
4. That's it — the block declares its own CDN dependencies (with SRI hashes)
   and initialisation via the built-in `Explainer.plugin(…)` host. No `<head>`
   edits, no hashes to manage.

To **remove** a plugin later, delete its whole block. Nothing else references it.

## Catalog

| Plugin | File | Adds | Reach for it when |
|--------|------|------|-------------------|
| katex | `assets/plugins/katex.html` | KaTeX math via `$…$` / `$$…$$` / `\(…\)` / `\[…\]` | your content has math |
| highlightjs | `assets/plugins/highlightjs.html` | highlight.js code highlighting for `<pre><code class="language-x">` | your content has code |

Each plugin file starts with a usage comment showing the markup it enables.
Math and code must live in **light DOM** (page body or a component slot) — see
[rich-content.md](./rich-content.md) for the shadow-DOM caveat.

## Notes

- Plugins load their scripts dynamically and run after the DOM is ready, so
  they process content already on the page.
- Multiple plugins coexist; paste as many blocks as you need.
- Want to add a *new* kind of plugin (not in the catalog)? See
  [authoring-plugins.md](./authoring-plugins.md).
