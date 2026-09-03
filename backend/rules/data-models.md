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

**Status/enum columns**: this file defines the column and its legal
values. The transition rules between those values — what can move to
what, and in what order — belong in `rules/business-logic.md`'s
state-machine coverage, not duplicated here.

**Primary keys**: sequential integer or UUID, and why. A sequential id is
enumerable — a client can guess `/orders/1235` exists just by
incrementing — which still matters even with row-level security in place
(RLS stops the read, but an enumerable id already leaked "how many of
these exist" and invites probing). Decide this deliberately per table,
don't default to whatever the ORM picks.

**Timestamps and deletion**: the `created_at`/`updated_at` convention, and
explicitly, per table if it genuinely varies — soft-delete (a nullable
`deleted_at`/status flag) or hard-delete. This is the actual mechanism
behind "a hidden/moderated row must still be readable by whoever already
has legitimate access to it" below — say which columns implement it.

**Foreign-key delete behavior**: for every foreign key from a user-owned
or shared table, state cascade, restrict, or null-out on parent delete,
and confirm it matches the ownership/sharing answer in question 2 below —
a shared, multi-contributor row shouldn't silently vanish just because
one contributor's account is deleted. This is the schema-level mechanism
`rules/auth.md`'s account-deletion policy and `rules/api-routes.md`'s
delete-account route actually get enforced against, not just a detail of
this file.

If money moves through this system: amounts are integers in the smallest
currency unit (cents), never a float — floating-point rounding error
compounds across many transactions, a distinct failure mode from "no
ledger to audit against" below.

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
6. Sequential integer or UUID primary keys, and why — factor in whether an
   enumerable id would leak anything (row counts, probing for other
   users' records) beyond what row-level security already blocks.
7. What's the soft-delete vs hard-delete convention, per table if it
   varies? Does every table need `created_at`/`updated_at`, or only ones
   where it's actually used?
8. For each foreign key on a table flagged as user-owned or shared
   (question 2): cascade, restrict, or null out on parent delete? Flag any
   case where this needs to differ from a plain "delete everything"
   default because the row is shared.

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
exposure, never claw back access already granted." Other likely
candidates: a money amount is never a float; a foreign key from a shared
row never cascade-deletes just because one contributing user's account is
deleted, without that being an explicit decision.]
