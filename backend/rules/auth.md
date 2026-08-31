# Auth: session mechanics and endpoints

Part of the backend spec — see the root `backend/AGENTS.md`. The rest of
the security surface (rate limiting, input validation, RLS) lives in
`rules/security-practices.md`, not here.

## Write into this file, after asking the questions below

Token/session mechanics: access-token lifetime and what it carries, how the
refresh token is stored and rotated, and — the part that's easy to leave
implicit — **exactly what makes the app "stay logged in" safely** rather
than either re-prompting for a password constantly or holding one
long-lived token forever. Refresh-token rotation (a new token issued every
refresh, the old one dead) plus reuse detection (a dead token presented
again is a compromise signal, not a normal expiry) is the pattern that
makes "logged in indefinitely while actively used" safe without a single
forever-valid credential — worth adopting outright rather than
re-deriving.

Also: password hashing algorithm, how a request's auth and its
database-session scoping (if using row-level security) share one
dependency/middleware so they can't drift out of sync, account
-deletion's session-teardown step, and how the very first admin/privileged
account gets created (almost always: out-of-band, a manual DB update at
launch — not a self-service endpoint, since no endpoint should ever let a
user grant themselves a privileged role).

## Questions to answer

1. What roles exist beyond a plain user? How does someone get promoted to
   one — and confirm explicitly that no API endpoint can grant a role to
   the caller's own account.
2. Does the product need "stay logged in" behavior, or is re-authenticating
   periodically actually fine for this product's usage pattern? If yes,
   adopt refresh-token rotation + reuse detection rather than a single
   long-lived token.
3. Is there an account-deletion flow? If shared/reused content exists (see
   `rules/data-models.md`'s question 2), deletion needs to distinguish
   "this user's own data" (removed) from "content other users may still
   depend on" (survives) — work this out here, cross-reference from
   `rules/api-routes.md`'s delete-account route.
4. Are there account states beyond active (suspended, banned)? If so, does
   the login flow need a specific message for that state rather than a
   generic "wrong credentials" error?

## Things to get right

[REPLACE once real auth exists — likely candidates: refresh-token reuse
must trigger revoking the whole session chain, not just rejecting the one
request; password hashes are never logged, returned, or included in an
error message.]
