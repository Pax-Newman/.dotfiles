# Rich content: code & math

Code highlighting and math typesetting come from the **katex** and
**highlightjs** plugins (the base template ships with neither — see
[plugins.md](./plugins.md) to add them). Both are CDN libraries that scan the
page after load. The critical constraint is **where** that content lives.

## The shadow-DOM caveat

KaTeX and highlight.js scan the **light DOM** (the normal page body) for target
classes/delimiters. They **cannot see into closed/shadow roots**. Therefore:

- Put code and math in the page body (inside `<main>`, `<call-out>`,
  `<reveal-block>` — anywhere in light DOM), and they auto-process.
- The interactive components render author content via **slots**, and slotted
  content stays in light DOM, so it's still reachable. Content you write
  *between* a component's tags is fine.
- Do **not** hand-build shadow-DOM markup containing math/code and expect it to
  render — it won't. (This is why the kit's components keep author rich content
  in slots.)

## Code — highlight.js 11.11.2

Use a fenced `<pre><code>` with a `language-*` class:

```html
<pre><code class="language-js">const x = 42;</code></pre>
```

Requires the **highlightjs** plugin ([plugins.md](./plugins.md)).

- The plugin runs `hljs.highlightAll()` once loaded.
- It ships the `github` theme (light) and `github-dark` (dark, via
  `prefers-color-scheme`). Swap the theme CSS href in the plugin block to change it.
- Inline `<code>` without a `language-*` class is styled but not tokenised.

## Math — KaTeX 0.18.4

Requires the **katex** plugin ([plugins.md](./plugins.md)). Auto-render uses
these delimiters:

| Delimiter | Mode |
|-----------|------|
| `$…$` | inline |
| `$$…$$` | display |
| `\(…\)` | inline |
| `\[…\]` | display |

```html
<p>The area is $\pi r^2$.</p>
<p>$$\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$$</p>
```

`throwOnError:false` means a bad expression renders in red rather than breaking
the page. If a literal `$` appears in prose (e.g. a price) and gets eaten,
escape it as `\$`.

## Adding / removing these libraries

Both are plugins: paste one block to add, delete the block to remove. See
[plugins.md](./plugins.md) for the catalog and copy rule, and
[authoring-plugins.md](./authoring-plugins.md) to add a new library of your own.

### Pinned versions (verified 2026-09-15)

- KaTeX `0.18.4` — jsdelivr, css + js + `contrib/auto-render.min.js`, with SRI.
- highlight.js `11.11.2` — cdnjs, `highlight.min.js` + theme css.
