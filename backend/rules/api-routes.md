# API surface — index

Part of the backend spec — see the root `backend/AGENTS.md`. Auth routes
(signup, login, refresh, ...) live in `rules/auth.md`, next to the session
mechanics they implement, not here.

## Write into this file, after asking the questions below

Every route grouped by **purpose or the service/table group it fronts**,
not dumped into one flat list — group generation-shaped endpoints together,
account/settings together, admin-only endpoints together, and so on. For
each route: method + path, request shape, what it actually does (one or two
sentences, cross-referencing `rules/business-logic.md` rather than
re-explaining the logic here), and its specific, non-default error cases
(the ones a client actually needs to branch on — a plain validation error
doesn't need a callout, a business-rule rejection does).

Once there's more than roughly half a dozen routes or more than one real
purpose group, split into a `rules/api-routes/` subdirectory — one
file per purpose group, this file either goes away or becomes a short
overview — the same convention as `data-models`. Don't pre-guess the
groupings before real routes exist; start flat, split once a real shape
emerges.

Every route's error responses share one envelope — see
`rules/error-handling.md` for the shape; this file (and its
sibling files, once split) documents *which* error codes a given route can
return, not the envelope itself.

## Questions to answer

1. What are the actual user-facing actions in this product? List them as
   verbs (generate, purchase, rate, report, delete...) before turning them
   into routes — this list is also what drives `rules/data-models.md`'s
   entity list and `rules/business-logic.md`'s algorithms.
2. Which of these need a webhook instead of a normal user-facing route (a
   payment provider confirming a purchase, an ad network confirming a
   view)? Webhooks get a different trust model — verified by the sender's
   signature, never by a client's say-so — flag them as such explicitly.
3. Which routes are admin/moderator-only? Group them together; they'll need
   the same role gate and the same RLS treatment in
   `rules/security-practices.md`.
4. Is there a "delete my account" route? If the product has any concept of
   user-owned content that other users might also depend on (shared/reused
   content, a marketplace, anything collaborative), deleting an account
   can't be a blind cascade — work out what survives and what doesn't
   *before* writing this route, not after.

## Things to get right

[REPLACE once real routes exist.]
