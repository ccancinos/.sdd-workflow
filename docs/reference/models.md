# Per-Agent Model Selection (opt-in)

Every agent in the harness is its own Markdown file with frontmatter, and both OpenCode and Claude
Code let that frontmatter pin **which model the agent runs on**. Nothing here sets a model by
default — each agent uses whatever your session/global default is. Choosing a model per agent is an
optional optimization you add yourself.

This is [Principle 3 — agents are engineering
boundaries](../concepts/architecture.md#principle-3--agents-are-engineering-boundaries) extended to
**cost and capability**: match each phase's model to how hard that phase actually is.

---

## Why per-agent models help

The phases are not equally demanding. Some do open-ended reasoning and shape the solution space;
others mechanically transform an already-decided contract. Paying top-tier model cost on the
mechanical phases is waste; skimping on the phases where mistakes amplify downstream costs you in
rework. Because each agent is a separate file, you can tune them independently.

It's also safe to go cheaper downstream: gates and contracts (Principles 2 and 4) mean a Fast model
on a late phase is working inside an already-narrowed, human-approved space — so it has far less
room to go wrong than the same model would in a freeform chat.

---

## Terminology: Heavy / Balanced / Fast

To keep the guidance vendor-neutral and durable, name models by the **job they suit**, on a
capability-vs-cost axis:

| Tier | Use when the phase… | Optimizes for |
| --- | --- | --- |
| **Heavy** | Does open-ended reasoning, weighs tradeoffs, or shapes the solution space (mistakes amplify downstream) | Capability over cost |
| **Balanced** | Needs solid general capability at moderate cost/latency — the sensible default | The capability ↔ cost tradeoff |
| **Fast** | Follows an already-fixed contract; mechanical or well-bounded output | Cost & speed over depth |

> These tiers are a lens, not official product classes. Vendors don't label their models exactly
> this way — treat the mapping below as "as of today."

---

## Suggested tier per SDD phase

A starting point, not a mandate. Adjust to your codebase and budget.

| Phase | Nature | Suggested tier |
| --- | --- | --- |
| `explore` | Open-ended investigation, approach comparison | **Heavy** |
| `propose` | Scope and tradeoff decisions | **Heavy** |
| `design` | Architecture decisions; errors amplify downstream | **Heavy** |
| `apply` | Implementation, bounded by spec + design + tasks | **Balanced** (Heavy for complex code) |
| `verify` | Runs checks against an explicit contract | **Balanced** |
| `spec` | Turns an approved proposal into requirements | **Balanced** |
| `tasks` | Decomposes a settled design into ordered units | **Fast** |
| `archive` | Mechanical: merge specs, move folder, write report | **Fast** |
| orchestrator | Routes and summarizes; doesn't need your most expensive model | **Balanced** |

---

## Vendor reference (as of today — verify before use)

| Tier | Anthropic | OpenAI (GPT-5.6 line) | Google Gemini |
| --- | --- | --- | --- |
| **Heavy** | Claude **Opus** family | GPT-5.6 **Sol** (`gpt-5.6-sol`) | Gemini **Pro** |
| **Balanced** | Claude **Sonnet** family | GPT-5.6 **Terra** (`gpt-5.6-terra`) | Gemini **Flash** |
| **Fast** | Claude **Haiku** family | GPT-5.6 **Luna** (`gpt-5.6-luna`) | Gemini **Flash-Lite** |

Pick the current generation within a family — the latest Opus / Sonnet / Haiku, or the latest
GPT-5.x Sol / Terra / Luna. For OpenAI, the **Sol / Terra / Luna** suffix is the tier axis *within* a
generation; the version number (5.6, 5.5, …) is just the generation. Model names and availability
change frequently, so confirm current IDs against the OpenCode and Anthropic/OpenAI docs before
setting them. This mapping reflects the general shape of each vendor's lineup, not an endorsement of
a specific model for a specific phase.

---

## How to set it

Each tool has its own agent file with its own frontmatter format. Edit the file for the tool you
are targeting and add or update the `model:` line. The value format is not interchangeable between
tools — OpenCode requires a provider prefix, Claude Code must not have one.

### OpenCode

File: `.sdd-workflow/opencode/agents/<agent>.md`

Value format: full `provider/model-id`.

```yaml
---
name: sdd-tasks
mode: subagent
model: openai/gpt-5.6-luna
permission:
  # ... existing permission: block ...
---
```

If omitted, a subagent inherits the invoking agent's model.

### Claude Code

File: `.sdd-workflow/claude/agents/<agent>.md`

Value format: bare model ID (no provider prefix), or a short alias (`opus` / `sonnet` / `haiku`),
or `inherit`.

```yaml
---
name: sdd-tasks
mode: subagent
model: claude-haiku-4-5
tools: Read, Edit, Write, Grep, Glob
---
```

If omitted, defaults to `inherit`. Also honors the `CLAUDE_CODE_SUBAGENT_MODEL` environment
variable as a session-wide override.

### Setting the same model in both tools

Because each tool has its own file, you set the correct format in each independently — no manual
switching needed. Example: pinning `sdd-tasks` to Haiku in both:

```yaml
# .sdd-workflow/opencode/agents/sdd-tasks.md
model: anthropic/claude-haiku-4-5

# .sdd-workflow/claude/agents/sdd-tasks.md
model: claude-haiku-4-5
```

Confirm current model IDs against the OpenCode and Anthropic/OpenAI docs before setting them —
model names change often.
