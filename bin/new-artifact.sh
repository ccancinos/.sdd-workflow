#!/usr/bin/env bash
#
# new-artifact.sh — scaffold a new skill, agent, or command inside .sdd-workflow/.
#
# Creates a spec-correct starter file with the right frontmatter so it works in both OpenCode and
# Claude Code, then reminds you to re-link and refresh the registry.
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

case "$KIND" in
  skill)
    dir="$SDD_DIR/skills/$NAME"; file="$dir/SKILL.md"
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
    ;;
  agent)
    file="$SDD_DIR/agents/$NAME.md"
    [[ -e "$file" ]] && { echo "error: $file already exists" >&2; exit 1; }
    cat > "$file" <<EOF
---
name: $NAME
description: >
  $DESC
mode: subagent
tools:
  read: true
  grep: true
  glob: true
  write: true
  edit: false
permission:
  edit: deny
---

You are the $NAME executor. Do this work yourself. Do NOT delegate further.

## Instructions

TODO: what this agent does.
EOF
    ;;
  command)
    file="$SDD_DIR/commands/$NAME.md"
    [[ -e "$file" ]] && { echo "error: $file already exists" >&2; exit 1; }
    cat > "$file" <<EOF
---
description: $DESC
agent: sdd-orchestrator
---

TODO: the prompt template for /$NAME. Use \$ARGUMENTS for user input.
EOF
    ;;
  *)
    echo "error: unknown kind: $KIND (expected skill|agent|command)" >&2
    usage 1
    ;;
esac

echo "Created $file"
echo ""
echo "Next steps:"
echo "  1. Edit the file above."
echo "  2. Re-run  .sdd-workflow/bin/link.sh   to symlink it into your agents."
[[ "$KIND" == "skill" ]] && echo "  3. Re-run  .sdd-workflow/bin/skill-registry.sh   to index it."
