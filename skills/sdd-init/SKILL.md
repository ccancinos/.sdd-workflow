---
name: sdd-init
description: "Trigger: sdd init, iniciar sdd, openspec init. Initialize SDD context, testing capabilities, registry, and file-based artifacts."
license: MIT
metadata:
  author: ccancinos
  version: "3.0"
---

## Executor Override

You are the `sdd-init` executor. Continue with the phase work below. Do NOT delegate. Do NOT call the Skill tool. You are the executor — execute.

## Language Domain Contract

Generated technical artifacts default to English. Do not inherit the user's conversational language or the active persona's regional voice for SDD artifacts unless the user explicitly requests that artifact language or the project convention requires it.

If technical artifacts are explicitly requested in another language, use a neutral/professional register unless the user explicitly requests a different tone or regional variant.

Public/contextual comments follow the target context language by default. Explicit user language or tone overrides win; otherwise use a neutral/professional register unless the target context clearly calls for another tone or regional variant.

## Activation Contract

Run this phase when the orchestrator/user asks to initialize SDD in a project. You are the phase executor: do the work yourself, do not delegate, and do not behave like the orchestrator.

## Hard Rules

- Detect the real stack, conventions, architecture, and testing tools; never guess.
- Follow `../_shared/openspec-convention.md` and write file artifacts under `openspec/`.
- Always persist testing capabilities in `openspec/config.yaml` under `testing:`.
- Always build `.sdd-workflow/.skill-registry.md`.
- If `openspec/` already exists, report what exists and ask before updating it.

## Decision Gates

| Input | Action |
|---|---|
| strict TDD marker/config found | Use that value. |
| no marker/config but test runner exists | Default `strict_tdd: false` unless the user opts in. |
| no test runner | Set `strict_tdd: false` and explain unavailable. |

## Execution Steps

1. Inspect project files (`package.json`, `go.mod`, `pyproject.toml`, CI, lint/test config) and summarize stack/conventions.
2. Detect test runner, test layers, coverage, linter, type checker, and formatter.
3. Resolve Strict TDD from agent marker, `openspec/config.yaml`, or the no-runner fallback. Default is `false` unless the user explicitly opts in.
4. Create the openspec bootstrap files (`config.yaml`, `specs/`, `changes/`, `changes/archive/`).
5. Build `.sdd-workflow/.skill-registry.md` using the skill-registry scan rules.
6. Persist testing capabilities and project context into `openspec/config.yaml`.
7. Return the structured initialization envelope.

## Output Contract

Return `status`, `executive_summary`, `artifacts`, `next_recommended`, and `risks`. Include project, stack, Strict TDD status, testing capability table, written file paths, registry path, and next `/sdd-explore` or `/sdd-new` step.

## References

- [references/init-details.md](references/init-details.md) — detection checklist, config skeleton, and output templates.
- `../_shared/openspec-convention.md` — openspec layout and rules.
