---
description: Continue the next SDD phase in the dependency chain
agent: sdd-orchestrator
---

Follow the SDD orchestrator workflow to continue the active change "$ARGUMENTS".

WORKFLOW:

1. Resolve the workspace root (`git rev-parse --show-toplevel 2>/dev/null || pwd`).
2. Determine the change: if `$ARGUMENTS` is empty and more than one active change exists under
   `openspec/changes/` (excluding `archive/`), ask the user to choose and STOP. Do not guess.
3. Inspect which artifacts already exist for the change in `openspec/changes/{change-name}/`:
   `exploration.md`, `proposal.md`, `spec.md`, `design.md`, `tasks.md`, `verify-report.md`.
4. Determine the next phase from the dependency graph:
   `explore → propose → [spec ∥ design] → tasks → apply → verify → archive`.
   The next phase is the first one whose required inputs exist but whose own output does not
   (for `apply`, the next phase is `verify` once all tasks in `tasks.md` are `- [x]`).
5. Delegate the appropriate sub-agent for that next phase only.
6. Present the result and STOP for the user's approval before continuing further.

CONTEXT:

- Change name: $ARGUMENTS
- Artifacts live in `openspec/changes/$ARGUMENTS/`.

Do NOT execute phase work inline — delegate to sub-agents, and honor approval gates.
