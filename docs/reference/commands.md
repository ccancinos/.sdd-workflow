# Commands Reference

The canonical list of slash commands. In **OpenCode** these are slash commands; in **Claude Code**
there's no slash trigger — phrase them as requests to the `sdd-orchestrator` agent (e.g. "continue
the SDD change add-rate-limiting").

| Command | What it does |
| --- | --- |
| `/sdd-new <name>` | Start a change: runs `explore`, then `propose`, with an approval gate after each. |
| `/sdd-continue [name]` | Run the next phase in the dependency chain — the first phase whose inputs exist but whose own output doesn't. Never overwrites existing files. |
| `/sdd-status [name]` | Read-only: show which artifacts exist and the next recommended phase. Makes no changes. |
| `/sdd-ff <name>` | Fast-forward the planning phases (`propose → spec → design → tasks`). Stops before `apply`. |

All four are backed by the `sdd-orchestrator` agent, which delegates the actual phase work to
focused sub-agents and stops at each approval gate.

---

## Details

### `/sdd-new <name>`

Starts a new change. Runs the one-time **Session Preflight** (resolve workspace root, confirm the
kebab-case change name, delegate `sdd-init` if `openspec/config.yaml` is missing, read the skill
registry), then runs `explore` and `propose` with a gate after each. Artifacts land in
`openspec/changes/<name>/`.

### `/sdd-continue [name]`

Resumes an in-progress change by running the next phase in the dependency graph:

```
explore → propose → [spec ∥ design] → tasks → apply → verify → archive
```

The "next phase" is the first one whose required inputs exist but whose own output does not. For
`apply`, the next phase becomes `verify` once every task in `tasks.md` is `- [x]`. It never touches
existing files — nothing is overwritten. If `name` is omitted and more than one active change
exists, the orchestrator asks you to choose and stops.

### `/sdd-status [name]`

Read-only inspection. Lists which artifacts exist for the change and the next recommended phase.
Makes no changes — safe to run anytime. With no `name` and multiple active changes, it lists them.

### `/sdd-ff <name>`

Fast-forwards the four **planning** phases: `propose → spec → design → tasks`. Asks once whether to
run **interactive** (stop for approval after each phase) or **auto** (run all four, then present a
combined summary); defaults to interactive. It stops at `tasks` and never runs `apply`, `verify`, or
`archive` — those remain separate, explicitly approved steps.

---

## Rework (no dedicated command yet)

There's no rework command. Re-run a phase by asking the orchestrator directly, and remember that
downstream files are **not** auto-invalidated — cascade explicitly:

```
re-run sdd-spec with that change, then re-run sdd-design and sdd-tasks to match.
```

See [`guides/workflow.md`](../guides/workflow.md#stop-resume-restart-rework) for the full rework
mechanics.

---

## See also

- Run a change end to end: [`guides/workflow.md`](../guides/workflow.md)
- What each phase does and which agent runs it: [`guides/workflow.md`](../guides/workflow.md#what-each-phase-does)
- Why the gates and agents work this way: [`concepts/architecture.md`](../concepts/architecture.md)
