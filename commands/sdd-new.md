---
description: Start a new SDD change — runs exploration then creates a proposal
agent: sdd-orchestrator
---

Follow the SDD orchestrator workflow to start a new change named "$ARGUMENTS".

WORKFLOW:

1. Complete Session Preflight: resolve the workspace root
   (`git rev-parse --show-toplevel 2>/dev/null || pwd`), confirm the change name, ensure
   `openspec/config.yaml` exists (delegate `sdd-init` if missing), and read
   `.sdd-workflow/.skill-registry.md` if present.
2. Delegate the `sdd-explore` sub-agent to investigate the codebase for this change.
3. Present the exploration summary to the user and STOP for approval.
4. After approval, delegate the `sdd-propose` sub-agent to create the proposal.
5. Present the proposal summary and ask whether to continue with spec and design.

CONTEXT:

- Change name: $ARGUMENTS
- Artifacts live in `openspec/changes/$ARGUMENTS/` (exploration.md, proposal.md, …).

Do NOT execute phase work inline — delegate to sub-agents, and honor approval gates between phases.
