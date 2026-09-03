# Auth: session mechanics and endpoints

Part of the backend spec — see the root `backend/AGENTS.md`. The rest of
the security surface (rate limiting, input validation, RLS) lives in
`rules/security-practices.md`, not here.

## Write into this file, after asking the questions below

**Sign-in method(s) first** — password, OAuth/social sign-in, magic
link/email OTP, or a mix — since that choice changes almost everything
below it. OAuth-only means no password hash and no reset flow, but does
mean storing which provider plus that provider's user id issued the
account, and deciding what happens if the same person later signs in
through a second provider (a new account, or linked to the existing one by
verified email?). A mix means the schema needs to support an account with
zero, one, or several sign-in methods attached, not exactly one.

**Session-based or JWT first** — this decides what the access token even
is before anything else about it makes sense. A session-based token is an
opaque id looked up against server-side state on every request: trivial to
revoke instantly (delete the row), at the cost of a lookup per request. A
JWT is a self-contained signed token: no lookup, but no instant revocation
either — it's valid until it expires no matter what the server does
afterward, which is exactly why JWTs lean on short access-token lifetimes
plus a separate, server-side-revocable refresh token rather than one
long-lived token of either kind. Pick one and say why given this product's
actual read volume and revocation needs, rather than defaulting to
whichever is trendier.

Token/session mechanics: access-token lifetime and what it carries (if
JWT — a session token carries nothing but its own id), how the refresh
token is stored and rotated, and — the part that's easy to leave implicit
— **exactly what makes the app "stay logged in" safely** rather than
either re-prompting for a password constantly or holding one long-lived
token forever. Refresh-token rotation (a new token issued every refresh,
the old one dead) plus reuse detection (a dead token presented again is a
compromise signal, not a normal expiry) is the pattern that makes "logged
in indefinitely while actively used" safe without a single forever-valid
credential — worth adopting outright rather than re-deriving.

**Token transport**: httpOnly cookie or an `Authorization` header. A cookie
rides along on every request automatically, including cross-site ones, so
it needs explicit CSRF protection (`SameSite`, plus a double-submit token
for any state-changing request) — a bearer header has no CSRF exposure but
pushes storage, and the XSS risk that comes with it, onto the client. Pick
one deliberately and say why; don't leave it implicit.

If password-based: hashing algorithm, and the **password-reset flow** —
a reset token is single-use and short-lived, is invalidated the moment
it's used *or* a newer one is requested (so an old, forgotten reset email
can't resurface as a live credential), and a successful reset revokes
every existing session on the account, not just the one that requested it
(closes the door on whatever compromised the password in the first place).

Also: how a request's auth and its database-session scoping (if using row
-level security) share one dependency/middleware so they can't drift out of
sync, account-deletion's session-teardown step, and how the very first
admin/privileged account gets created (almost always: out-of-band, a manual
DB update at launch — not a self-service endpoint, since no endpoint should
ever let a user grant themselves a privileged role).

Auth endpoints are also where brute-force/credential-stuffing attempts land
first — cross-reference `rules/security-practices.md` for the actual rate
-limit numbers rather than restating them here.

## Questions to answer

1. What sign-in method(s) does this product actually support — password,
   OAuth/social, magic link, or a mix? This decides whether a reset flow,
   a password column, or a per-provider linking story even applies.
2. Session-based (opaque token, server-side lookup, instant revocation) or
   JWT (self-contained, no lookup, but no instant revocation — only
   expiry)? Base this on the product's actual revocation needs and read
   volume, not on whichever is more familiar.
3. What roles exist beyond a plain user? How does someone get promoted to
   one — and confirm explicitly that no API endpoint can grant a role to
   the caller's own account.
4. Does the product need "stay logged in" behavior, or is re-authenticating
   periodically actually fine for this product's usage pattern? If yes,
   adopt refresh-token rotation + reuse detection rather than a single
   long-lived token.
5. Will sessions live in a cookie or be sent as a bearer header? If a
   cookie, what's the CSRF story (`SameSite` setting, and whether a
   double-submit token is needed on top of it)?
6. If password-based: what does the forgot-password flow look like end to
   end — reset-token lifetime, single-use invalidation, and confirming a
   successful reset kills every other existing session on the account.
7. Is there an account-deletion flow? If shared/reused content exists (see
   `rules/data-models.md`'s question 2), deletion needs to distinguish
   "this user's own data" (removed) from "content other users may still
   depend on" (survives) — work this out here, matching
   `rules/data-models.md`'s question 8 (foreign-key delete behavior) for
   what actually happens to each table's rows, and cross-reference from
   `rules/api-routes.md`'s delete-account route.
8. Are there account states beyond active (suspended, banned)? If so, does
   the login flow need a specific message for that state rather than a
   generic "wrong credentials" error?

## Things to get right

[REPLACE once real auth exists — likely candidates: refresh-token reuse
must trigger revoking the whole session chain, not just rejecting the one
request; password hashes are never logged, returned, or included in an
error message; a password-reset token is dead the instant it's used or
superseded; session cookies (if used) are httpOnly + secure with an
explicit `SameSite`, never left to browser defaults.]
