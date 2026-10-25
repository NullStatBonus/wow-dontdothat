#!/usr/bin/env python3
"""Lists a class's spell families from the local cache (tools/.cache/class-spells.json), for writing or
checking Rules/Data/<Class>.lua: name, rank count, first level, T for a talent spell, F for Forever-only.

Usage: tools/class-families.py PALADIN [MAGE ...]

The cache is built from wago.tools tables for WoW Forever and Classic Era (see tools/build-spell-data.py).
Rows at level 0 or 1 with no ranks are passives, effects and rune abilities and are left out.
"""
import collections
import json
import os
import sys

SKIP_LINES = {"Runes", "Engraving", "GENERIC (DND)", "All - Specializations"}

cache = os.path.join(os.path.dirname(__file__), ".cache", "class-spells.json")
classes = json.load(open(cache))["classes"]
for name in sys.argv[1:]:
    c = classes[name.upper()]
    talents = {t["name"] for tab in c["talents"]["forever"].values() for t in tab}
    era = {n for rows in c["spells"]["era"].values() for n, *_ in rows}
    fam = collections.OrderedDict()
    for line, rows in c["spells"]["forever"].items():
        if line in SKIP_LINES or line.startswith("Racial"):
            continue
        for n, rank, level, _ in rows:
            fam.setdefault(n, []).append((rank, level))
    print(f"== {name.upper()} tabs {c['tabs']['forever']}")
    out = []
    for n, rs in sorted(fam.items(), key=lambda kv: min(l for _, l in kv[1])):
        level = min(l for _, l in rs)
        ranks = len({r for r, _ in rs if r})
        if level <= 1 and not ranks:
            continue
        flag = ("T" if n in talents else "") + ("" if n in era else "F")
        out.append(f"{n}[{ranks or ''}@{level}{flag}]")
    print("; ".join(out))
