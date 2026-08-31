# Observability: logging, error tracking, metrics, health checks

Part of the backend spec — see the root `backend/AGENTS.md`. This is the
"did the code work" half of monitoring — if there's an LLM involved, "was
the output actually good" is a separate concern in
`rules/llm-integration.md`, not duplicated here.

## Write into this file, after asking the questions below

A correlation/request id generated per request in **middleware that runs
before routing** — not tied to an auth dependency, since unauthenticated
routes (login, signup, webhooks) never run that dependency and are exactly
the ones most likely to need debugging. Structured logging carrying that
id, with an explicit list of what never gets logged (passwords, tokens,
OTP codes, any user-typed free text). Real error tracking, not just log
lines. Metrics/alerting — a generic uptime/latency baseline, plus whatever
this specific product's own expensive-to-get-wrong failure modes are (a
balance-ledger mismatch, an anomalous spend rate on whatever triggers real
external cost). Two small health-check routes (liveness, readiness) for the
hosting platform's restart policy — genuinely small, a handful of lines,
not a subsystem.

## Questions to answer

1. What's this product's equivalent of "a balance-ledger mismatch" — the
   specific internal-consistency check that, if it silently drifted, would
   mean a real correctness bug slipped through? Alert on that specifically,
   not just generic error rate.
2. Which routes are unauthenticated (per `rules/auth.md` and
   `rules/api-routes.md`)? Confirm the correlation id covers all of them,
   not just the ones behind the auth dependency.
3. Does the hosting platform (per `rules/engineering-standards.md`) support
   native health-check-gated deploys? If yes, that's what the readiness
   route is actually for.

## Things to get right

[REPLACE once real logging/monitoring exists.]
