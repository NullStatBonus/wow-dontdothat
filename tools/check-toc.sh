#!/bin/sh
# Verifies every file listed in the addon TOC exists. Usage: tools/check-toc.sh [path/to/file.toc]
toc="${1:-DontDoThat/DontDoThat_Camelot.toc}"
dir=$(dirname "$toc")
status=0
grep -v -e '^##' -e '^#' -e '^[[:space:]]*$' "$toc" | tr -d '\r' | while IFS= read -r entry; do
  path="$dir/$(printf '%s' "$entry" | tr '\\' '/')"
  if [ -f "$path" ]; then echo "ok       $entry"; else echo "MISSING  $entry"; exit 1; fi
done
status=$?
grep -q '^## Interface: ' "$toc" || { echo "MISSING  ## Interface line"; status=1; }
exit $status
