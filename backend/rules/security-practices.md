# Security practices: rate limiting, input sanitization, row-level security

Part of the backend spec — see the root `backend/AGENTS.md`. Session/login
mechanics live separately in `rules/auth.md` — this file covers the rest.

## Write into this file, after asking the questions below

**Rate limiting**, different limits for different endpoint shapes — tight
per-IP-and-per-account limits on unauthenticated auth endpoints (brute
-force protection), per-user limits on anything that triggers real external
spend (an LLM call, an API call you pay for), a stricter limit on webhooks
(unauthenticated-by-user, verified by signature instead, and a target for
replay/flood attempts even when a uniqueness constraint already backstops
against double-processing).

**Input validation**, server-side always, regardless of what the client
already checks — client validation is a UX nicety, never a security
boundary, since a request can always be hand-crafted.

**Row-level security**, if the database supports it (e.g. Postgres RLS) —
worth adopting if there's any per-user data at all, since it turns "a
developer forgot a `WHERE` clause" from a data leak into a query that
returns nothing. The one genuinely tricky part: tables where more than one
user legitimately needs to read the same row (shared/reused content, if
this product has any) need a policy that's *not* a plain ownership check —
work out that policy explicitly rather than defaulting to "own rows only"
and accidentally breaking the sharing behavior.

**CORS**, if there's a browser-facing client at all (an admin panel, a web
app) — a native mobile client doesn't need it, don't add a policy for a
client type that doesn't exist.

## Questions to answer

1. Which endpoints trigger real external cost (an LLM call, a paid API)?
   Those need per-user rate limits specifically, on top of whatever general
   default applies everywhere else.
2. Which tables (per `rules/data-models.md`'s question 2) are shared
   across users rather than strictly owned by one? Their RLS policy (if
   using RLS) needs to be worked out explicitly, not defaulted.
3. Are there any webhooks (per `rules/api-routes.md`'s question 2)? Each
   one needs its trust model stated explicitly — verified by whose
   signature, what happens on a replay.
4. Is there a browser-facing client at all? If yes, what origins actually
   need to be in the CORS allowlist — keep it an explicit, short list, never
   a wildcard.

## Things to get right

[REPLACE once real policies exist.]
