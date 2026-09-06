#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

ICON_DIR="NudgeList/Resources/Assets.xcassets/AppIcon.appiconset"
BASE="$ICON_DIR/AppIcon-1024.png"

mkdir -p "$ICON_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
GENERATOR="$TMP_DIR/generate_app_icon"

# Compile the Swift generator first. Running it through `swift` directly can
# expose Swift frontend arguments (for example `-frontend`) to CommandLine.
xcrun swiftc scripts/generate_app_icon.swift -o "$GENERATOR"
"$GENERATOR" "$BASE"

if [[ ! -f "$BASE" ]]; then
  echo "Error: base app icon was not generated at $BASE" >&2
  exit 1
fi

resize() {
  local size="$1"
  local name="$2"
  sips -z "$size" "$size" "$BASE" --out "$ICON_DIR/$name" >/dev/null
}

resize 40 AppIcon-20@2x.png
resize 60 AppIcon-20@3x.png
resize 58 AppIcon-29@2x.png
resize 87 AppIcon-29@3x.png
resize 80 AppIcon-40@2x.png
resize 120 AppIcon-40@3x.png
resize 120 AppIcon-60@2x.png
resize 180 AppIcon-60@3x.png

resize 16 AppIcon-mac-16.png
resize 32 AppIcon-mac-16@2x.png
resize 32 AppIcon-mac-32.png
resize 64 AppIcon-mac-32@2x.png
resize 128 AppIcon-mac-128.png
resize 256 AppIcon-mac-128@2x.png
resize 256 AppIcon-mac-256.png
resize 512 AppIcon-mac-256@2x.png
resize 512 AppIcon-mac-512.png
resize 1024 AppIcon-mac-512@2x.png

echo "App icon set generated."
