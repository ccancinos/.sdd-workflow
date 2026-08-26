#!/usr/bin/env bash
#
# new-artifact.sh — scaffold a new skill, agent, or command inside .sdd-workflow/.
#
# Creates starter files with native frontmatter for each tool:
#   skill   — one SKILL.md in common/skills/extensions/<name>/  (shared by both tools)
#   agent   — two files: claude/agents/<name>.md (Claude-native tools: list)
#                    and opencode/agents/<name>.md (OpenCode-native permission: block)
#             Both files have identical bodies; only the frontmatter differs.
#   command — one file in common/commands/<name>.md (shared by both tools)
#
# Usage:
#   .sdd-workflow/bin/new-artifact.sh skill   <name>   "<description>"
#   .sdd-workflow/bin/new-artifact.sh agent   <name>   "<description>"
#   .sdd-workflow/bin/new-artifact.sh command <name>   "<description>"
#
# <name> must be lowercase-hyphenated (a-z, 0-9, single hyphens).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() { sed -n '2,17p' "$0"; exit "${1:-0}"; }

[[ $# -lt 2 ]] && usage 1
KIND="$1"; NAME="$2"; DESC="${3:-TODO: describe when to use this.}"

if [[ ! "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: name must be lowercase-hyphenated (matched ^[a-z0-9]+(-[a-z0-9]+)*\$): $NAME" >&2
  exit 1
fi

AGENT_BODY="You are the $NAME executor. Do this work yourself. Do NOT delegate further.

## Instructions

TODO: what this agent does."

case "$KIND" in
  skill)
    dir="$SDD_DIR/common/skills/extensions/$NAME"; file="$dir/SKILL.md"
    [[ -e "$file" ]] && { echo "error: $file already exists" >&2; exit 1; }
    mkdir -p "$dir"
    cat > "$file" <<EOF
---
name: $NAME
description: "$DESC"
license: MIT
metadata:
  version: "1.0"
---

## When to Use

Use this skill when: TODO.

## Instructions

TODO: the reusable procedure/patterns for this skill.
EOF
    echo "Created $file"
    ;;
  agent)
    claude_file="$SDD_DIR/claude/agents/$NAME.md"
    opencode_file="$SDD_DIR/opencode/agents/$NAME.md"
    [[ -e "$claude_file" ]]   && { echo "error: $claude_file already exists" >&2; exit 1; }
    [[ -e "$opencode_file" ]] && { echo "error: $opencode_file already exists" >&2; exit 1; }
    cat > "$claude_file" <<EOF
---
name: $NAME
description: >
  $DESC
mode: subagent
tools: Read, Grep, Glob, Write
---

$AGENT_BODY
EOF
    cat > "$opencode_file" <<EOF
---
name: $NAME
description: >
  $DESC
mode: subagent
permission:
  read: allow
  grep: allow
  glob: allow
  write: allow
  edit: deny
---

$AGENT_BODY
EOF
    echo "Created $claude_file"
    echo "Created $opencode_file"
    ;;
  command)
    file="$SDD_DIR/common/commands/$NAME.md"
    [[ -e "$file" ]] && { echo "error: $file already exists" >&2; exit 1; }
    cat > "$file" <<EOF
---
description: $DESC
agent: sdd-orchestrator
---

TODO: the prompt template for /$NAME. Use \$ARGUMENTS for user input.
EOF
    echo "Created $file"
    ;;
  *)
    echo "error: unknown kind: $KIND (expected skill|agent|command)" >&2
    usage 1
    ;;
esac

echo ""
echo "Next steps:"
echo "  1. Edit the file(s) above."
if [[ "$KIND" == "agent" ]]; then
  echo "     - claude/agents/$NAME.md  — Claude-native frontmatter (tools: list)"
  echo "     - opencode/agents/$NAME.md — OpenCode-native frontmatter (permission: block)"
  echo "     Bodies are identical; edit both if instructions differ per tool."
fi
echo "  2. Re-run  .sdd-workflow/bin/link.sh   to symlink into .claude/ and .opencode/."
[[ "$KIND" == "skill" ]] && echo "  3. Re-run  .sdd-workflow/bin/skill-registry.sh   to index it."
