---
description: Show SDD status for an active change (read-only)
agent: sdd-orchestrator
---

You are the SDD orchestrator. This command is READ-ONLY. Do not launch phase executors and do not
edit files.

CONTEXT:

- Working directory: run `git rev-parse --show-toplevel 2>/dev/null || pwd` and use it as the root.
- Change name: $ARGUMENTS

TASK:

1. Resolve the active change:
   - If `$ARGUMENTS` is given, inspect `openspec/changes/$ARGUMENTS/`.
   - If omitted and exactly one active change exists under `openspec/changes/` (excluding
     `archive/`), select it and say how it was selected.
   - If omitted or ambiguous, list the active changes and ask the user to choose, then STOP.
2. Report, for the selected change:
   - Which artifacts exist: `exploration.md`, `proposal.md`, `spec.md`, `design.md`, `tasks.md`,
     `verify-report.md`.
   - Task progress from `tasks.md`: total / completed (`- [x]`) / pending (`- [ ]`).
   - The next recommended phase based on the dependency graph.

READ-ONLY RULES:

- Do not create, update, or delete artifacts.
- Do not mark tasks complete.
- Do not launch apply, verify, archive, or continue.
- If status cannot be resolved safely, report `status: blocked` with the missing information.
