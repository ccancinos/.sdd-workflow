#!/usr/bin/env bash
#
# unlink.sh — detach the .sdd-workflow toolkit from this workspace.
#
# Removes exactly what link.sh created, as recorded in .sdd-workflow/.link-manifest:
#   - every symlink it made under .opencode/ and .claude/
#   - the managed persona block in AGENTS.md / CLAUDE.md (if --persona was used)
# Then prunes now-empty directories.
#
# Safety rules (never destroy your data):
#   - AGENTS.md / CLAUDE.md are deleted ONLY if they are completely empty AFTER the persona block
#     is removed. Any content you added — before or after link.sh ran — keeps the file.
#   - Directories are removed with rmdir, which only succeeds when they are empty, so a .opencode/
#     or .claude/ that holds your own files (e.g. opencode.json) is left intact.
#
# Your own files (source, openspec/ artifacts, hand-written opencode.json, etc.) are never touched.
#
# Usage: .sdd-workflow/bin/unlink.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$SDD_DIR/.." && pwd)"
MANIFEST="$SDD_DIR/.link-manifest"

PERSONA_BEGIN="<!-- sdd-workflow:persona -->"
PERSONA_END="<!-- /sdd-workflow:persona -->"

if [[ ! -f "$MANIFEST" ]]; then
  echo "No manifest found ($MANIFEST). Nothing to unlink."
  exit 0
fi

remove_persona_block() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  # Delete the managed block (inclusive). If the line immediately before the block is blank
  # (the separator link.sh adds), drop that blank line too — but only that one.
  awk -v b="$PERSONA_BEGIN" -v e="$PERSONA_END" '
    { lines[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        if (lines[i] == b) {
          # If we already emitted a trailing blank line just before the block, drop it.
          if (outn > 0 && out[outn] == "") outn--
          # Skip until (and including) the end marker.
          while (i <= NR && lines[i] != e) i++
          continue   # i now at end marker; for-loop i++ moves past it
        }
        out[++outn] = lines[i]
      }
      for (i = 1; i <= outn; i++) print out[i]
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
  echo "  removed persona block from $file"
}

echo "Detaching .sdd-workflow from root: $ROOT"

# Collect candidate parent dirs to prune afterward.
declare -a PRUNE_DIRS=()

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  if [[ "$line" == persona:* ]]; then
    # format: persona:<created|existed>:<file>  (the created/existed field is ignored on purpose)
    rest="${line#persona:}"
    pfile="${rest#*:}"
    remove_persona_block "$pfile"
    # Remove the file ONLY if it is now completely empty (zero bytes or whitespace-only).
    # This never deletes content you added after link.sh ran, regardless of who created the file.
    if [[ -f "$pfile" ]] && [[ ! -s "$pfile" || -z "$(tr -d '[:space:]' < "$pfile")" ]]; then
      rm -f "$pfile"
      echo "  removed now-empty $pfile"
    else
      echo "  kept $pfile (still has content)"
    fi
    continue
  fi
  # Otherwise it's a symlink path we created.
  if [[ -L "$line" ]]; then
    rm -f "$line"
    echo "  removed $line"
    PRUNE_DIRS+=("$(dirname "$line")")
  elif [[ -e "$line" ]]; then
    echo "  skip (not a symlink, left untouched): $line"
  fi
done < "$MANIFEST"

# Prune now-empty directories we linked into (and their empty parents up to root).
# Always consider the two agent config roots as prune candidates too.
PRUNE_DIRS+=("$ROOT/.opencode" "$ROOT/.claude")
for d in $(printf '%s\n' "${PRUNE_DIRS[@]:-}" | sort -u); do
  [[ -z "$d" ]] && continue
  while [[ "$d" == "$ROOT"/* && -d "$d" ]]; do
    if rmdir "$d" 2>/dev/null; then
      echo "  pruned empty dir $d"
      d="$(dirname "$d")"
    else
      break
    fi
  done
done

: > "$MANIFEST"
echo ""
echo "Done. Toolkit detached. You may now delete $SDD_DIR to remove all trace."
