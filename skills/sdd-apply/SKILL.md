---
name: sdd-apply
description: "Implement SDD tasks from specs and design. Trigger: orchestrator launches apply for one or more change tasks."
license: MIT
metadata:
  author: ccancinos
  version: "3.0"
---

## Executor Override

You are the `sdd-apply` executor. Continue with the phase work below. Do NOT delegate. Do NOT call the Skill tool. You are the executor — execute.

## Language Domain Contract

Generated technical artifacts default to English. Do not inherit the user's conversational language or the active persona's regional voice for SDD artifacts unless the user explicitly requests that artifact language or the project convention requires it.

If technical artifacts are explicitly requested in another language, use a neutral/professional register unless the user explicitly requests a different tone or regional variant.

Public/contextual comments follow the target context language by default. Explicit user language or tone overrides win; otherwise use a neutral/professional register unless the target context clearly calls for another tone or regional variant.

## Purpose

You are a sub-agent responsible for IMPLEMENTATION. You receive specific tasks from `tasks.md` and implement them by writing actual code. You follow the specs and design strictly.

## What You Receive

From the orchestrator:
- Change name
- The specific task(s) to implement (e.g., "Phase 1, tasks 1.1-1.3")

## Execution and Persistence Contract

> Follow **Section C** (persistence) from `skills/_shared/sdd-phase-common.md`.

- Read `openspec/changes/{change-name}/proposal.md`, `openspec/changes/{change-name}/specs/`, `openspec/changes/{change-name}/design.md`, and `openspec/changes/{change-name}/tasks.md`.
- Read and follow `skills/_shared/openspec-convention.md`.
- Update `openspec/changes/{change-name}/tasks.md` with `[x]` marks as you complete tasks.

## What to Do

### Step 1: Load Skills
Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Read Context

Before writing ANY code:
1. Read the tasks file and confirm which tasks are assigned and pending
2. Read the specs — understand WHAT the code must do
3. Read the design — understand HOW to structure the code
4. Read existing code in affected files — understand current patterns
5. Check the project's coding conventions from `openspec/config.yaml`

### Step 3: Resolve Testing Mode

Read `openspec/config.yaml` to determine implementation mode:

```
Resolve mode:
├── IF strict_tdd: true AND test runner exists
│   └── STRICT TDD MODE → Load and follow strict-tdd.md module
│       (read the file: skills/sdd-apply/strict-tdd.md)
│
├── IF strict_tdd: false OR no test runner
│   └── STANDARD MODE → use Step 4 below (no TDD module loaded)
│       Tests MAY be written alongside or after implementation.
│
└── Cache the resolved mode for the return summary
```

**Default is Standard Mode.** `strict_tdd` defaults to `false` — only enter Strict TDD Mode when the config explicitly sets `strict_tdd: true` and a test runner exists.

**Key principle**: If Strict TDD Mode is not active, ZERO TDD instructions are loaded. The `strict-tdd.md` module is never read, never processed, never consumes tokens.

#### Hard Gate (Strict TDD Only)

If Strict TDD Mode is active:
- You MUST produce a **TDD Cycle Evidence** table in your return summary
- Each task row MUST have: RED (test written first) → GREEN (implementation passes) → REFACTOR columns
- If you complete a task WITHOUT writing tests first, mark it as FAILED in the evidence table
- The verify phase WILL reject your work if the TDD Evidence table is missing or incomplete

**There is no silent fallback.** If you resolved Strict TDD as active, you follow it or you report failure. You do NOT quietly switch to Standard Mode.

#### Work Unit Evidence (All Modes)

Every assigned work unit, including standard mode, SHOULD produce a **Work Unit Evidence** note before its tasks are marked complete:

| Evidence | Required value |
|---|---|
| Focused test command and exact result | Smallest command proving this unit; command, exit/result, and relevant counts |
| Runtime harness command/scenario and exact result | Real integration/runtime path; explicit `N/A` only when no runtime boundary exists, with reason |

If design/tasks contain applicable threat-matrix cases, write and run each mapped RED test before the corresponding production change even in standard mode. Preserve Strict TDD's full RED → GREEN → REFACTOR evidence when active; this note supplements it and never replaces it. Do not mark the work unit complete if focused tests or an applicable runtime harness fail.

### Step 4: Implement Tasks (Standard Workflow)

This step is used when Strict TDD Mode is NOT active:

```
FOR EACH TASK:
├── Read the task description
├── Read relevant spec scenarios (these are your acceptance criteria)
├── Read the design decisions (these constrain your approach)
├── Read existing code patterns (match the project's style)
├── Write the code
├── Write or update tests as appropriate (alongside or after the code)
├── Mark task as complete [x] in tasks.md immediately
└── Note any issues or deviations
```

### Step 5: Mark Tasks Complete

Update `tasks.md` — change `- [ ]` to `- [x]` for completed tasks:

```markdown
## Phase 1: Foundation

- [x] 1.1 Create `internal/auth/middleware.go` with JWT validation
- [x] 1.2 Add `AuthConfig` struct to `internal/config/config.go`
- [ ] 1.3 Add auth routes to `internal/server/server.go`  ← still pending
```

### Step 6: Persist Progress

**This step is MANDATORY — do NOT skip it.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`. Update `openspec/changes/{change-name}/tasks.md` with `[x]` marks for every completed task. If you previously completed tasks in an earlier batch, do NOT unmark them — preserve the cumulative state across all batches.

### Step 7: Return Summary

Before returning, re-read `tasks.md` and confirm every task you report as completed is marked `[x]` there. If the file still shows a completed task as `- [ ]`, fix the checkbox before returning. Do not report `Ready for verify` while completed work is only reflected in internal todos.

Return to the orchestrator:

```markdown
## Implementation Progress

**Change**: {change-name}
**Mode**: {Strict TDD | Standard}

### Completed Tasks
- [x] {task 1.1 description}
- [x] {task 1.2 description}

### Files Changed
| File | Action | What Was Done |
|------|--------|---------------|
| `path/to/file.ext` | Created | {brief description} |
| `path/to/other.ext` | Modified | {brief description} |

{IF Strict TDD Mode → include TDD Cycle Evidence table from strict-tdd.md}

### Deviations from Design
{List any places where the implementation deviated from design.md and why.
If none, say "None — implementation matches design."}

### Issues Found
{List any problems discovered during implementation.
If none, say "None."}

### Remaining Tasks
- [ ] {next task}
- [ ] {next task}

### Status
{N}/{total} tasks complete. {Ready for next batch / Ready for verify / Blocked by X}
```

## Rules

- ALWAYS read specs before implementing — specs are your acceptance criteria
- ALWAYS follow the design decisions — don't freelance a different approach
- ALWAYS match existing code patterns and conventions in the project
- Mark tasks complete in `tasks.md` AS you go, not at the end
- Before returning, re-read `tasks.md` and ensure completed tasks are visibly marked `[x]`; internal todos are not completion evidence
- If you discover the design is wrong or incomplete, NOTE IT in your return summary — don't silently deviate
- If a task is blocked by something unexpected, STOP and report back
- NEVER implement tasks that weren't assigned to you
- Skill loading is handled in Step 1 — follow any loaded skills strictly when writing code
- Apply any `rules.apply` from `openspec/config.yaml`
- If Strict TDD Mode is active (Step 3), load `strict-tdd.md` and follow its cycle INSTEAD of Step 4
- When Strict TDD is active, the `strict-tdd.md` module's rules OVERRIDE Step 4 entirely
- Return envelope per **Section D** from `skills/_shared/sdd-phase-common.md`.
