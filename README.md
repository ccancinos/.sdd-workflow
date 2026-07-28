# .sdd-workflow

A portable Spec-Driven Development (SDD) toolkit for **OpenCode** and **Claude Code**. Clone it into
a project, run one script, and your agent gains an SDD orchestrator, 10 phase agents, slash
commands, and a curated skill library — with file-based artifacts, approval gates between phases,
and a shared skill registry. Detach it just as easily.

It's a distilled, dependency-free SDD toolkit: no Go binary, no global install. Just markdown +
symlinks.

## Quick start

```bash
git clone <your-fork-url> .sdd-workflow      # inside your project / umbrella dir
.sdd-workflow/bin/link.sh --opencode --claude
.sdd-workflow/bin/skill-registry.sh
```

Then, in your agent: `/sdd-new my-feature` (OpenCode) or ask the `sdd-orchestrator` to start SDD.

Detach with `.sdd-workflow/bin/unlink.sh`.

## What's inside

| Path | What |
| --- | --- |
| `agents/` | SDD orchestrator + 10 phase agents (superset frontmatter: works in both agents from one file) |
| `commands/` | `/sdd-new`, `/sdd-continue`, `/sdd-status`, `/sdd-ff` |
| `skills/` | SDD phase skills, foundation skills, and shared conventions |
| `persona/` | Optional persona / working-contract, referenced (not copied) into `AGENTS.md`/`CLAUDE.md` |
| `templates/` | `openspec-config.yaml` — per-project SDD config (`strict_tdd: false` by default) |
| `bin/` | `link.sh`, `unlink.sh`, `skill-registry.sh`, `new-artifact.sh` |
| `docs/` | `usage.md`, `permissions.md` (opt-in), `context7.md` (opt-in) |

## Design highlights

- **One file per agent, two symlinks.** Each agent file carries both Claude Code's `tools:` and
  OpenCode's `permission:` blocks; each parser ignores what it doesn't recognize. No duplication, no
  drift.
- **Skills live once** in `.claude/skills/` (OpenCode reads it natively) — registered exactly once
  even with both agents wired.
- **Works from a non-git umbrella directory** grouping several service repos.
- **Clean detach**: `unlink.sh` removes only what `link.sh` created (tracked in a manifest); your
  files are never touched.

See [`docs/usage.md`](docs/usage.md) for install/attach/detach, and
[`docs/workflow.md`](docs/workflow.md) for a worked example of running a change (start, stop,
resume, restart, rework).
