#!/bin/bash
# Build and run all HepReference tests on the first available iPhone simulator.
# Works the same on the author's Mac and on the GitHub Actions macOS runner.
#   tools/test.sh            # xcodegen + tests, prints a short summary
set -uo pipefail
cd "$(dirname "$0")/../ios/HepReference"

xcodegen generate --quiet

SIM="${HEP_SIM:-$(xcrun simctl list devices available | grep -oE 'iPhone [0-9]+( Pro)?( Max)? \(' | head -1 | sed 's/ ($//')}"
echo "Simulator: $SIM"

xcodebuild -project HepReference.xcodeproj -scheme HepReference \
  -destination "platform=iOS Simulator,name=$SIM" test 2>&1 \
  | tee /tmp/hep-test.log \
  | grep -E "error:|failed|Executed .* tests|TEST (SUCCEEDED|FAILED)"
exit "${PIPESTATUS[0]}"
