---
description: Fast-forward SDD planning phases — proposal through tasks
agent: sdd-orchestrator
---

Follow the SDD orchestrator workflow to fast-forward the planning phases for change "$ARGUMENTS".

Planning phases, in order:

1. `sdd-propose` — create the proposal
2. `sdd-spec` — write specifications
3. `sdd-design` — create the technical design
4. `sdd-tasks` — break down into implementation tasks

BEHAVIOR:

- Ask the user once whether to run in **interactive** mode (stop for approval after each planning
  phase) or **auto** mode (run all four back-to-back, then present a combined summary). Default to
  interactive if the user does not answer.
- In interactive mode, run only the next planning phase, present its summary and artifact path(s),
  and STOP until the user confirms.
- Stop at `sdd-tasks`. This command never runs `sdd-apply`, `sdd-verify`, or `sdd-archive` — those
  are separate, explicitly approved steps.

CONTEXT:

- Change name: $ARGUMENTS
- Artifacts live in `openspec/changes/$ARGUMENTS/`.

Do NOT execute phase work inline — delegate to sub-agents.
