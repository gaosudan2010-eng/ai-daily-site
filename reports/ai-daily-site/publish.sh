#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/publish-$(date +%Y%m%d-%H%M%S).log"

MODE="${1:-run}" # run | dry-run
BRANCH="${BRANCH:-main}"
MSG="${MSG:-chore(ai-daily): update content and ui}"

run_cmd() {
  echo "+ $*" | tee -a "$LOG_FILE"
  if [[ "$MODE" == "dry-run" ]]; then
    return 0
  fi
  "$@" 2>&1 | tee -a "$LOG_FILE"
}

{
  echo "[publish] mode=$MODE"
  echo "[publish] root=$ROOT"
  echo "[publish] branch=$BRANCH"
  echo "[publish] msg=$MSG"
  echo "[publish] time=$(date '+%F %T %Z')"
} | tee -a "$LOG_FILE"

cd "$ROOT"
run_cmd git rev-parse --is-inside-work-tree
run_cmd git add data.js index.html detail.html styles.css
run_cmd git status --short
run_cmd git commit -m "$MSG"
run_cmd git push origin "$BRANCH"

echo "[publish] done log=$LOG_FILE" | tee -a "$LOG_FILE"
