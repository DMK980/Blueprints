```
   ___  __   __  _________  ___  _____  ____________
  / _ )/ /  / / / / __/ _ \/ _ \/  _/ |/ /_  __/ __/
 / _  / /__/ /_/ / _// ___/ , _// //    / / / _\ \
/____/____/\____/___/_/  /_/|_/___/_/|_/ /_/ /___/
```

### v1 — backend

A reusable starting point for bootstrapping a new project's spec: a short
interview, then the agent writes a full set of project-specific
instruction files covering the
data model, the core business logic, API routes, auth, security, engineering
standards, testing/CI, observability, and error handling. Concrete,
product-specific rules with the reasoning behind them — not generic advice
a search engine could have produced.

**You shouldn't need to write or edit any of the files in here yourself.**
Everything under `backend/` is instructions *for the coding agent*, not
documentation for you to read line by line. This README is the one file in
this repo actually written for you.

This is v1 — backend only for now. More domains (a web frontend, a mobile
app) are planned as future sibling folders alongside `backend/`, using the
same pattern.

## How to use it

1. Install the `backend` blueprint into your project with one command — no
   git, npm, or plugin system required, just `curl`/`tar` (macOS, Linux, git
   -bash/WSL) or PowerShell (Windows, `tar` is bundled since 10 1803/11):

   ```sh
   curl -fsSL https://raw.githubusercontent.com/DMK980/Blueprints/main/install.sh | bash -s -- backend
   ```

   ```powershell
   iwr -useb https://raw.githubusercontent.com/DMK980/Blueprints/main/install.ps1 -OutFile install.ps1
   .\install.ps1 backend
   ```

   This drops a `backend/` folder into your current directory. Pass a second
   argument to install somewhere else (`... -- backend ./server`), and
   `--force`/`-Force` to overwrite an existing folder of that name. Prefer
   the manual route instead? Just copy `backend/` out of this repo yourself
   — the installer is a convenience, not a requirement.
2. Start a coding-agent session in that project and tell it something like
   *"follow the instructions in AGENTS.md to set up this backend's spec."*
   In Claude Code specifically, just starting a session is enough — it
   auto-loads `backend/CLAUDE.md`, which pulls in the same procedure.
3. The agent interviews you — a handful of questions about what the product
   actually does, who uses it, whether money or an LLM is involved, and
   what stack fits — one at a time, not a giant form. Just answer them.
4. The agent then writes the real content into every file itself: the root
   description of the product, and each file under `backend/rules/` (data
   models, business logic, API routes, auth, security, engineering
   standards, testing, observability, error handling). If there's no LLM
   involved, it deletes the one optional file (`llm-integration.md`) rather
   than leaving it as an unused stub.
5. What you get at the end is a spec that's ready to actually build
   against, not a vague outline.

This step only produces the **spec** — the instruction files describing how
the backend should work. It doesn't scaffold real application code. That's
a deliberate, separate step you ask for explicitly once the spec looks
right.

## Why there are two instruction files

- **`backend/AGENTS.md`** is the real, canonical procedure — plain markdown
  any coding agent can follow (Claude Code, Codex, or anything else that
  reads `AGENTS.md`). This is what makes the whole thing model-agnostic:
  the actual content — the interview, what belongs in each file, the
  writing style — doesn't depend on which agent is running it.
- **`backend/CLAUDE.md`** is a thin file that imports `AGENTS.md` (so
  Claude Code, which only auto-loads `CLAUDE.md` and doesn't read
  `AGENTS.md` on its own, still gets the full procedure) and adds exactly
  one Claude-Code-specific extra: once real backend code exists later,
  Claude sets up `.claude/rules/` on its own, unprompted, as part of
  finishing that code — you never trigger this yourself. It's Claude
  Code's own mechanism for a rules file to load automatically the moment
  matching code is opened, instead of needing to be remembered. That's the
  one advantage that's genuinely Claude-Code-only; everything else works
  the same everywhere.
- **`backend/rules/*.md`** stay the one source of truth either way — the
  Claude-Code-specific copy is explicitly documented as derived from these,
  never the other way around.

## Landing page

`docs/index.html` is a self-contained landing page (no build step, no
dependencies beyond two Google Fonts). To serve it live: on GitHub, go to
**Settings → Pages**, set **Source** to `Deploy from a branch`, pick the
`main` branch and the `/docs` folder, then save. It'll be live at
`https://dmk980.github.io/Blueprints/` shortly after.

## Current status

`backend` is the one blueprint that exists so far, installable via
`install.sh`/`install.ps1` as described above. Adding the planned
frontend-web/frontend-mobile sibling blueprints is the next step — the
installer already supports them the moment their folders exist at the repo
root; nothing about it is backend-specific.
