# Build order

Part of the backend blueprint — see the root `AGENTS.md` for the overall
procedure. This file only applies once the user separately asks you to
actually build the backend — a distinct, later request from the spec
interview (`INTERVIEW.md`), not something to slide into once the spec is
written.

Even when asked to build the whole thing in one go, **do not implement
the entire spec in one pass.** Work through it one phase at a time,
finishing (and testing) each phase before starting the next. The order
below is dependency-driven, not product-specific — it holds regardless of
what this particular backend actually does, because each phase only
depends on what a prior phase already built, and nothing is ever left
live-but-unprotected in between:

1. `rules/engineering-standards.md` — scaffold: stack, project structure,
   deployment skeleton, secrets loading, and the test runner/CI harness
   itself (not tests yet — just the harness, so every phase after this
   can add its own tests immediately instead of deferring them).
2. `rules/observability.md`, baseline only — correlation-id middleware,
   structured logging conventions, health-check routes. Cheap,
   foundational, and makes every later phase easier to debug.
3. `rules/error-handling.md` — the shared error envelope and global
   exception handler, before any real route exists, so the first route
   written already returns errors in the one consistent shape instead of
   retrofitting it later.
4. `rules/data-models.md` — schema and migrations. Auth, business logic,
   and routes all read/write against this, so it has to exist first.
5. `rules/auth.md` — identity/session mechanics. Almost everything
   downstream needs to know who's calling before it can enforce anything.
6. `rules/security-practices.md` — row-level security on the real tables
   from step 4, rate limiting, CORS, input-validation/mass-assignment
   wiring. Done immediately after auth and data rather than bolted on
   later, so nothing is ever built temporarily unprotected.
7. `rules/business-logic.md` — the core domain algorithms, built and
   tested directly against the data models, independent of HTTP.
8. `rules/api-routes.md` — the HTTP surface, wiring auth + security +
   business logic + error handling together **one purpose-group at a
   time** (mirrors that file's own "grouped by purpose" instruction) —
   finish and test one group before starting the next, not every route
   file stubbed at once.
9. `rules/llm-integration.md`, if it wasn't deleted during the interview
   — wherever it's actually invoked from business logic or routes; let it
   land at its real call sites rather than forcing it into an earlier
   phase.

Write each phase's tests as you build it, per `rules/testing.md`'s
strategy — never as one deferred final "testing" pass at the end. And if
building a phase reveals that an earlier rules file was wrong or
incomplete, fix that file directly before continuing: the rules files stay
the source of truth for what the code should do, not a one-time reference
you drift away from once real code exists.

See `INTERVIEW.md` for why this order is close to the reverse of the
interview order — that's expected, not a contradiction: the interview
goes domain-first/infra-last since each question needs the previous
answer to make sense, while the build goes infra-first/domain-later since
a running scaffold and a consistent error/logging story need to exist
before there's real code to build against.
