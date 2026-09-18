#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Simulator auth still needs an application-identifier entitlement.
# CODE_SIGNING_ALLOWED=NO builds may launch but fail Keychain access (-34018).
xcodebuild -workspace Kirokun.xcworkspace -scheme Kirokun-Dev \
  -configuration DevDebug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "${KIROKUN_DERIVED_DATA:-/tmp/kirokun-dev-derived}" \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- build
