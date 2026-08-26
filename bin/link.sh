#!/usr/bin/env bash
#
# link.sh — attach the .sdd-workflow toolkit to OpenCode and/or Claude Code in this workspace.
#
# Creates symlinks from the agents' config directories into .sdd-workflow/. It is idempotent:
# re-run it any time after adding/removing artifacts to reconcile the links. It records every
# path it creates in .sdd-workflow/.link-manifest so unlink.sh can cleanly remove them.
#
# Usage:
#   .sdd-workflow/bin/link.sh [--opencode] [--claude] [--persona]
#
#   --opencode   Wire OpenCode   (.opencode/agents, .opencode/commands, .opencode/skills)
#   --claude     Wire Claude Code (.claude/agents, .claude/commands, .claude/skills)
#   --persona    Also reference .sdd-workflow/common/persona/persona.md from AGENTS.md / CLAUDE.md
#
# If neither --opencode nor --claude is given, both are wired.
#
# Source layout inside .sdd-workflow/:
#   claude/agents/                  — Claude-specific agent files
#   opencode/agents/                — OpenCode-specific agent files
#   common/commands/                — slash commands (identical for both tools)
#   common/skills/extensions/       — standalone skills symlinked into tool skill dirs
#   common/skills/phases/           — SDD phase skills (internal; never symlinked to tools)
#   common/persona/                 — persona files (referenced via AGENTS.md / CLAUDE.md)

set -euo pipefail

# --- resolve paths -----------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"          # .../.sdd-workflow
ROOT="$(cd "$SDD_DIR/.." && pwd)"                # workspace/umbrella root
MANIFEST="$SDD_DIR/.link-manifest"

# .sdd-workflow must live directly under the root as a dir named exactly .sdd-workflow
if [[ "$(basename "$SDD_DIR")" != ".sdd-workflow" ]]; then
  echo "error: expected toolkit dir to be named .sdd-workflow, got $(basename "$SDD_DIR")" >&2
  exit 1
fi

# --- parse flags -------------------------------------------------------------
WANT_OPENCODE=0
WANT_CLAUDE=0
WANT_PERSONA=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --opencode) WANT_OPENCODE=1 ;;
    --claude)   WANT_CLAUDE=1 ;;
    --persona)  WANT_PERSONA=1 ;;
    -h|--help)  sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "error: unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done
if [[ $WANT_OPENCODE -eq 0 && $WANT_CLAUDE -eq 0 ]]; then
  WANT_OPENCODE=1; WANT_CLAUDE=1
fi

# --- manifest helpers --------------------------------------------------------
# Start a fresh manifest each run; link.sh is the single source of truth for what it created.
: > "$MANIFEST"
record() { printf '%s\n' "$1" >> "$MANIFEST"; }

# link SRC -> DESTLINK (DESTLINK is the symlink path to create). Records DESTLINK in the manifest.
make_link() {
  local src="$1" destlink="$2"
  mkdir -p "$(dirname "$destlink")"
  # Remove an existing symlink or file at the destination so re-runs reconcile cleanly.
  if [[ -L "$destlink" || -e "$destlink" ]]; then
    rm -rf "$destlink"
  fi
  ln -s "$src" "$destlink"
  record "$destlink"
  echo "  linked $destlink -> $src"
}

# Symlink every entry of SRCDIR/* into DESTDIR/ (one link per entry).
link_dir_entries() {
  local srcdir="$1" destdir="$2"
  [[ -d "$srcdir" ]] || return 0
  local entry name
  for entry in "$srcdir"/*; do
    [[ -e "$entry" ]] || continue
    name="$(basename "$entry")"
    make_link "$entry" "$destdir/$name"
  done
}

# --- persona reference (opt-in) ---------------------------------------------
PERSONA_REF="@.sdd-workflow/common/persona/persona.md"
PERSONA_BEGIN="<!-- sdd-workflow:persona -->"
PERSONA_END="<!-- /sdd-workflow:persona -->"

add_persona_ref() {
  local file="$1"
  # Track whether the file pre-existed, so unlink knows whether it may delete it.
  local created="created" ; [[ -f "$file" ]] && created="existed"
  # Skip if the managed block already exists.
  if [[ -f "$file" ]] && grep -qF "$PERSONA_BEGIN" "$file"; then
    echo "  persona ref already present in $file"
    record "persona:$created:$file"
    return 0
  fi
  {
    [[ -f "$file" ]] && echo ""
    echo "$PERSONA_BEGIN"
    echo "$PERSONA_REF"
    echo "$PERSONA_END"
  } >> "$file"
  record "persona:$created:$file"
  echo "  added persona ref to $file"
}

# --- do the work -------------------------------------------------------------
echo "Attaching .sdd-workflow at root: $ROOT"

if [[ $WANT_OPENCODE -eq 1 ]]; then
  echo "OpenCode agents/commands/skills ->"
  link_dir_entries "$SDD_DIR/opencode/agents"          "$ROOT/.opencode/agents"
  link_dir_entries "$SDD_DIR/common/commands"          "$ROOT/.opencode/commands"
  link_dir_entries "$SDD_DIR/common/skills/extensions" "$ROOT/.opencode/skills"
fi

if [[ $WANT_CLAUDE -eq 1 ]]; then
  echo "Claude Code agents/commands/skills ->"
  link_dir_entries "$SDD_DIR/claude/agents"            "$ROOT/.claude/agents"
  link_dir_entries "$SDD_DIR/common/commands"          "$ROOT/.claude/commands"
  link_dir_entries "$SDD_DIR/common/skills/extensions" "$ROOT/.claude/skills"
fi

if [[ $WANT_PERSONA -eq 1 ]]; then
  echo "Persona reference ->"
  [[ $WANT_OPENCODE -eq 1 ]] && add_persona_ref "$ROOT/AGENTS.md"
  [[ $WANT_CLAUDE   -eq 1 ]] && add_persona_ref "$ROOT/CLAUDE.md"
fi

echo ""
echo "Done. Manifest: $MANIFEST"
echo "Tip: run .sdd-workflow/bin/skill-registry.sh to (re)build the skill registry."
