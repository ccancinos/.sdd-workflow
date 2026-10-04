#!/usr/bin/env bash
set -euo pipefail

AGENTS_DIR="$(cd "$(dirname "$0")/../opencode/agents" && pwd)"

# ── Model tiers ──────────────────────────────────────────────────────
# Anthropic Models (Best)
MODEL_HEAVY=anthropic/claude-opus-5
MODEL_BALANCED=anthropic/claude-sonnet-5
MODEL_FAST=anthropic/claude-haiku-4-5

# Mixed Models (Balanced)
# MODEL_HEAVY=anthropic/claude-opus-5
# MODEL_BALANCED=opencode/gpt-5.6-terra
# MODEL_FAST=opencode/gpt-5.6-luna

# OpenAI Models (Minimum)
# MODEL_HEAVY=opencode/gpt-5.6-sol
# MODEL_BALANCED=opencode/gpt-5.6-terra
# MODEL_FAST=opencode/gpt-5.6-luna

# ── Per-agent assignments ──────────
resolve_model() {
  case "$1" in
    sdd-apply)        echo "$MODEL_BALANCED" ;;
    sdd-archive)      echo "$MODEL_FAST" ;;
    sdd-design)       echo "$MODEL_HEAVY" ;;
    sdd-explore)      echo "$MODEL_HEAVY" ;;
    sdd-init)         echo "$MODEL_FAST" ;;
    sdd-onboard)      echo "$MODEL_FAST" ;;
    sdd-orchestrator) echo "$MODEL_HEAVY" ;;
    sdd-propose)      echo "$MODEL_HEAVY" ;;
    sdd-spec)         echo "$MODEL_BALANCED" ;;
    sdd-tasks)        echo "$MODEL_BALANCED" ;;
    sdd-verify)       echo "$MODEL_BALANCED" ;;
    *)                echo "" ;;
  esac
}

updated=0
inserted=0
skipped=0

for file in "$AGENTS_DIR"/*.md; do
  agent="$(basename "$file" .md)"
  model="$(resolve_model "$agent")"

  if [[ -z "$model" ]]; then
    echo "  SKIP  $agent — no model assigned"
    skipped=$((skipped + 1))
    continue
  fi

  if grep -q '^model:' "$file"; then
    sed -i '' "s|^model:.*|model: $model|" "$file"
    echo "  UPD   $agent → $model"
    updated=$((updated + 1))
  else
    sed -i '' "/^mode:/a\\
model: $model
" "$file"
    echo "  ADD   $agent → $model"
    inserted=$((inserted + 1))
  fi
done

echo ""
echo "Done: $updated updated, $inserted inserted, $skipped skipped"
