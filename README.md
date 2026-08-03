# Documentation

**A workflow harness for AI-assisted software engineering.** It puts a real engineering process
around an AI agent, so building software with AI becomes a sequence of bounded, reviewable steps —
not a big prompt you throw at the model while hoping the fix-it loop eventually converges.

Spec-Driven Development (SDD) is the **first workflow encoded in the harness**, not the product
itself. The product is the architecture: an orchestrator, specialized agents, file-based artifacts,
approval gates, and per-agent permissions.

> **AI should not replace the engineering process — it should operate inside one.**

## Quick start

```bash
git clone <your-fork-url> .sdd-workflow      # inside your project / umbrella dir
.sdd-workflow/bin/link.sh --opencode --claude
.sdd-workflow/bin/skill-registry.sh
```

Then, in your agent: `/sdd-new my-feature` (OpenCode) or ask the `sdd-orchestrator` to start SDD.
Full steps in [`docs/guides/install.md`](docs/guides/install.md).

## What do you want to know next?

New here? Read top to bottom.

**`concepts/` — the WHY (start here)**

| Doc | Read it to… |
| --- | --- |
| [`overview.md`](docs/concepts/overview.md) | Understand what this is, the problem it solves, and the philosophy |
| [`architecture.md`](docs/concepts/architecture.md) | Understand how it's built — the four principles + SDD as the first workflow |

**`guides/` — the HOW (task-oriented)**

| Doc | Read it to… |
| --- | --- |
| [`install.md`](docs/guides/install.md) | Attach/detach it to a project (single repo vs. umbrella) |
| [`workflow.md`](docs/guides/workflow.md) | Run a change end to end — start, stop, resume, rework |

**`reference/` — lookups & opt-in config**

| Doc | Read it to… |
| --- | --- |
| [`commands.md`](docs/reference/commands.md) | Look up the canonical command list |
| [`permissions.md`](docs/reference/permissions.md) | Harden it with the opt-in secrets deny-list |
| [`context7.md`](docs/reference/context7.md) | Add live library docs (Context7 MCP server) |

## The idea, in one paragraph

The bottleneck in AI-assisted development isn't the model's ability to write code — it's **entropy**:
long conversations drift, context stays implicit, decisions scatter, and the model re-reconstructs
intent every turn. This harness reduces entropy by **replacing conversational state with explicit,
Git-tracked artifacts**, **treating each artifact as a contract for the next phase**, **orchestrating
specialized agents whose boundaries are enforced by permissions**, and **keeping a human at approval
gates that progressively narrow the solution space**. Better models reduce implementation mistakes;
better workflows reduce engineering mistakes. This project is about the second problem — which is why
it stays valuable no matter how good the models get.
