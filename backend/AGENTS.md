# Backend blueprint — agent instructions

This is not documentation for a human to read. It's a procedure for you (the
coding agent) to run when the user wants to bootstrap a new backend. The
user should not need to write or edit any of this themselves — you
interview them, you write every file.

This file works with any agent that reads `AGENTS.md`. If you're Claude
Code specifically, also read `CLAUDE.md` in this same directory — it
imports this file and adds one extra step that only applies there.

## What you do, in order

1. **Interview the user** using the checklist below, one question at a
   time (not a wall of questions at once) — this is a conversation, not a
   form. For every question except what the product does and how the
   mechanism works, you MUST invoke the host's multiple-choice tool
   (`AskQuestion` in Cursor, Claude Code's question tool) with a few
   options — the write-in/Other is built in, don't duplicate it. Do not
   ask those as a free-text chat message; a numbered list in prose is
   not a picker. If no such tool exists, then print numbered options
   ending in `Other`. Then open each applicable file in `rules/` and
   work through its own "Questions to answer" section the same way.
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

## Interview checklist (ask these first, before opening any rules file)

1. What does this product do, in two or three sentences? Who's the user,
   what do they come here to do?
2. Is there a defining mechanism — something about how the backend works
   that isn't obvious from "it's a CRUD app for X"? If yes, that's this
   file's opening paragraph and probably drives `business-logic.md`.
3. What user roles exist beyond a plain user (admin, moderator, ...)?
4. Does real money move through this system (subscriptions, credits,
   in-app purchases, a marketplace)?
5. Does this product call an LLM or another external AI service? Default
   assumption is no — only keep `llm-integration.md` if the answer is
   genuinely yes.
6. What's the stack? Don't assume one — reason from what this product
   actually needs (a vector-search database, real-time updates, heavy
   background jobs) rather than defaulting to whatever the last project
   used. `engineering-standards.md`'s own "Questions to answer" goes
   deeper on this.

Each rules file has its own follow-up questions scoped to that area —
answer these six first, since several of the others don't make sense until
these are settled.

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
