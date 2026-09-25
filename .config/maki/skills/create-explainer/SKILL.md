---
name: create-explainer
description: Use when the user wants to build a single-file HTML explainer or quiz — interactive lessons with multiple-choice questions, step-throughs, reveals, flip cards, callouts, code/math/diagrams, and progress tracking.
---

# Explainer Kit

A building-block kit for authoring one self-contained HTML explainer or quiz.
Everything is pre-written: a CSS design system, interactive web components, and
CDN hooks for code/math. Your job: **copy the template, then fill in content.**

Reference files live beside this one under
`~/.config/maki/skills/create-explainer/`; read them with the read tool only
when a task below points you there.

## Workflow

1. **Copy** `assets/explainer-template.html` to the output location. Never edit
   it in place — it is the reusable template.
2. **Write well, don't just assemble.** How you write matters more than which
   blocks you pick. Before filling in content, read
   [writing.md](./references/writing.md) for voice, structure (background →
   intuition → detail → quiz), diagram philosophy, and quiz design.
3. **Edit only what is marked.** Everything inside `<header>`, `<main>`, and
   `<footer>` is yours (look for `EDIT:` markers). The template ships one live
   example of every block, each with a one-line usage comment — replace them
   with your content and delete the ones you don't need.
4. **NEVER touch the component runtime.** The block below
   `===== DO NOT EDIT BELOW THIS LINE =====` defines all the web components.
   Preserve it verbatim.
5. **Add plugins if needed.** The base template ships with **no** math or code
   library. Need math or syntax-highlighted code? Add a plugin: copy one block
   from `assets/plugins/` below the `PLUGINS` marker — see
   [plugins.md](./references/plugins.md).
6. **Output rule:** a single self-contained `.html` file. It may fetch plugin
   libraries (KaTeX / highlight.js) from a CDN at runtime; D2 diagrams are
   inlined SVG and need no runtime.

## Blocks at a glance

| Block | One-line example |
|-------|------------------|
| Call-out | `<call-out type="tip" title="Note">…</call-out>` (type: note\|tip\|warning\|danger) |
| Reveal | `<reveal-block summary="Show answer">…</reveal-block>` |
| Flip card | `<flip-card><span slot="front">Q</span><span slot="back">A</span></flip-card>` |
| Quiz | `<quiz-mc question="…"><quiz-option correct>…</quiz-option>…</quiz-mc>` |
| Step-through | `<step-through><step-item>…</step-item>…</step-through>` |
| Progress | `<progress-tracker></progress-tracker>` (one instance; tracks quizzes) |
| Diagram | `<d2-figure><svg>…</svg><d2-step highlight="id1, id2">…</d2-step></d2-figure>` |
| Image / figure | `<img>` or `<figure wide><img><figcaption>…</figure>` — wider than text, click-to-zoom (`no-zoom` opts out) |
| Code | `<pre><code class="language-python">…</code></pre>` (needs **highlightjs** plugin) |
| Math | `$inline$` or `$$display$$` (needs **katex** plugin) |

Code and math must be in **light DOM** (normal page body) or inside a
component **slot** — never buried where the CDN libs can't scan them. Slotted
content works; the components are built for it.

## References (read on demand)

| Read | When |
|------|------|
| [writing.md](./references/writing.md) | **read before writing** — voice, section structure, diagram & quiz craft |
| [components.md](./references/components.md) | full attributes, slots, and events for every component |
| [plugins.md](./references/plugins.md) | adding optional libraries (math, code) \u2014 catalog + copy rule |
| [authoring-plugins.md](./references/authoring-plugins.md) | creating a new plugin of your own |
| [rich-content.md](./references/rich-content.md) | code/math specifics + shadow-DOM caveats |
| [diagrams.md](./references/diagrams.md) | making a `<d2-figure>`: author `.d2` → render with `d2` CLI → inline SVG → add steps |
| [styling.md](./references/styling.md) | design tokens, theming, dark mode, restyling the look |
