#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

ICON_DIR="NudgeList/Resources/Assets.xcassets/AppIcon.appiconset"
SOURCE_SVG="docs/app-logo.svg"
BASE="$ICON_DIR/AppIcon-1024.png"

mkdir -p "$ICON_DIR"

if [[ ! -f "$SOURCE_SVG" ]]; then
  echo "Error: missing $SOURCE_SVG" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Prefer sips if this macOS build can read SVG. Otherwise use Quick Look,
# which is available on macOS and can render the SVG to a PNG thumbnail.
if sips -s format png "$SOURCE_SVG" --out "$BASE" >/dev/null 2>&1; then
  :
else
  qlmanage -t -s 1024 -o "$TMP_DIR" "$SOURCE_SVG" >/dev/null 2>&1
  QL_PNG="$TMP_DIR/$(basename "$SOURCE_SVG").png"
  if [[ ! -f "$QL_PNG" ]]; then
    echo "Error: unable to render $SOURCE_SVG to PNG" >&2
    exit 1
  fi
  cp "$QL_PNG" "$BASE"
fi

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

echo "Generated $BASE"
echo "App icon set generated."
