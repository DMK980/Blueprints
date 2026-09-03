# Backend blueprint — agent instructions

This is not documentation for a human to read. It's a procedure for you (the
coding agent) to run when the user wants to bootstrap a new backend. The
user should not need to write or edit any of this themselves — you
interview them, you write every file.

This file works with any agent that reads `AGENTS.md`. If you're Claude
Code specifically, also read `CLAUDE.md` in this same directory — it
imports this file and adds one extra step that only applies there.

## What you do, in order

1. **Interview the user** by opening `INTERVIEW.md` in this directory and
   following it in order, one question at a time (not a wall of questions
   at once) — this is a conversation, not a form. Its ordering is
   deliberate: don't reorder it, don't jump ahead to a rules file it
   hasn't reached yet. That file also covers the picker-tool requirement
   for how each question gets asked.
2. **Write this file's opening paragraph** — replace the `[REPLACE: ...]`
   block below with the real one-paragraph description, from the answers
   you got. If there's no genuine defining mechanism, say so plainly
   instead of inventing one; don't force drama into a plain CRUD backend.
3. **Delete `rules/llm-integration.md`** (and its row in the table below)
   unless the user confirmed this product actually calls an LLM or
   another external AI service. Default is delete — don't ask "should I
   keep this," just remove it unless they said yes.
4. **Rewrite every remaining file in `rules/`**: work through that file's
   "Questions to answer," then replace its "Write into this file" section
   with the real, product-specific content it describes — same structure
   (concrete rules with reasoning, cross-references to other rules files,
   ending in "Things to get right"), but about *this* product, not
   written as a description of what the section is for. Delete the
   "Questions to answer" heading and its contents once you've used them —
   they're your interview script, not something that belongs in the
   finished file.
5. **Drop any table row / rules file that genuinely doesn't apply** once
   you know the product (e.g. no CORS content if there's no browser
   client). Add a new row and rules file the same way if a real concern
   doesn't fit any existing one.
6. **Stop here for this pass.** Don't scaffold real application code
   unless the user separately asks for that — this procedure produces the
   spec, not the app.

## Building the real app, once asked

This only applies later, once the user separately asks you to actually
build the backend — a distinct request from the spec interview above, not
something step 6 implies you should keep going into.

Even when asked to build the whole thing in one go, **do not implement
the entire spec in one pass.** Open `BUILD-ORDER.md` in this directory and
work through it one phase at a time, finishing (and testing) each phase
before starting the next — its order is dependency-driven, not
product-specific, and deliberately different from `INTERVIEW.md`'s order
(that file explains why).

## Where to look / what to build

The nine rows below apply to essentially any real backend. `llm-integration`
is the one exception — delete it per step 3 above unless confirmed
otherwise.

| Working on... | File |
|---|---|
| Database tables | `rules/data-models.md` |
| Core business logic — [REPLACE: name the actual mechanism] | `rules/business-logic.md` |
| API endpoints | `rules/api-routes.md` |
| Login/signup/session flows | `rules/auth.md` |
| Rate limiting, input validation, row-level security | `rules/security-practices.md` |
| Stack, project structure, deployment | `rules/engineering-standards.md` |
| Testing strategy, CI/CD | `rules/testing.md` |
| Logging, error tracking, metrics, health checks | `rules/observability.md` |
| Error-response shape, status codes | `rules/error-handling.md` |
| LLM calls, tool-calling, eval — **optional, delete by default** | `rules/llm-integration.md` |

[REPLACE: one paragraph on what this product does and its defining
mechanism, if it has one — written here once step 2 above is done.]

## Interview checklist

See `INTERVIEW.md` in this directory — the full ordered interview lives
there, not here, so it can carry its own reasoning for why each question
comes where it does without bloating this file.

## Writing style for every file you produce

Every rule you write needs to be concrete enough to actually prevent a
mistake, not generic best-practice filler. Test: if a sentence would still
be true with the product's name swapped for a different app entirely, it's
too generic — make it specific to *this* product's real behavior. State the
reasoning behind a rule, not just the rule, so a future session (you,
later, with no memory of this conversation) can extend it correctly instead
of just obeying it blindly. Every rules file ends with a "Things to get
right" list scoped to that file's area, not a shared master list.

## Splitting a rules file once it grows

When a rules file in `rules/` gets big enough to cover more than one real
concern (most likely candidates: `data-models`, `api-routes`), split it
into a subdirectory — `rules/data-models/auth-tables.md`,
`rules/data-models/billing-tables.md`, and so on. Do this yourself when a
file is clearly outgrowing its scope; don't wait to be asked.
