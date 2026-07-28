# Usage

`.sdd-workflow` is a self-contained, git-clonable toolkit that adds a Spec-Driven Development (SDD)
workflow — an orchestrator, 10 phase agents, slash commands, and a curated skill library — to
**OpenCode** and **Claude Code**. It attaches to any project via symlinks and detaches cleanly.

Nothing is installed globally. No binary rewrites your config. The scripts only create symlinks
(plus, optionally, one persona-reference line). Everything else — permissions, Context7 — is
documentation you apply yourself.

---

## Install into a project

From the directory you want to work in (a single repo, or an umbrella directory that groups several
service repos):

```bash
git clone <your-fork-url> .sdd-workflow
.sdd-workflow/bin/link.sh --opencode --claude
```

- `--opencode` wires OpenCode (`.opencode/agents`, `.opencode/commands`).
- `--claude` wires Claude Code (`.claude/agents`, `.claude/commands`, `.claude/skills`).
- Omit both to wire **both**.
- Add `--persona` to also reference the persona file from `AGENTS.md` / `CLAUDE.md` (opt-in).

Then build the skill registry once:

```bash
.sdd-workflow/bin/skill-registry.sh
```

That's it. Open your agent from this directory and use `/sdd-new <change-name>` (OpenCode) or ask
the `sdd-orchestrator` agent to start SDD.

---

## Single repo vs. umbrella (microservices)

Both agents resolve their config by looking in the current directory first, then walking up to the
nearest git root. Two supported layouts:

### Single git repo

```
my-repo/            <- git repo, you launch the agent here
├── .sdd-workflow/
├── .opencode/      <- symlinks (created by link.sh)
├── .claude/        <- symlinks (created by link.sh)
└── openspec/       <- SDD artifacts land here
```

### Umbrella directory (no git needed at the umbrella)

```
work/               <- NOT a git repo; just a grouping dir. Launch the agent HERE.
├── .sdd-workflow/
├── .opencode/      <- symlinks
├── .claude/        <- symlinks
├── openspec/       <- SDD artifacts land here (umbrella level)
├── service-a/      <- its own git repo
└── service-b/      <- its own git repo
```

**Launch your agent from the umbrella root** (`work/`). Config resolves from the current directory
before any git boundary, so the umbrella does not need to be a git repo. The agent can still read
and edit files inside `service-a/` and `service-b/` normally.

> Tip: if you instead `cd service-a && opencode`, the agent may resolve config from `service-a/`'s
> own git root and miss the umbrella config. In that case, either launch from the umbrella root, or
> clone `.sdd-workflow` into that service and run `link.sh` there too (per-service attach).

---

## The SDD workflow

Ten phases, each a focused sub-agent. The orchestrator delegates to them and **stops for your
approval between phases**. Each phase reads the previous phase's file and writes its own — the files
under `openspec/changes/<change-name>/` are the entire handoff; there is no hidden state.

```
explore → propose → spec → design → tasks → apply → verify → archive
```

| Command | What it does |
| --- | --- |
| `/sdd-new <name>` | Start a change: explore, then propose (with approval gates). |
| `/sdd-continue [name]` | Run the next phase in the dependency chain. |
| `/sdd-status [name]` | Read-only: show which artifacts exist and the next phase. |
| `/sdd-ff <name>` | Fast-forward the planning phases (propose → tasks). Stops before apply. |

Small requests don't need any of this — the orchestrator just does them inline. Say "use sdd" when
you want the structured flow.

For a full worked example — running a change end to end, and how to start, stop, resume, restart,
and rework any phase — see [`workflow.md`](workflow.md).

### Strict TDD (optional, off by default)

`openspec/config.yaml` (copied from `.sdd-workflow/templates/openspec-config.yaml` by `sdd-init`)
has `strict_tdd: false` by default. Leave it off to decide tests case by case or write them at the
end; set it to `true` to make `sdd-apply` work RED → GREEN → REFACTOR and `sdd-verify` audit the
evidence.

---

## Updating after you add/remove artifacts

`link.sh` is idempotent. After adding or removing an agent/command/skill, just re-run:

```bash
.sdd-workflow/bin/link.sh --opencode --claude
.sdd-workflow/bin/skill-registry.sh    # if you changed skills
```

It reconciles the symlinks (adds new, removes stale) — no separate update command needed.

### Creating a new artifact

```bash
.sdd-workflow/bin/new-artifact.sh skill   my-skill    "When to use this."
.sdd-workflow/bin/new-artifact.sh agent   my-agent    "What this agent does."
.sdd-workflow/bin/new-artifact.sh command my-command  "What this command does."
```

It scaffolds a spec-correct file with frontmatter that works in both agents, then reminds you to
re-link and re-index. You can also add your own curated skills by copying a skill
directory into `.sdd-workflow/skills/` and re-running `link.sh` + `skill-registry.sh`.

---

## Uninstall

```bash
.sdd-workflow/bin/unlink.sh
rm -rf .sdd-workflow
```

`unlink.sh` removes exactly what `link.sh` created (tracked in `.sdd-workflow/.link-manifest`):
every symlink, the managed persona block, and any empty `.opencode`/`.claude` dirs or persona files
it created. Your own files — source, `openspec/` artifacts, a hand-written `opencode.json`, a
pre-existing `AGENTS.md` — are never touched.

---

## Why symlinks, one file per agent

Each agent file uses a **superset frontmatter**: it carries both Claude Code's `tools:` block and
OpenCode's `permission:` block. Both parsers ignore keys they don't recognize, so a single physical
file, symlinked into both `.opencode/agents/` and `.claude/agents/`, drives both agents with no
duplication and no risk of the two drifting out of sync.

Skills go into a **single** location, `.claude/skills/`, which OpenCode reads natively — so a skill
is registered exactly once even when both agents are wired.

See `docs/permissions.md` and `docs/context7.md` for the opt-in security deny-list and live-docs
MCP server.
