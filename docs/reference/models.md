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

Add a `model:` line to the agent's frontmatter in `.sdd-workflow/agents/<agent>.md`.

**OpenCode** — value is a full `provider/model-id`:

```yaml
---
name: sdd-tasks
mode: subagent
model: openai/gpt-5.6-luna
# ... existing tools / permission blocks ...
---
```

**Claude Code** — value is an alias (`opus` / `sonnet` / `haiku`), a full model ID, or `inherit`:

```yaml
---
name: sdd-tasks
mode: subagent
model: haiku
# ... existing tools / permission blocks ...
---
```

### Setting `model:` across both harnesses

This is a preference, not a requirement — leave it unset and each agent uses its default model. If
you do set it, note that the two harnesses read `model:` with **different value formats**:

- **OpenCode:** `model: provider/model-id` — e.g. `openai/gpt-5.6-terra` or
  `anthropic/claude-sonnet-4-...`. If omitted, a subagent inherits the invoking agent's model.
- **Claude Code:** `model:` takes an alias (`opus` / `sonnet` / `haiku`), a full model ID, or
  `inherit`. If omitted, it defaults to `inherit`.

A single shared `model:` value won't be valid in both at once, so set it in the format of the
harness you're running and adjust if you switch. Claude Code also honors the
`CLAUDE_CODE_SUBAGENT_MODEL` environment variable as a session-wide override. Confirm current model
IDs against the OpenCode and Anthropic/OpenAI docs before setting them, since model names change
often.
