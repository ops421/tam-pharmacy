#!/usr/bin/env bash
# Composite the TAM Pharmacy wordmark onto a generated background plate and
# export a login screen wallpaper at exact pixel size.
#
#   scripts/make-login-image.sh ~/Downloads/plate.png
#   scripts/make-login-image.sh plate.png out.png --logo-width 520 --logo-y 38
#
# The logo is placed from assets/logo/tam-pharmacy.svg, which is real vector, so
# it stays sharp at any size. Never let an image model draw the wordmark: it
# produces a bent approximation that is unusable as branding.
#
# Rendering goes through headless Chrome rather than an image library because it
# rasterises the SVG at final resolution instead of scaling a bitmap, and gives
# exact control over position in one pass.
set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGO="$SITE_DIR/assets/logo/tam-pharmacy.svg"

PLATE="${1:-}"
OUT="${2:-$SITE_DIR/../_source/tam-pharmacy/login-screen.png}"
[[ "${OUT}" == --* ]] && { OUT="$SITE_DIR/../_source/tam-pharmacy/login-screen.png"; shift 1; } || shift 2 2>/dev/null || shift 1

W=2560; H=1440
LOGO_WIDTH=620          # px at 2560 wide
LOGO_Y=42               # vertical centre of the wordmark, % of frame height
LOGO_COLOR="#f5f1e8"
HALO=1                  # soft dark halo behind the mark

while [[ $# -gt 0 ]]; do
  case "$1" in
    --logo-width) LOGO_WIDTH="$2"; shift 2 ;;
    --logo-y)     LOGO_Y="$2";     shift 2 ;;
    --logo-color) LOGO_COLOR="$2"; shift 2 ;;
    --size)       W="${2%x*}"; H="${2#*x}"; shift 2 ;;
    --no-halo)    HALO=0; shift ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$PLATE" && -f "$PLATE" ]] || { echo "usage: $0 <plate-image> [out.png] [flags]" >&2; exit 1; }
[[ -f "$LOGO" ]] || { echo "error: logo not found at $LOGO" >&2; exit 1; }

BROWSER=""
for b in google-chrome google-chrome-stable chromium chromium-browser; do
  command -v "$b" >/dev/null && { BROWSER="$b"; break; }
done
[[ -n "$BROWSER" ]] || { echo "error: no Chrome/Chromium on PATH" >&2; exit 1; }

PLATE_ABS="$(cd "$(dirname "$PLATE")" && pwd)/$(basename "$PLATE")"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

python3 - "$PLATE_ABS" "$LOGO" "$TMP/compose.html" \
         "$W" "$H" "$LOGO_WIDTH" "$LOGO_Y" "$LOGO_COLOR" "$HALO" <<'PY'
import sys, pathlib
plate, logo, out, w, h, lw, ly, color, halo = sys.argv[1:10]
w, h, lw, ly, halo = int(w), int(h), int(lw), float(ly), int(halo)

svg = pathlib.Path(logo).read_text().strip()
# strip the fixed width/height so CSS drives the size; keep the viewBox
svg = svg.replace('width="535" height="213" ', '', 1)

shadow = ('filter: drop-shadow(0 0 90px rgba(0,0,0,.85)) '
          'drop-shadow(0 0 34px rgba(0,0,0,.7));') if halo else ''

pathlib.Path(out).write_text(f"""<!doctype html><meta charset="utf-8">
<style>
  html,body {{ margin:0; padding:0; background:#050505; overflow:hidden; }}
  .frame {{
    position:relative; width:{w}px; height:{h}px; overflow:hidden;
    background:#050505 url("file://{plate}") no-repeat center center / cover;
  }}
  .mark {{
    position:absolute; left:50%; top:{ly}%;
    transform:translate(-50%,-50%);
    width:{lw}px; color:{color}; {shadow}
  }}
  .mark svg {{ width:100%; height:auto; display:block; }}
</style>
<div class="frame"><div class="mark">{svg}</div></div>
""")
PY

"$BROWSER" --headless --disable-gpu --no-sandbox --hide-scrollbars \
  --force-device-scale-factor=1 --window-size="$W,$H" \
  --screenshot="$OUT" "file://$TMP/compose.html" >/dev/null 2>&1

[[ -f "$OUT" ]] || { echo "error: render produced no file" >&2; exit 1; }

echo "wrote $OUT"
python3 - "$OUT" <<'PY'
import struct, sys
d = open(sys.argv[1],'rb').read(33)
w, h = struct.unpack('>II', d[16:24])
import os
print(f"  {w} x {h}, {os.path.getsize(sys.argv[1])/1024:.0f} KB")
PY
