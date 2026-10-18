#!/bin/bash
# Daily autonomous run of HepReference. Started by launchd (see
# automation/com.hepreference.daily.plist) or by hand:
#   automation/run_daily.sh            # normal run (skips if today's report exists)
#   automation/run_daily.sh --force    # run even if today's report exists
#   automation/run_daily.sh --dry-run  # reconnaissance + plan only, no changes
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/usr/local/bin:/opt/homebrew/bin:/Library/Frameworks/Python.framework/Versions/3.12/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$ROOT"
mkdir -p logs reports

notify() {
  local msg="${1//\"/}"
  osascript -e "display notification \"${msg//\\/}\" with title \"HepReference\"" >/dev/null 2>&1 || true
}

MODE="${1:-}"
TODAY="$(date +%Y-%m-%d)"
if [ "$MODE" = "" ] && [ -f "reports/$TODAY.md" ]; then
  echo "Report for $TODAY already exists — skipping (use --force)."
  exit 0
fi

LOCK="$ROOT/logs/.run.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "Another run is in progress — exiting."
  exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

CLAUDE="$(command -v claude || true)"
if [ -z "$CLAUDE" ]; then
  CLAUDE="$(ls -d "$HOME"/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude 2>/dev/null | sort -V | tail -1)"
fi
if [ ! -x "$CLAUDE" ]; then
  notify "Daily run failed: Claude Code CLI not found"
  exit 1
fi

PROMPT="$(cat automation/DAILY_RUN.md)"
if [ "$MODE" = "--dry-run" ]; then
  PROMPT+=$'\n\n---\n**DRY RUN.** Выполни только фазы 1 и 2. Ничего не меняй: никаких правок файлов, коммитов, push и --done у синхронизации (сам скрипт синхронизации запускать можно). Тесты можно запустить. В конце выведи план дня в формате фазы 2.'
fi

LOG="logs/$(date +%Y-%m-%d_%H%M)${MODE:+_${MODE#--}}.log"
echo "Run started $(date) with $CLAUDE" >"$LOG"

# Permissions come from .claude/settings.json (project allowlist approved by the author).
# Hard stop after 3 hours so a stuck run never blocks the next day.
caffeinate -i "$CLAUDE" -p "$PROMPT" --permission-mode auto >>"$LOG" 2>&1 &
PID=$!
( sleep 10800 && kill "$PID" 2>/dev/null && echo "Killed after 3 h" >>"$LOG" ) &
WATCHDOG=$!
wait "$PID"
STATUS=$?
kill "$WATCHDOG" 2>/dev/null

echo "Run finished $(date) with exit $STATUS" >>"$LOG"
if [ "$MODE" = "--dry-run" ]; then
  notify "Dry run finished — plan in $LOG"
elif [ "$STATUS" -ne 0 ]; then
  notify "Daily run failed (exit $STATUS) — see $LOG"
else
  notify "$(head -1 reports/latest.txt 2>/dev/null || echo "Daily run finished")"
fi
exit "$STATUS"
