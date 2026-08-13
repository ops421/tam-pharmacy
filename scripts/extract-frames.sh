#!/usr/bin/env bash
# Extract the hero frame sequence and write the manifest the site reads.
#
# The site draws frames on a <canvas>. It never uses <video> + currentTime:
# browsers can only seek to keyframes in a compressed MP4, so scrubbing stutters.
#
#   usage: scripts/extract-frames.sh [video] [fps] [quality] [width]
#
# Defaults produce WebP, roughly 65% lighter than equivalent JPEG on this
# footage. Visitors download the whole sequence, so total weight matters far
# more than per-frame fidelity, especially since the hero canvas is dimmed to
# 58% opacity on top of everything.
#
# fps is the real lever: payload scales linearly with it. 12fps over a 300vh
# hero is about 29px of scroll per frame, which still reads as smooth because
# the scrub rate is set by the visitor, not by playback.
set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VIDEO="${1:-$SITE_DIR/assets/hero-loop.mp4}"
FPS="${2:-12}"
QUALITY="${3:-75}"
WIDTH="${4:-1280}"
OUT="$SITE_DIR/assets/frames"

if [[ ! -f "$VIDEO" ]]; then
  echo "error: no video at $VIDEO" >&2
  echo "generate one first, see HERO-PROMPTS.md" >&2
  exit 1
fi

command -v ffmpeg >/dev/null || { echo "error: ffmpeg not on PATH" >&2; exit 1; }

# Capture first, then test. Piping ffmpeg straight into `grep -q` makes grep
# exit on the first match, which SIGPIPEs ffmpeg, and `set -o pipefail` turns
# that into a false negative that silently falls back to JPEG.
ENCODERS="$(ffmpeg -hide_banner -encoders 2>/dev/null || true)"
if printf '%s' "$ENCODERS" | grep -q libwebp; then
  EXT="webp"; CODEC=(-c:v libwebp -quality "$QUALITY" -compression_level 6)
else
  EXT="jpg"; CODEC=(-q:v 6)   # -q:v is 2 (best) to 31 (worst), not the 0-100 scale
  echo "note: libwebp unavailable, falling back to JPEG (roughly 3x heavier)" >&2
fi

rm -f "$OUT"/frame-*.jpg "$OUT"/frame-*.webp "$OUT/manifest.json"
mkdir -p "$OUT"

echo "extracting ${FPS}fps at ${WIDTH}px as ${EXT} from $(basename "$VIDEO") ..."
ffmpeg -loglevel error -i "$VIDEO" \
  -vf "fps=${FPS},scale=${WIDTH}:-2" \
  "${CODEC[@]}" "$OUT/frame-%04d.${EXT}"

COUNT=$(find "$OUT" -name "frame-*.${EXT}" | wc -l | tr -d ' ')
if [[ "$COUNT" -lt 2 ]]; then
  echo "error: extracted $COUNT frames" >&2
  exit 1
fi

# site.js reads count and ext from here, so no hand-editing when encoding changes
printf '{"count": %s, "fps": %s, "ext": "%s", "quality": %s, "width": %s}\n' \
  "$COUNT" "$FPS" "$EXT" "$QUALITY" "$WIDTH" > "$OUT/manifest.json"

echo "wrote $COUNT frames + manifest.json"
du -sh "$OUT" | awk '{print "frames dir: " $1}'
