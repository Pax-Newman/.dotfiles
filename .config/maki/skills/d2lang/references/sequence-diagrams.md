# Sequence diagrams

Docs: https://d2lang.com/tour/sequence-diagrams/

Set `shape: sequence_diagram` on a container. Everything inside then follows two
rules that apply nowhere else in D2:

1. **Shared scope** — all descendants refer to the same actors, even inside
   nested groups. Elsewhere, nesting creates new scopes.
2. **Order matters** — messages are drawn in the order written. Everywhere else
   in D2, declaration order does not affect layout.

Because order matters, **declare the actors first** if you care about their
left-to-right arrangement.

Sequence diagrams are positioned by D2 itself and **ignore the layout engine**,
so `dagre`/`elk`/`tala` makes no difference to a pure sequence diagram.

Worked example: [`assets/sequence.d2`](../assets/sequence.d2).

```d2
chat: {
  shape: sequence_diagram

  alice
  bob

  alice -> bob: hi
  bob -> alice: hello
}
```

## Features

**Async / dashed messages** — `a --> b: notify` versus solid `a -> b: request`.

**Self messages** — `a -> a: recompute`.

**Spans (activation bars)** — a span is written as an *endpoint*,
`actor.span_name`, not as a block wrapping messages:

```d2
seq: {
  shape: sequence_diagram
  client; server; db

  client -> server: request
  server.query -> db: SELECT
  db -> server.query: rows
  server -> client: response
}
```

> Writing a span as a block that contains messages
> (`server.query: { server -> db }`) compiles but fails at layout with an
> `invalid position with infinity value` error. Use the endpoint form.

**Groups** — a labelled box around a run of messages. Any non-`sequence_diagram`
container inside works as a group:

```d2
seq: {
  shape: sequence_diagram
  alice; server

  "auth flow": {
    alice -> server: login
    server -> alice: token
  }
}
```

**Notes** — a lone unconnected object attached to an actor, placed in message
order:

```d2
alice."remembers the session"
```

**Lifespan ordering** — actors are sometimes called participants elsewhere; same
concept.

## Combining with the rest of D2

A sequence diagram is an ordinary object, so it can be styled, nested inside a
`layers`/`steps` board (e.g. to animate a protocol message by message), linked
and tooltipped like anything else.
