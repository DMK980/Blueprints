# Business logic

Part of the backend spec — see the root `backend/AGENTS.md`. This is the
"how" behind whatever this product's defining mechanism is (per the root
file's Q&A item 2) — the algorithms and rules that aren't obvious from the
schema alone. If this product genuinely doesn't have a defining mechanism
this sharp, this file still exists for whatever business rules *do* need
explaining beyond plain CRUD (pricing, eligibility rules, state machines,
anything with a formula or an ordering that matters) — just without the
single unifying framing a sharper mechanism would have.

## Write into this file, after asking the questions below

The actual algorithms, in enough procedural detail that two different
engineers implementing from this file would build the same thing — not "we
match similar requests," but the literal ordered steps (what gets filtered,
in what order, and *why that order specifically matters* if it's not
obvious). Every formula with real numbers/constants named and a reasoning
for their starting values, not just "tune this later." Every place where
getting the order of operations wrong would cause a subtle bug — say so
explicitly — for example, if a matching algorithm must exclude a user's
own submissions before ranking the rest, state plainly *why* that
exclusion has to happen first, not after.

If money moves through this system, this is where the pricing/charging
rules live, including: what happens when a user can't afford the full
request (reject outright? offer a smaller version? — and if there's a
choice involved, make it an explicit, structured choice the user picks,
never something the backend silently decides on their behalf and explains
after the fact), and the concurrency rule for any balance that's read then
written (a guarded atomic `UPDATE ... WHERE balance >= amount`, not a
read-then-write in application code — call this out explicitly as its own
rule ("Concurrency: balance changes must be race-safe"), since naive
implementations pass every sequential test while still double-spending
under real concurrent traffic).

## Questions to answer

1. Walk through the defining mechanism (if there is one) step by step, out
   loud, as if explaining it to an engineer who's never seen it. Write down
   what you actually said — that's a first draft of this file.
2. For every formula or threshold: what are the actual starting values, and
   what's the *reasoning* for that starting value (not just "seems
   reasonable")? Which ones are safety buffers (should stay small, not be
   used as a profit/aggressiveness lever) vs. real intentional levers?
3. Does this system have anything that behaves like inventory or a shared
   resource — something one action can consume that affects what's
   available to someone else? If so, that's exactly the kind of thing that
   needs the concurrency/race-safety treatment above.
4. Is there a case where the "ideal" action isn't affordable/available, and
   a smaller/different version is? Decide explicitly: does the backend ask
   the user to choose, or decide on their behalf and explain afterward?
   (the "explain afterward" version is a real anti-pattern worth avoiding
   from the start: it spends the user's resources on a decision they
   didn't get to make.)
5. What's the actual, honest source of profit/margin in this system, if
   any? Naming it explicitly (state plainly which one or two mechanisms
   actually generate margin, and call out what *isn't* a profit lever)
   prevents a future session from reaching for the wrong constant when
   someone asks "how do we make more money."

## Things to get right

[REPLACE once the real logic exists — the specific ways this exact
mechanism is most likely to get quietly broken. Likely candidates: never
double-grant the same resource to a user, a reused/cached price is
immutable, charge-and-grant happen atomically, and the balance-change
concurrency rule above.]
