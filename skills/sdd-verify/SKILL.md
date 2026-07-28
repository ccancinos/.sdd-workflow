---
name: sdd-verify
description: "Trigger: SDD verification phase, verify change. Execute tests and prove implementation matches specs, design, and tasks."
license: MIT
metadata:
  author: ccancinos
  version: "3.0"
---

## Executor Override

You are the `sdd-verify` executor. Continue with the phase work below. Do NOT delegate. Do NOT call the Skill tool. You are the executor — execute.

## Language Domain Contract

Generated technical artifacts default to English. Do not inherit the user's conversational language or the active persona's regional voice for SDD artifacts unless the user explicitly requests that artifact language or the project convention requires it.

If technical artifacts are explicitly requested in another language, use a neutral/professional register unless the user explicitly requests a different tone or regional variant.

Public/contextual comments follow the target context language by default. Explicit user language or tone overrides win; otherwise use a neutral/professional register unless the target context clearly calls for another tone or regional variant.

## Activation Contract

Run when the orchestrator launches verification for an SDD change. You are the quality gate: prove completion with source inspection plus real execution evidence.

Read the change artifacts under `openspec/changes/{change-name}/` — proposal, specs, design, and tasks — before judging the implementation.

## Hard Rules

- Read all available change artifacts before judging implementation. Full verification reads proposal, specs, design, and tasks; partial artifact sets degrade as described below.
- Run full verification only after all tasks are complete. If any task is pending, return `blocked` without running the full suite.
- Execute relevant tests; static analysis alone is never verification.
- A spec scenario is compliant only when a covering test passed at runtime.
- Compare specs first, design second, task completion third.
- Do not fix issues; report them for the orchestrator/user.
- Write the verification report to `openspec/changes/{change-name}/verify-report.md`, including a valid `FAIL` verdict when appropriate.
- Resolve Strict TDD from `openspec/config.yaml` (`strict_tdd`). If Strict TDD is active AND a test runner exists, load `strict-tdd-verify.md` from this skill directory; if inactive, never load it. Strict TDD defaults to `false`.
- Count the actual requirements and scenarios from the specs; never invent totals.
- Record current test/build commands, exit codes, and results in the report.
- Return the Section D envelope from `../_shared/sdd-phase-common.md`.

## Decision Gates

| Condition | Action |
|---|---|
| Config `strict_tdd: true` and runner exists | Strict TDD verify; load module. |
| Strict TDD false or no runner | Standard verify; skip TDD checks. |
| Only tasks artifact exists | Verify task completion only; skip spec/design correctness and record skipped checks. |
| Tasks + specs exist | Verify completeness and correctness; skip design coherence and record skipped checks. |
| Proposal/specs/design/tasks exist | Verify all dimensions. |
| Task incomplete | CRITICAL for core task, WARNING for cleanup task. |
| Test command exits non-zero | CRITICAL. |
| Spec scenario has no passing covering test | CRITICAL `UNTESTED` or `FAILING`. |
| Design deviation exists | WARNING unless it breaks a spec. |

## Execution Steps

1. Load relevant skills via shared SDD Section A.
2. Read the concrete change artifacts under `openspec/changes/{change-name}/`.
3. Resolve testing/TDD mode from `openspec/config.yaml` or project files.
4. Count completed and incomplete tasks. Any unchecked task blocks full verification.
5. If specs exist, map each spec requirement/scenario to implementation evidence and tests.
6. If design exists, check design decisions against changed code. If design is missing, skip design coherence and record why.
7. Run test, build/type-check, and coverage commands when available. Source inspection alone does not prove spec scenario compliance.
8. Build the behavioral compliance matrix from actual test results when specs/scenarios exist.
9. Write and return the verification report, including skipped dimensions for missing artifacts.

## Output Contract

Return `## Verification Report` with change, mode, completeness table, build/tests/coverage evidence, spec compliance matrix, correctness table, design coherence table, issues grouped as CRITICAL/WARNING/SUGGESTION, and final verdict `PASS`, `PASS WITH WARNINGS`, or `FAIL`. See `references/report-format.md` for the full template.

## Graceful Artifact Handling

- **Tasks only**: verify objective task completion only. Do not claim spec correctness or design coherence. If all tasks are checked and no runtime evidence is available, verdict may be `PASS WITH WARNINGS` for task completion only.
- **Tasks + specs**: verify task completeness and requirement/scenario correctness. Runtime test evidence is still required for full spec scenario compliance; missing covering tests are CRITICAL for required scenarios unless project config explicitly allows manual verification.
- **Full artifacts**: verify completeness, correctness, and coherence.
- **Unchecked tasks**: always remain CRITICAL, even when other artifacts are missing or warnings-only.

## References

- [references/report-format.md](references/report-format.md) — full report template and compliance statuses.
- [strict-tdd-verify.md](strict-tdd-verify.md) — load only when Strict TDD is active.
- `../_shared/sdd-phase-common.md` — skill loading, persistence, and return envelope.
