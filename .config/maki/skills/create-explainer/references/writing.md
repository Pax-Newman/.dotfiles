# Writing a good explainer

The kit gives you the blocks; this is how to use them well. Content quality
matters more than which components you reach for.

## Voice

- Write with the clarity and flow of **Martin Kleppmann** — engaging, in
  **classic style**: lead with the idea, make the reader *see* the thing rather
  than admire the prose. Concrete over abstract.
- **Smooth transitions.** Each section should hand off to the next; avoid a
  disconnected list of facts. The reader should feel carried along.
- Don't assume a fixed level of prior knowledge. Offer a **deep background for
  beginners that a knowledgeable reader can skip**, then narrow to what's
  directly relevant.

## A structure that works

Not mandatory, but a reliable shape for explaining a system, concept, or change:

1. **Background** — the existing world the reader needs in order to follow.
   Explore the surrounding context broadly; include the beginner-friendly layer
   plus the narrowly-relevant layer.
2. **Intuition** — the *essence*, not the full detail. Use concrete examples
   with **toy data**. Lean on figures and `<d2-figure>` diagrams here.
3. **Detail / walkthrough** — the actual mechanics, grouped and ordered so they
   build on each other rather than dumped in source order.
4. **Quiz** — check understanding (see below).

Make it **one long page** with section headings. A short table of contents up
top helps navigation; on a phone it should still read cleanly (the template's
tokens are already responsive).

## Diagrams

- Pick a **small number of diagram families** and reuse them throughout to
  explain different cases — a reader who learns to read one diagram gets fluent.
  Useful families: a simplified view of the **UI** the user sees (for UI
  changes), and a **system/data-flow diagram** between components.
- **Include example data** in system diagrams — show a real value flowing
  through, not just labelled boxes.
- **Never use ASCII diagrams.** Use `<d2-figure>` (pre-rendered D2 SVG; see
  [diagrams.md](./diagrams.md)) or simple semantic HTML. Use HTML lists for
  lists of things.

## Quizzes

Use `<quiz-mc>` and add a `<progress-tracker>`. Aim for questions that:

- are **medium difficulty** — you should have to understand the substance to
  answer, but they are **not gotchas** or trivia;
- test comprehension of the core ideas, so the reader can confirm they actually
  understood, not just recall a keyword;
- give **useful feedback** on the answer (the component already reveals the
  correct option — write options that make the *why* clear).

Five questions is a good default for a substantial explainer.

## Callouts

Use `<call-out>` for key concepts and definitions, important edge cases, and
gotchas — the things a reader should not miss. Don't over-use them; if
everything is a callout, nothing is.

## Code

Put code in `<pre><code>` (light DOM) and add the **highlightjs** plugin
([plugins.md](./plugins.md)) if you want highlighting. `<pre>` preserves
newlines; never hand-roll a styled `<div>` for code without `white-space:
pre`/`pre-wrap`, or the browser collapses the newlines.
