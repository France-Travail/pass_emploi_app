#!/bin/bash
set -euo pipefail

# Upload iOS dSYM files to Firebase Crashlytics.
# Usage: ios/scripts/upload_crashlytics_dsyms.sh <flavor>
# Example: ios/scripts/upload_crashlytics_dsyms.sh cejProd

FLAVOR="${1:?Flavor required (e.g. cejProd or brsaProd)}"
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GOOGLE_SERVICE_PLIST="${PROJECT_ROOT}/ios/firebase-config/${FLAVOR}/GoogleService-Info.plist"
# Firebase comes from Swift Package Manager (checked out by `flutter build` in build/ios/SourcePackages),
# CocoaPods path kept as a fallback.
UPLOAD_SYMBOLS=""
for candidate in \
  "${PROJECT_ROOT}/build/ios/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols" \
  "${PROJECT_ROOT}/ios/Pods/FirebaseCrashlytics/upload-symbols"; do
  if [ -x "$candidate" ]; then
    UPLOAD_SYMBOLS="$candidate"
    break
  fi
done

if [ ! -f "$GOOGLE_SERVICE_PLIST" ]; then
  echo "Missing GoogleService-Info.plist at ${GOOGLE_SERVICE_PLIST}"
  exit 1
fi

if [ -z "$UPLOAD_SYMBOLS" ]; then
  echo "Missing upload-symbols in build/ios/SourcePackages (Swift Package Manager) or ios/Pods. Run flutter build first."
  exit 1
fi

ARCHIVE_PATH="$(find "${PROJECT_ROOT}/build/ios/archive" -name "*.xcarchive" -type d 2>/dev/null | sort | tail -1)"
if [ -z "$ARCHIVE_PATH" ]; then
  echo "No xcarchive found in build/ios/archive"
  exit 1
fi

DSYM_DIR="${ARCHIVE_PATH}/dSYMs"
if [ ! -d "$DSYM_DIR" ]; then
  echo "No dSYMs directory in ${ARCHIVE_PATH}"
  exit 1
fi

echo "Uploading dSYMs from ${DSYM_DIR} to Crashlytics (${FLAVOR})"
find "$DSYM_DIR" -name "*.dSYM" -print0 | while IFS= read -r -d '' dsym; do
  echo "Uploading ${dsym}"
  "$UPLOAD_SYMBOLS" -gsp "$GOOGLE_SERVICE_PLIST" -p ios "$dsym"
done

echo "Crashlytics dSYM upload completed for ${FLAVOR}"
