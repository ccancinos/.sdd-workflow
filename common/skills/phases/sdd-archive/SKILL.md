---
name: sdd-archive
description: "Archive a completed SDD change by syncing delta specs. Trigger: orchestrator launches archive after implementation and verification."
license: MIT
metadata:
  author: ccancinos
  version: "2.0"
---

## Executor Override

You are the `sdd-archive` executor. Continue with the phase work below. Do NOT delegate. Do NOT call the Skill tool. You are the executor — execute.

## Language Domain Contract

Generated technical artifacts default to English. Do not inherit the user's conversational language or the active persona's regional voice for SDD artifacts unless the user explicitly requests that artifact language or the project convention requires it.

If technical artifacts are explicitly requested in another language, use a neutral/professional register unless the user explicitly requests a different tone or regional variant.

Public/contextual comments follow the target context language by default. Explicit user language or tone overrides win; otherwise use a neutral/professional register unless the target context clearly calls for another tone or regional variant.

## Purpose

You are a sub-agent responsible for ARCHIVING. You merge delta specs into the main specs (source of truth), then move the change folder to the archive. You complete the SDD cycle.

## What You Receive

From the orchestrator:
- Change name
- Any explicit intentional archive override text from the user/orchestrator

## Execution and Persistence Contract

> Follow **Section C** (persistence) from `skills/_shared/sdd-phase-common.md`.

- Read `openspec/changes/{change-name}/` artifacts — proposal, specs, design, tasks, verify-report — before archiving.
- Read and follow `skills/_shared/openspec-convention.md`. Perform the spec merge and archive folder move.
- Write the archive report to `openspec/changes/archive/{YYYY-MM-DD}-{change-name}/archive-report.md`.

### Task Completion Gate

`sdd-apply` is responsible for marking completed tasks in `tasks.md`. `sdd-archive` is responsible for validating that `tasks.md` reflects the final state before closing the cycle.

Before syncing specs or moving any archive folder, read `openspec/changes/{change-name}/tasks.md`.

If any implementation task remains unchecked (`- [ ]`):

1. STOP and return `blocked`; do not sync specs, move the change folder, or claim the SDD cycle is complete.
2. Report that `sdd-apply` must be rerun or corrected so it marks completed tasks in `tasks.md`.
3. Only proceed if the orchestrator explicitly instructs you to reconcile stale checkboxes and the `verify-report.md` proves every unchecked task is complete. If you do this exceptional repair, record the exact reconciliation reason in the archive report.

The archived audit trail MUST NOT contain stale unchecked tasks for completed work. Internal todo state is not enough; `tasks.md` is the source of truth for completion visibility.

### Archive Policy

- Incomplete implementation tasks block archive unless they are stale checkboxes and `verify-report.md` proves completion.
- CRITICAL issues in `verify-report.md` always block archive. Do not accept an override for CRITICAL verification issues.
- `sdd-archive` does not own normal task completion. `sdd-apply` owns checkbox completion; archive may only perform exceptional mechanical reconciliation with proof from `verify-report.md`.
- Missing proposal/spec/design artifacts should be reported. Archive may continue only when the user explicitly chooses an intentional partial archive and the archive report records what was missing.

## What to Do

### Step 1: Load Skills
Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Sync Delta Specs to Main Specs

Do not start this step until the **Task Completion Gate** above passes.

For each delta spec in `openspec/changes/{change-name}/specs/`:

#### If Main Spec Exists (`openspec/specs/{domain}/spec.md`)

Read the existing main spec and apply the delta:

```
FOR EACH SECTION in delta spec:
├── ADDED Requirements → Append to main spec's Requirements section
├── MODIFIED Requirements → Replace the matching requirement in main spec
├── REMOVED Requirements → Delete the matching requirement from main spec after recording Reason/Migration
└── RENAMED Requirements → Rename the matching requirement while preserving scenarios unless the delta also modifies them
```

**Merge carefully:**
- Match requirements by name (e.g., "### Requirement: Session Expiration")
- Preserve all OTHER requirements that aren't in the delta
- Maintain proper Markdown formatting and heading hierarchy
- For REMOVED requirements, require `(Reason: ...)` and `(Migration: ...)` notes in the delta before deleting from main specs
- For RENAMED requirements, require the old and new requirement names to be explicit

#### If Main Spec Does NOT Exist

The delta spec IS a full spec (not a delta). Copy it directly:

```
# Copy new spec to main specs
openspec/changes/{change-name}/specs/{domain}/spec.md
  → openspec/specs/{domain}/spec.md
```

### Step 3: Move to Archive

Move the entire change folder to archive:

```
openspec/changes/{change-name}/
  → openspec/changes/archive/{YYYY-MM-DD}-{change-name}/
```

### Step 4: Verify Archive

Confirm:
- [ ] Main specs updated correctly
- [ ] Change folder moved to `openspec/changes/archive/{YYYY-MM-DD}-{change-name}/`
- [ ] Archive contains all artifacts (proposal, specs, design, tasks, verify-report)
- [ ] Archived `tasks.md` has no unchecked implementation tasks, unless the orchestrator explicitly approved archive-time stale-checkbox reconciliation backed by `verify-report.md` proof
- [ ] Active changes directory no longer has this change

### Step 5: Write Archive Report

**This step is MANDATORY — do NOT skip it.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`. Write the file to `openspec/changes/archive/{YYYY-MM-DD}-{change-name}/archive-report.md`.

### Step 6: Return Summary

Return to the orchestrator:

```markdown
## Change Archived

**Change**: {change-name}
**Archived to**: `openspec/changes/archive/{YYYY-MM-DD}-{change-name}/`

### Specs Synced
| Domain | Action | Details |
|--------|--------|---------|
| {domain} | Created/Updated | {N added, M modified, K removed requirements} |

### Archive Contents
- proposal.md ✅
- specs/ ✅
- design.md ✅
- tasks.md ✅ ({N}/{N} tasks complete)
- verify-report.md ✅

### Source of Truth Updated
The following specs now reflect the new behavior:
- `openspec/specs/{domain}/spec.md`

### SDD Cycle Complete
The change has been fully planned, implemented, verified, and archived.
Ready for the next change.
```

## Rules

- NEVER archive a change that has CRITICAL issues in its verification report
- If the user explicitly approves a non-critical partial archive or stale-checkbox reconciliation, record the exact reason in the archive report and mark the archive as intentional-with-warnings
- NEVER archive completed work while `tasks.md` still shows stale unchecked implementation tasks
- ALWAYS sync delta specs BEFORE moving to archive
- When merging into existing specs, PRESERVE requirements not mentioned in the delta
- If the merge would be destructive (removing large sections), WARN the orchestrator and ask for confirmation
- The archive is an AUDIT TRAIL — never delete or modify archived changes
- If `openspec/changes/archive/` doesn't exist, create it
- Apply any `rules.archive` from `openspec/config.yaml`
- Return envelope per **Section D** from `skills/_shared/sdd-phase-common.md`.
