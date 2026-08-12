#!/usr/bin/env bash
# Extract the hero frame sequence and write the manifest the site reads.
#
# The site draws JPEG frames on a <canvas>. It never uses <video> + currentTime:
# browsers can only seek to keyframes in a compressed MP4, so scrubbing stutters.
#
#   usage: scripts/extract-frames.sh assets/hero-loop.mp4 [fps]
set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VIDEO="${1:-$SITE_DIR/assets/hero-loop.mp4}"
FPS="${2:-24}"
OUT="$SITE_DIR/assets/frames"

if [[ ! -f "$VIDEO" ]]; then
  echo "error: no video at $VIDEO" >&2
  echo "generate one first — see HERO-PROMPTS.md" >&2
  exit 1
fi

command -v ffmpeg >/dev/null || { echo "error: ffmpeg not on PATH" >&2; exit 1; }

rm -f "$OUT"/frame-*.jpg "$OUT/manifest.json"
mkdir -p "$OUT"

echo "extracting ${FPS}fps from $(basename "$VIDEO") ..."
ffmpeg -loglevel error -i "$VIDEO" \
  -vf "fps=${FPS},scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720" \
  -q:v 4 "$OUT/frame-%04d.jpg"

COUNT=$(find "$OUT" -name 'frame-*.jpg' | wc -l | tr -d ' ')
if [[ "$COUNT" -lt 2 ]]; then
  echo "error: extracted $COUNT frames" >&2
  exit 1
fi

# site.js reads this to size the scrub timeline — no hand-edited frame count
printf '{"count": %s, "fps": %s}\n' "$COUNT" "$FPS" > "$OUT/manifest.json"

echo "wrote $COUNT frames + manifest.json"
du -sh "$OUT" | awk '{print "frames dir: " $1}'
