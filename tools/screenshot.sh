#!/bin/bash
# Launch the last built HepReference on the first available iPhone simulator
# and save a screenshot. Run tools/test.sh (or any build) first.
#   tools/screenshot.sh reports/shots/2026-10-19-home.png [seconds-to-wait]
# Optional environment:
#   HEP_APPEARANCE=dark|light   simulator appearance for the shot (reset to light afterwards)
#   HEP_OPEN_CARD=<card_id>     open this card on launch (Debug builds only)
#   HEP_SCROLL_BLOCK=<n>       with HEP_OPEN_CARD: open the card scrolled to block n, 0-based (Debug builds only)
#   HEP_OPEN_CATEGORY=<cat>     open this home category on launch (Debug builds only)
#   HEP_OPEN_CALC=<calc_id>     open this calculator on launch (Debug builds only)
#   HEP_OPEN_TAB=home|study|search   open this tab on launch (Debug builds only)
#   HEP_STUDY_BLOCK=<n>         show this year-plan block in the Study tab (Debug builds only)
#   HEP_SEARCH_QUERY=<text>     prefill the Search field (Debug builds only; pair with HEP_OPEN_TAB=search)
#   HEP_FAVORITES=<id,id,…>     Home's Favorites for this launch (default: none; any build)
#   HEP_RECENTS=<id,id,…>       Home's Recent for this launch (default: none) — both keep shots
#                               independent of cards opened in earlier runs
set -euo pipefail
OUT="${1:?usage: tools/screenshot.sh <output.png> [wait-seconds]}"
WAIT="${2:-6}"

SIM="${HEP_SIM:-$(xcrun simctl list devices available | grep -oE 'iPhone [0-9]+( Pro)?( Max)? \(' | head -1 | sed 's/ ($//')}"
APP="$(find "$HOME/Library/Developer/Xcode/DerivedData" -maxdepth 6 -path "*HepReference*/Build/Products/Debug-iphonesimulator/HepReference.app" 2>/dev/null | head -1)"
[ -n "$APP" ] || { echo "HepReference.app not found — build first (tools/test.sh)"; exit 1; }

xcrun simctl boot "$SIM" 2>/dev/null || true
xcrun simctl bootstatus "$SIM" -b >/dev/null
xcrun simctl install "$SIM" "$APP"
[ -n "${HEP_APPEARANCE:-}" ] && xcrun simctl ui "$SIM" appearance "$HEP_APPEARANCE"
xcrun simctl terminate "$SIM" com.hepreference.app 2>/dev/null || true
ARGS=()
[ -n "${HEP_OPEN_CATEGORY:-}" ] && ARGS+=(-hepOpenCategory "$HEP_OPEN_CATEGORY")
[ -n "${HEP_OPEN_CARD:-}" ] && ARGS+=(-hepOpenCard "$HEP_OPEN_CARD")
[ -n "${HEP_SCROLL_BLOCK:-}" ] && [ -n "${HEP_OPEN_CARD:-}" ] && ARGS+=(-hepScrollToBlock "$HEP_SCROLL_BLOCK")
[ -n "${HEP_OPEN_CALC:-}" ] && ARGS+=(-hepOpenCalc "$HEP_OPEN_CALC")
[ -n "${HEP_OPEN_TAB:-}" ] && ARGS+=(-hepOpenTab "$HEP_OPEN_TAB")
[ -n "${HEP_STUDY_BLOCK:-}" ] && ARGS+=(-hepStudyBlock "$HEP_STUDY_BLOCK")
[ -n "${HEP_SEARCH_QUERY:-}" ] && ARGS+=(-hepSearchQuery "$HEP_SEARCH_QUERY")
# UserDefaults' argument domain: `-hep.favorites '("a","b")'` overrides the
# stored list for this launch only.
plist_array() {
  local IFS=, out=() id
  for id in ${1// /}; do [ -n "$id" ] && out+=("\"$id\""); done
  echo "(${out[*]-})"
}
ARGS+=(-hep.favorites "$(plist_array "${HEP_FAVORITES:-}")" -hep.recents "$(plist_array "${HEP_RECENTS:-}")")
xcrun simctl launch "$SIM" com.hepreference.app ${ARGS[@]+"${ARGS[@]}"} >/dev/null
sleep "$WAIT"
mkdir -p "$(dirname "$OUT")"
xcrun simctl io "$SIM" screenshot "$OUT" >/dev/null
[ -n "${HEP_APPEARANCE:-}" ] && xcrun simctl ui "$SIM" appearance light
echo "Screenshot ($SIM): $OUT"
