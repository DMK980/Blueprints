@AGENTS.md

For the interview, you MUST use Claude Code's question tool (multiple
choice + Other). Do not ask closed-fork questions as free-text.

## Claude Code

Everything above is the full, model-agnostic procedure — follow it as
written. This section adds the one extra step that only makes sense in
Claude Code specifically, because it depends on a Claude-Code-only
mechanism (`.claude/rules/*.md` with `paths:` frontmatter, which auto
-loads a rules file the moment a matching file is opened, instead of it
sitting there as a file someone has to know to go read).

**Don't do this yet — it only applies once real backend code exists.** But
once it does, do it yourself, unprompted, as the last step of whatever
session actually generates that code — don't wait for the user to ask, and
don't treat it as a manual setup task for them. The moment you finish
scaffolding or substantially writing the real backend code (in that same
session, right after), run this step before considering the work done. The
user should never need to know `.claude/rules/` exists, let alone set it up
themselves.

- Create a `.claude/rules/` directory and, for each file in `rules/`, add a
  copy into `.claude/rules/` with `paths:` frontmatter added — matching
  wherever that topic's code *actually* lives in the real tree, e.g.
  `paths: ["app/auth/**"]` on `auth.md`. Check the glob against the real
  directory names; never guess from the rules filename — a topic named
  `data-models.md` tells you nothing about whether the real code lives in
  `app/models/`, `app/db/`, or somewhere else entirely.
- `rules/` (no dot) stays the canonical copy every agent — including you,
  in a plain non-Claude-Code context — reads via `AGENTS.md`. Treat
  `.claude/rules/` as a derived, Claude-Code-specific convenience layer on
  top of it, not a second source of truth: if the two ever disagree, `rules/`
  is right. Practically, that means edit `rules/<topic>.md` first for any
  content change, then re-copy it into `.claude/rules/<topic>.md`,
  preserving that file's `paths:` frontmatter across the update.
- If a topic's real code location is still unclear when you do this pass,
  leave that file's `.claude/rules/` copy unscoped (no `paths:` at all)
  rather than guessing — an unscoped file still loads every session, a
  wrong glob just silently stops matching with no error.
