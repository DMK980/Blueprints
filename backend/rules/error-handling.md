# Error handling: the response envelope and status-code conventions

Part of the backend spec — see the root `backend/AGENTS.md`. Individual
routes (`rules/api-routes.md`) document *which* error cases they can
return; this file defines the one shared shape those all use, so a new
route's errors are consistent by default instead of each route reinventing
one.

## Write into this file, after asking the questions below

One error envelope, used everywhere, no exceptions — typically something
like `{ error: { code, message, requestId } }`, where `code` is a stable
machine-readable string the client branches on (never parse `message` for
logic), and `requestId` ties back to `rules/observability.md`'s
correlation id so a user's bug report is traceable to real server-side
logs. A short status-code reference table (validation → 422, auth → 401,
role/ownership → 403, not found → 404, a state conflict or a business-rule
rejection → 409, rate limit → 429, unhandled → 500) so a new error case
picks its status consistently rather than each route improvising. A single
global unhandled-exception handler that logs the real detail to error
tracking and returns a generic message to the client — never a raw
exception string or stack trace, even during early development when it's
tempting to leave that in "just for now."

## Questions to answer

1. Does this product have any "offer the user a choice before proceeding"
   response (per `rules/business-logic.md`'s question 4)? That needs its
   own `code` and a clear status (one reasonable choice is `409`,
   reasoning it as a state conflict rather than a payment-required gate —
   pick one and be consistent) — and it must be purely informational: nothing gets
   generated, charged, or committed until the client explicitly resubmits
   with the choice made.

## Things to get right

- Every non-2xx response uses the shared envelope — no route returns a bare
  string or a different shape "just this once."
- An unhandled exception's real detail goes to the error tracker via
  `requestId`, never into the response body.
