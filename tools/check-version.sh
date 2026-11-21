#!/bin/sh
# Fails unless both TOC files carry the same version, and, when a tag is given (v0.9.0 or 0.9.0), that tag too.
# Also requires a changelog heading for the TOC version.
# Usage: tools/check-version.sh [tag]
dir=DontDoThat
want=$(printf '%s' "${1#v}")
status=0
first=
for toc in "$dir"/DontDoThat_*.toc; do
  v=$(sed -n 's/^## Version:[[:space:]]*//p' "$toc" | tr -d '\r')
  [ -z "$first" ] && first=$v
  if [ -z "$v" ] || [ "$v" != "$first" ]; then echo "VERSION  $(basename "$toc") has '$v', expected '$first'"; status=1; else echo "ok       $(basename "$toc") $v"; fi
  if [ -n "$want" ] && [ "$v" != "$want" ]; then echo "TAG      $(basename "$toc") has '$v' but the tag is '$want'"; status=1; fi
done
if [ -n "$first" ]; then
  if grep -Fxq "## $first" CHANGELOG.md; then
    echo "ok       CHANGELOG.md has $first"
  else
    echo "CHANGELOG CHANGELOG.md has no '## $first' section"
    status=1
  fi
fi
exit $status
