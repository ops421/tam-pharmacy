#!/usr/bin/env bash
# Is tampharmacy.com pointed at GitHub Pages yet?
#
#   scripts/check-dns.sh          one check
#   scripts/check-dns.sh --watch  re-check every 60s until it flips
#
# Queries 8.8.8.8 directly rather than the local resolver, because a stale
# negative cache on this machine will otherwise report failure long after the
# records are actually live.
set -uo pipefail

DOMAIN="tampharmacy.com"
PAGES_HOST="ops421.github.io"
EXPECTED=(185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153)

check () {
  local ok=0

  echo "== $(date '+%Y-%m-%d %H:%M:%S') =="

  # --- apex A records -------------------------------------------------------
  local a
  a=$(dig +short @8.8.8.8 A "$DOMAIN" | sort | tr '\n' ' ')
  local hits=0
  for ip in "${EXPECTED[@]}"; do
    [[ "$a" == *"$ip"* ]] && hits=$((hits+1))
  done
  if [[ $hits -eq 4 ]]; then
    echo "  A records      OK   all four GitHub Pages IPs"
  elif [[ $hits -gt 0 ]]; then
    echo "  A records      PART $hits of 4 present: $a"
  else
    echo "  A records      NO   currently: ${a:-none}"
    ok=1
  fi

  # --- www ------------------------------------------------------------------
  local w
  w=$(dig +short @8.8.8.8 CNAME www."$DOMAIN")
  if [[ "$w" == "$PAGES_HOST." ]]; then
    echo "  www CNAME      OK   -> $w"
  else
    echo "  www CNAME      NO   currently: ${w:-none} (want $PAGES_HOST.)"
    ok=1
  fi

  # --- mail must survive the change ----------------------------------------
  local mx
  mx=$(dig +short @8.8.8.8 MX "$DOMAIN" | wc -l | tr -d ' ')
  if [[ "$mx" -ge 5 ]]; then
    echo "  MX records     OK   $mx present, Google Workspace mail intact"
  else
    echo "  MX records     WARN only $mx found, mail may have been disturbed"
  fi

  # --- is Pages actually answering? ----------------------------------------
  local code server
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 12 -L "https://$DOMAIN" 2>/dev/null)
  server=$(curl -s -o /dev/null -D - --max-time 12 -L "https://$DOMAIN" 2>/dev/null | grep -i '^server:' | tr -d '\r' | cut -d' ' -f2-)
  if [[ "$code" == "200" && "$server" == *"GitHub"* ]]; then
    echo "  https://$DOMAIN  OK   200 from ${server:-?}"
  else
    echo "  https://$DOMAIN  NO   ${code:-no response} from ${server:-?}"
    ok=1
  fi

  return $ok
}

if [[ "${1:-}" == "--watch" ]]; then
  while true; do
    if check; then
      echo
      echo "DNS is live. Next: add the custom domain on the GitHub side."
      exit 0
    fi
    echo "  ... re-checking in 60s (Ctrl+C to stop)"
    echo
    sleep 60
  done
else
  check
fi
