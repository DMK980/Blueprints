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

**Query safety**: parameterized queries or the ORM's own query builder,
never a raw string built by concatenating user input — this is a separate
concern from input validation above, since a field that already passed
validation (a correctly-shaped string, say) can still carry an injection
payload if it's interpolated into SQL directly instead of bound as a
parameter.

**Mass assignment**: any endpoint whose underlying model has a privileged
or sensitive column (`role`, `isAdmin`, a balance, a price, a verified
flag) must build its update from an explicit allow-list of client
-writable fields, never a blind deserialize of the full request body onto
the model — this is the general mechanism behind `rules/auth.md`'s "no
endpoint can let a caller grant themselves a role" rule, and it applies to
every privileged column, not just role.

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
client type that doesn't exist. CORS and CSRF are not the same protection:
CORS only controls which origins are allowed to *read the response* of a
cross-origin request; it does nothing to stop a cross-site page from
*sending* a state-changing request with the browser's cookies attached in
the first place. If sessions live in a cookie, that's CSRF exposure and is
covered by `rules/auth.md`'s token-transport section, not by the CORS
allowlist here.

**File uploads**, if this product accepts any (images, documents, other
user-supplied files): validate the real content by sniffing its actual
bytes, never trust a client-declared MIME type or file extension; cap size
server-side; and store the file somewhere that isn't directly executable
or web-servable from the app server (a bucket behind signed URLs is the
usual answer) so a malicious upload can't become a served file.

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
   a wildcard. If sessions are cookie-based, confirm `rules/auth.md` has a
   CSRF answer, not just a CORS one.
5. Which endpoints' models include a privileged or sensitive column (role,
   balance, price, a verified/approved flag)? Each needs an explicit
   allow-list of client-writable fields, confirmed here so nothing relies
   on a blind full-body deserialize.
6. Does this product accept file uploads at all? If yes: what's actually
   validated (real content, not client-declared type/extension), what's
   the size cap, and where do files live so an uploaded file can never be
   served back as executable content.

## Things to get right

[REPLACE once real policies exist — likely candidates: every write query
goes through parameterized queries or the ORM's builder, never raw
string-built SQL; every endpoint touching a privileged column enforces its
allow-list server-side even if the client UI never exposes that field; the
CORS allowlist never contains a wildcard; an uploaded file is never stored
somewhere the app server would execute or directly serve it.]
