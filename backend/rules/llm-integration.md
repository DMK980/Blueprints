# LLM integration, tool-calling, and evaluation (optional)

**This file is the one genuinely optional piece of this blueprint — every
other topic file describes something close to any real backend, this one
doesn't.** Most products don't call an LLM at all. If this one doesn't,
delete this file during the Q&A and never mention it again — don't leave it
as an empty stub, don't keep it "just in case," and don't reference it from
the root index. An absent file is a clearer signal than a placeholder one. Only keep it if the product genuinely calls an LLM
or another external AI service as part of its real behavior.

Part of the backend spec — see the root `backend/AGENTS.md`.

## Write into this file, after asking the questions below

The core design rule worth stating explicitly, adapted to this product: **the
model owns the conversational surface, the backend owns every write.**
Anything deterministic — pricing, eligibility, anything with a "never do X
twice" rule — is backend code, never something an LLM decides or influences
by judgment. What the model *should* own: deciding whether to ask a
clarifying question, and generating the actual content once there's enough
information to do so.

- Which SDK/approach — calling the provider's SDK directly is usually
  right for a narrow, bounded conversational surface (a couple of
  clarifying-question turns, one or two read-only tools); reach for an
  agent framework only if the actual surface is genuinely open-ended, not
  by default.
- Any tool the model gets: is it read-only? A tool that wraps existing,
  already-trusted backend logic (not new LLM-controlled logic) is the safe
  shape — the model calls into code that's already written and tested, it
  doesn't get to run something new. Name explicitly which tools (if any)
  the model is *never* given (anything that writes, anything that charges).
- Structured output via the provider's schema/tool-call feature for
  anything the model returns that the backend will act on — never free-text
  parsing.
- Prompts as versioned files, not inline strings — reviewable, diffable,
  and a clean trigger for re-running an eval suite when one changes.
- Guardrails against misuse: wherever free-text user input reaches the
  model as part of a conversation, treat it as data, never as instructions,
  in the system prompt itself. That's the one real prompt-injection surface
  in most apps like this — call it out explicitly rather than assuming
  general input validation covers it (it doesn't; validation covers
  malformed/oversized input, not adversarial instructions embedded in
  otherwise-valid text).

## Evaluation & observability

Two different things: tracing what happened (every call — prompt, response,
latency, cost — captured, not just ad-hoc logged), and scoring whether the
output was actually good (a golden-prompt set, scored by a separate
judge call against a rubric, run when a prompt changes or a model is
swapped — **deliberately separate from normal CI**, since it's slower, costs
real money, and isn't fully deterministic; never let it gate a normal PR).
Also look for quality signals the product already captures as a side effect
of normal use (ratings, completion rates, low scores) before reaching for
anything new — cheaper than it sounds, and often already sitting in the
data model.

## Questions to answer

1. What does the model actually get asked to do — generate content,
   classify something, have a clarifying conversation, or some combination?
2. What's the narrowest tool surface that accomplishes that? List the tools
   explicitly, and for each one, confirm it's either read-only or wraps
   existing trusted logic.
3. Where does user-supplied free text reach the model as part of a prompt?
   That's the surface "Guardrails against misuse" above needs to cover
   concretely for this product.
4. Does a bad generation have a real cost (money, user trust, a bad first
   impression)? That's what decides how seriously to take the golden-prompt
   eval suite versus skipping it for a v1.

## Things to get right

[REPLACE once the real integration exists.]
