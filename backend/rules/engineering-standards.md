# Engineering standards: stack, code quality, deployment

Part of the backend spec — see the root `backend/AGENTS.md`.

## Write into this file, after asking the questions below

**Stack** — chosen for *this* product's actual needs, not defaulted from
habit. State the reasoning for each real choice (language/framework,
database, hosting), not just the choice — a future session revisiting this
should understand *why*, especially for anything that looks unusual. Note
what was deliberately rejected and why (serverless, a particular database,
a heavier framework) if that was a real decision, not just an omission.

**Project structure** — a clear separation between routes/handlers,
request/response schemas, data-access models, and business logic, so
business logic stays testable without spinning up the whole HTTP stack.

**Code quality** — type checking, linting/formatting, and *where* comments
actually earn their place: the why, not the what, concentrated at the
specific points elsewhere in this spec that are genuinely easy to get wrong
(cross-reference them by name here, so grepping for a phrase from this list
finds the code implementing it).

**Deployment** — the actual production footprint (one instance? a
container? what's the database hosting story?), backups/disaster-recovery
(**this is the one piece of infrastructure worth setting up before real
user data exists**, unlike most infra which is fine to add when a real need
shows up — data loss is irreversible in a way deferred infrastructure
isn't), and secrets management (how a secret actually gets into the running
process, never a committed file; what rotating each one actually costs).

**Payments**, if the product sells anything and ships as a native mobile
app: Apple's/Google's own in-app-purchase systems are generally expected
for a consumable digital good sold inside a native app, not a third-party
processor routed around them — decide this early, since it changes the
actual purchase-verification flow (`rules/api-routes.md`), not just which
SDK key gets set.

**Email**, if the product sends any: name a real provider with a free/cheap
tier appropriate to expected volume, not "TBD."

## Questions to answer

1. **The stack.** By the time this file is reached (see `INTERVIEW.md`),
   `data-models.md`, `business-logic.md`, `auth.md`, `api-routes.md`,
   `error-handling.md`, and `security-practices.md` are already answered
   — use what they actually revealed (a database with vector search?
   real-time updates? heavy background processing? a payment/IAP flow?
   transactional email?) to pick the stack. Don't default to whatever the
   last project used, and don't guess ahead of what's actually needed.
2. What's the cheapest hosting setup that's genuinely sufficient for
   expected early-stage traffic? Note the concrete trigger for upgrading
   past it (e.g. "once actually running more than one instance"), not a
   preemptive upgrade.
3. Does this product sell anything through a native mobile app? If so,
   in-app-purchase compliance needs deciding now, not after
   `rules/api-routes.md`'s purchase route is already built against the
   wrong assumption.
4. What's the backup/PITR story for the database, concretely — which tier,
   what retention window? Don't leave this as "the platform handles it"
   without checking what the platform's default tier actually guarantees.

## Things to get right

[REPLACE once the real stack/deployment exists.]
