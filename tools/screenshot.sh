#!/bin/bash
# Launch the last built HepReference on the first available iPhone simulator
# and save a screenshot. Run tools/test.sh (or any build) first.
#   tools/screenshot.sh reports/shots/2026-10-19-home.png [seconds-to-wait]
set -euo pipefail
OUT="${1:?usage: tools/screenshot.sh <output.png> [wait-seconds]}"
WAIT="${2:-6}"

SIM="${HEP_SIM:-$(xcrun simctl list devices available | grep -oE 'iPhone [0-9]+( Pro)?( Max)? \(' | head -1 | sed 's/ ($//')}"
APP="$(find "$HOME/Library/Developer/Xcode/DerivedData" -maxdepth 6 -path "*HepReference*/Build/Products/Debug-iphonesimulator/HepReference.app" 2>/dev/null | head -1)"
[ -n "$APP" ] || { echo "HepReference.app not found — build first (tools/test.sh)"; exit 1; }

xcrun simctl boot "$SIM" 2>/dev/null || true
xcrun simctl bootstatus "$SIM" -b >/dev/null
xcrun simctl install "$SIM" "$APP"
xcrun simctl terminate "$SIM" com.hepreference.app 2>/dev/null || true
xcrun simctl launch "$SIM" com.hepreference.app >/dev/null
sleep "$WAIT"
mkdir -p "$(dirname "$OUT")"
xcrun simctl io "$SIM" screenshot "$OUT" >/dev/null
echo "Screenshot ($SIM): $OUT"
