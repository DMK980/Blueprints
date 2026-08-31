# Testing strategy and CI/CD

Part of the backend spec — see the root `backend/AGENTS.md`.

## Write into this file, after asking the questions below

The test pyramid (unit → integration → end-to-end), each layer's actual
scope for *this* product, not a generic description of what unit tests are.
A fixture/test-data strategy. If using row-level security: an explicit
callout that tests must connect as the restricted application role, never
the migration-owner/superuser role — RLS is silently bypassed for a table
owner, so a test suite connecting as the wrong role passes even when a
policy is missing or broken. A traceability mapping from
`rules/business-logic.md`'s "Things to get right" to actual required test
cases, so nothing there is just aspirational prose. If money/balances are
involved: an explicit concurrent-write test (fire two simultaneous
operations against a balance that can only cover one, assert exactly one
succeeds) — this is the test that catches a naive read-then-write
implementation that every *sequential* test would otherwise let through.

Then CI (what runs on every PR — keep it fast and deterministic, no real
external-API calls) and CD (what happens on merge — deploy trigger,
migration safety, health-check-gated cutover, rollback plan, and
deliberately no staging environment until there's a concrete reason for
one, not preemptively). If there's an LLM eval suite
(`rules/llm-integration.md`), it explicitly does **not** run on the normal
PR gate — different trigger, different question being answered.

## Questions to answer

1. What's actually worth testing at each layer for this specific product?
   Don't default to "test everything equally" — the highest-priority code
   is whatever `rules/business-logic.md` covers, since that's where a
   silent bug costs the most.
2. Does this product use row-level security? If yes, the RLS-role callout
   above is not optional — it's the single easiest way an entire test suite
   gives false confidence.
3. Is there a balance, inventory, or anything else read-then-written under
   concurrent access? That needs an explicit concurrent-write test, not
   just sequential coverage.
4. What's the actual deploy target, and does it support health-check-gated
   traffic cutover natively? If yes, use it rather than building custom
   readiness-polling logic.

## Things to get right

[REPLACE once the real test suite/pipeline exists.]
