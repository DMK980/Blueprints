# Data model

Part of the backend spec — see the root `backend/AGENTS.md` for the shared
framing. Every table in this system, with columns, keys, and constraints —
get these right before writing business logic against them, since most of
the ways a real system silently misbehaves (double charges, a leaked "who
else has seen this" signal, a user seeing something twice) are schema
-shaped problems, not logic-shaped ones.

## Write into this file, after asking the questions below

For each table: columns with type and constraints, what each non-obvious
column actually means (not just its type — *why* it exists, what it's for),
foreign keys, unique constraints (and *why* — a unique constraint that
exists as a deliberate business-rule backstop, not just an accident of
normalization, is worth a sentence explaining what it's actually
preventing), and indexes tied to the actual query pattern that needs them
(not indexes added speculatively).

Say plainly which fields are **computed, not stored** — and why. A repeated
pattern worth adopting outright: "don't cache a derived aggregate" — a
count, a ranking, or any other value derivable from other rows is often
better left as a live query instead of a denormalized column, because a
cached copy needs to be kept in sync forever and *will* drift. Default
to live computation; only cache when profiling actually shows a real
bottleneck.

## Questions to answer

1. What are the actual entities this product needs to persist? Start from
   the two-sentence product description in the root file and work outward —
   don't start from a generic CRUD-app table list.
2. For each table that represents something a user creates or owns: who can
   read it, who can write it, and does more than one user ever legitimately
   need access to the same row (shared or collaborative content, for
   example)? That answer
   is what `rules/security-practices.md`'s row-level-security policies get
   built from later — get it right here first.
3. Which columns are genuinely derived/computed rather than source-of-truth
   data? Flag them explicitly so `rules/business-logic.md` doesn't
   accidentally treat a cache as ground truth.
4. Are there any DB-level constraints that exist specifically to backstop a
   business rule (not just normal data integrity) — for example, a unique
   constraint whose real job is "never show a user the same item twice"?
   Name the rule each one is defending, not just the constraint itself.
5. If money moves through this system: is there a ledger table (an
   append-only log of every balance change) separate from the cached
   current-balance column? A cached balance without a ledger behind it is
   very hard to audit or debug later — decide this now, it's expensive to
   retrofit.

## Split into more files once this grows

Once there's more than a handful of tables, split them into a
`rules/data-models/` subdirectory (grouped by the part of the
product they serve, for example `auth-tables.md`, `billing-tables.md`,
etc.), with this file either going away or staying as a short overview —
same convention described in the root file's "Keeping the structure
organized."

## Things to get right

[REPLACE once real tables exist — the handful of schema-level rules that,
if violated, would cause the most damage. Example shape: "A
hidden/moderated row must still be readable by whoever already has
legitimate access to it — hiding something should only ever affect *future*
exposure, never claw back access already granted."]
