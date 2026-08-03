# Install & Attach

Attach the harness to any project in three commands, detach it in one. Nothing is installed
globally; no binary rewrites your config. The scripts only create symlinks (plus, optionally, one
persona-reference line). Everything else — permissions, Context7 — is opt-in config you apply
yourself.

## Quick path

First you *cd* into your project / umbrella dir

```bash
git clone <your-fork-url> .sdd-workflow
.sdd-workflow/bin/link.sh --opencode --claude
.sdd-workflow/bin/skill-registry.sh
```

Then, in your agent: `/sdd-new my-feature` (OpenCode) or ask the `sdd-orchestrator` to start SDD.

To detach: `.sdd-workflow/bin/unlink.sh`.

---

## What `link.sh` wires

| Flag | Wires |
| --- | --- |
| `--opencode` | OpenCode: `.opencode/agents`, `.opencode/commands` |
| `--claude` | Claude Code: `.claude/agents`, `.claude/commands`, `.claude/skills` |
| *(omit both)* | Wires **both** |
| `--persona` | Also references the persona file from `AGENTS.md` / `CLAUDE.md` (opt-in) |

Then build the skill registry once so the orchestrator can hand exact skill paths to sub-agents:

```bash
.sdd-workflow/bin/skill-registry.sh
```

That's it. Open your agent from this directory and start a change.

---

## Single repo vs. umbrella (microservices)

Both agents resolve config from the current directory first, then walk up to the nearest git root.
Two supported layouts:

### Single git repo

```
my-repo/            <- git repo, you launch the agent here
├── .sdd-workflow/
├── .opencode/      <- symlinks (created by link.sh)
├── .claude/        <- symlinks (created by link.sh)
└── openspec/       <- workflow artifacts land here
```

### Umbrella directory (no git needed at the umbrella)

```
work/               <- NOT a git repo; just a grouping dir. Launch the agent HERE.
├── .sdd-workflow/
├── .opencode/      <- symlinks
├── .claude/        <- symlinks
├── openspec/       <- artifacts land here (umbrella level)
├── service-a/      <- its own git repo
└── service-b/      <- its own git repo
```

**Launch your agent from the umbrella root** (`work/`). Config resolves from the current directory
before any git boundary, so the umbrella doesn't need to be a git repo. The agent can still read and
edit files inside `service-a/` and `service-b/` normally.

> Tip: if you instead `cd service-a && opencode`, the agent may resolve config from `service-a/`'s
> own git root and miss the umbrella config. In that case, either launch from the umbrella root, or
> clone `.sdd-workflow` into that service and run `link.sh` there too (per-service attach).

---

## Update after adding/removing artifacts

`link.sh` is idempotent — it reconciles symlinks (adds new, removes stale). After adding or removing
an agent/command/skill, just re-run:

```bash
.sdd-workflow/bin/link.sh --opencode --claude
.sdd-workflow/bin/skill-registry.sh    # if you changed skills
```

### Create a new artifact

```bash
.sdd-workflow/bin/new-artifact.sh skill   my-skill    "When to use this."
.sdd-workflow/bin/new-artifact.sh agent   my-agent    "What this agent does."
.sdd-workflow/bin/new-artifact.sh command my-command  "What this command does."
```

It scaffolds a spec-correct file with frontmatter that works in both agents, then reminds you to
re-link and re-index. You can also add your own curated skills by copying a skill directory into
`.sdd-workflow/skills/` and re-running `link.sh` + `skill-registry.sh`.

---

## Strict TDD (optional, off by default)

`openspec/config.yaml` (copied from `.sdd-workflow/templates/openspec-config.yaml` by `sdd-init`)
has `strict_tdd: false` by default. Leave it off to decide tests case by case or write them at the
end; set it to `true` to make `sdd-apply` work RED → GREEN → REFACTOR and `sdd-verify` audit the
evidence.

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

---

## Next steps

- Run your first change end to end: [`guides/workflow.md`](workflow.md).
- Look up commands: [`reference/commands.md`](../reference/commands.md).
- Harden it: opt-in [`reference/permissions.md`](../reference/permissions.md) deny-list and
  [`reference/context7.md`](../reference/context7.md) live-docs MCP server.
