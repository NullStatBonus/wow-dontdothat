#!/bin/bash
# Verifies every Script/Include path in DontDoThat/embeds.xml (recursively) exists.
cd "$(dirname "$0")/.." || exit 1
fail=0
check() {
  local xml="$1" dir; dir=$(dirname "$xml")
  sed "s/<!--.*-->//" "$xml" | grep -o '<\(Script\|Include\) file="[^"]*"' | sed 's/.*file="//; s/"$//' | while read -r p; do
    local f; f="$dir/$(printf '%s' "$p" | tr '\\' '/')"
    if [ -f "$f" ]; then
      echo "ok   $f"
      case "$f" in *.xml) check "$f" || echo "FAIL nested" ;; esac
    else
      echo "MISSING $f"; touch /tmp/.ddt_embed_fail.$$
    fi
  done
}
check DontDoThat/embeds.xml
if [ -f /tmp/.ddt_embed_fail.$$ ]; then rm -f /tmp/.ddt_embed_fail.$$; echo "FAILED"; exit 1; fi
echo "All embed paths exist"
