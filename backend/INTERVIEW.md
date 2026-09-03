# Interview checklist

Part of the backend blueprint — see the root `AGENTS.md` for the overall
procedure. This file is the interview itself: the order below is
deliberate, not just a checklist to work through in whatever sequence is
convenient. Every question here only gets asked once everything it
depends on is already known — nothing is asked before its prerequisite,
and the stack question in particular is deliberately last among the
functional questions, not first, so it can be reasoned from the product's
actual requirements instead of guessed before they exist.

For every question except what the product does and how the mechanism
works, you MUST invoke the host's multiple-choice tool (`AskQuestion` in
Cursor, Claude Code's question tool) with a few options — the write
-in/Other is built in, don't duplicate it. Do not ask those as a free-text
chat message; a numbered list in prose is not a picker. If no such tool
exists, print numbered options ending in `Other`.

## Root questions (ask first, before opening any file in `rules/`)

1. What does this product do, in two or three sentences? Who's the user,
   what do they come here to do?
2. Is there a defining mechanism — something about how the backend works
   that isn't obvious from "it's a CRUD app for X"? If yes, that's
   `AGENTS.md`'s opening paragraph and probably drives `business-logic.md`.
3. What user roles exist beyond a plain user (admin, moderator, ...)?
4. Does real money move through this system (subscriptions, credits,
   in-app purchases, a marketplace)?
5. Does this product call an LLM or another external AI service? Default
   assumption is no — only keep `rules/llm-integration.md` if the answer
   is genuinely yes.

Stack is **not** asked here. It's the first question in
`rules/engineering-standards.md`, reached at position 8 below, once the
product's actual requirements are known instead of guessed.

## File order (open each in this order, work through its own "Questions
to answer")

1. **`rules/data-models.md`** — entities are the foundation. `auth.md`
   (account deletion), `security-practices.md` (row-level security), and
   `api-routes.md` all reference "per data-models.md's question 2/3," so
   this has to be answered first.
2. **`rules/business-logic.md`** — needs data-models' entities and its
   computed-vs-stored answer (so a cached/derived field never gets
   treated as ground truth here). The defining mechanism named in root
   question 2 gets its real procedural detail in this file.
3. **`rules/llm-integration.md`**, only if root question 5 was yes —
   skip entirely otherwise. Its tools are meant to "wrap existing trusted
   logic," i.e. the logic `business-logic.md` just named, so it follows
   directly after.
4. **`rules/auth.md`** — its account-deletion question needs
   data-models' shared-vs-owned-content answer (question 2) and its
   foreign-key delete-behavior answer (question 8). Everything else in
   this file (sign-in method, session mechanism, roles, reset flow) only
   needs the root phase, but it's placed here so the account-deletion
   question has what it needs.
5. **`rules/api-routes.md`** — routes cross-reference
   `business-logic.md`'s algorithm instead of re-explaining it here, need
   auth's account-deletion policy for the delete-account route, and need
   root question 3's roles for grouping admin-only routes.
6. **`rules/error-handling.md`** — its one real question ("does this
   product have an 'offer the user a choice' response") points directly
   at `business-logic.md`'s question 4. It also pairs naturally with the
   routes just laid out, since every route's errors use this file's
   shared envelope.
7. **`rules/security-practices.md`** — needs data-models (which tables
   are shared, for row-level security), auth (the CSRF story for cookie
   -based sessions), and api-routes (webhooks, admin routes, which
   endpoints touch privileged columns) — all three already covered by
   this point.
8. **`rules/engineering-standards.md`** — **the stack question lives
   here.** By now the real requirements are known: does anything need
   vector search or a particular read pattern (data-models), real-time
   updates or heavy background processing (business-logic), a payment/IAP
   flow (api-routes plus the root money answer), transactional email
   (auth's reset flow). Let the stack follow from these instead of
   defaulting to whatever the last project used.
9. **`rules/observability.md`** — needs the hosting platform just
   decided in engineering-standards (for the readiness-route question)
   and needs to know which routes are unauthenticated (auth +
   api-routes, both already covered).
10. **`rules/testing.md`** — needs the deploy target
    (engineering-standards, for the health-check-gated-cutover question)
    and `business-logic.md`'s "Things to get right" to build its
    traceability mapping. Last, since it's meant to cover everything
    already decided above.

## Why this order is not the build order

This file governs the **interview** — what to ask, and when enough is
known to ask the next thing. `BUILD-ORDER.md` governs **implementation**
— what to actually write code for first, once the user separately asks
for real code. They run in close to opposite directions on purpose: this
file goes domain-first, infra-last (`engineering-standards.md` is
question 8 of 10, near the end) because each question needs the previous
answer to make sense. `BUILD-ORDER.md` goes infra-first, domain-later
(`engineering-standards.md` is phase 1) because a running scaffold and a
consistent error/logging story need to exist before there's any real code
to build against. Seeing `engineering-standards.md` in a very different
position in each list is expected, not a contradiction between the two.
