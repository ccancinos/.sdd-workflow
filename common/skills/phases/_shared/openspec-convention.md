# OpenSpec File Convention (shared across all SDD skills)

All SDD artifacts are plain markdown/YAML files under `openspec/` in the workspace root. There is
no database and no hidden state — the files ARE the handoff between phases.

## Directory Structure

```
openspec/
├── config.yaml              <- Project-specific SDD config
├── specs/                   <- Source of truth (main specs)
│   └── {domain}/
│       └── spec.md
└── changes/                 <- Active changes
    ├── archive/             <- Completed changes (YYYY-MM-DD-{change-name}/)
    └── {change-name}/       <- Active change folder
        ├── exploration.md   <- (optional) from sdd-explore
        ├── proposal.md      <- from sdd-propose
        ├── specs/           <- from sdd-spec
        │   └── {domain}/
        │       └── spec.md  <- Delta spec
        ├── design.md        <- from sdd-design
        ├── tasks.md         <- from sdd-tasks (updated by sdd-apply)
        └── verify-report.md <- from sdd-verify
```

For simple, single-domain changes it is fine to write the delta spec directly as
`openspec/changes/{change-name}/spec.md` instead of a `specs/{domain}/spec.md` subtree. Use the
`specs/{domain}/` layout only when a change spans multiple domains.

## Artifact File Paths

| Skill | Creates / Reads | Path |
|-------|----------------|------|
| sdd-init | Creates | `openspec/config.yaml`, `openspec/specs/`, `openspec/changes/`, `openspec/changes/archive/` |
| sdd-explore | Creates (optional) | `openspec/changes/{change-name}/exploration.md` |
| sdd-propose | Creates | `openspec/changes/{change-name}/proposal.md` |
| sdd-spec | Creates | `openspec/changes/{change-name}/spec.md` (or `specs/{domain}/spec.md`) |
| sdd-design | Creates | `openspec/changes/{change-name}/design.md` |
| sdd-tasks | Creates | `openspec/changes/{change-name}/tasks.md` |
| sdd-apply | Updates | `openspec/changes/{change-name}/tasks.md` (marks `[x]`) |
| sdd-verify | Creates | `openspec/changes/{change-name}/verify-report.md` |
| sdd-archive | Moves | `openspec/changes/{change-name}/` → `openspec/changes/archive/YYYY-MM-DD-{change-name}/` |
| sdd-archive | Updates | `openspec/specs/{domain}/spec.md` (merges deltas into main specs) |

## Writing Rules

- Always create the change directory before writing artifacts.
- If a file already exists, READ it first and UPDATE it (don't overwrite blindly).
- If the change directory already exists with artifacts, the change is being CONTINUED.
- Use the `openspec/config.yaml` `rules` section for project-specific constraints per phase.

## Delta Spec Sections

Delta specs MAY include these sections:

```markdown
## ADDED Requirements
## MODIFIED Requirements
## REMOVED Requirements
## RENAMED Requirements
```

- `ADDED` appends new requirements to the main spec.
- `MODIFIED` replaces the full matching requirement block in the main spec. The delta MUST contain the entire updated requirement, including unchanged scenarios that must be preserved.
- `REMOVED` deletes the matching requirement from the main spec. Each removed requirement MUST include `(Reason: ...)` and SHOULD include `(Migration: ...)` when consumers or persisted behavior are affected.
- `RENAMED` changes a requirement heading/name without changing behavior unless the delta also includes a `MODIFIED` block for the new requirement. Each rename MUST state old and new names explicitly.

## Config File Reference

See `.sdd-workflow/templates/openspec-config.yaml` for the canonical template. The key fields:

```yaml
# openspec/config.yaml
schema: spec-driven

context: |
  Tech stack: {detected}
  Architecture: {detected}
  Testing: {detected}
  Style: {detected}

strict_tdd: false            # Set to true to enable RED-GREEN-REFACTOR in sdd-apply/sdd-verify

rules:
  proposal:
    - Include rollback plan for risky changes
  specs:
    - Use Given/When/Then for scenarios
    - Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY)
  design:
    - Document architecture decisions with rationale
  tasks:
    - Keep tasks completable in one session
  apply:
    - Follow existing code patterns
  verify:
    test_command: ""
    build_command: ""
    coverage_threshold: 0
  archive:
    - Warn before merging destructive deltas

testing:
  detected: "YYYY-MM-DD"
  runner:
    command: ""
    framework: ""
```

## Archive Structure

When archiving, the change folder moves to:

```
openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Use today's date in ISO format. The archive is an AUDIT TRAIL — never delete or modify archived changes.
