#!/usr/bin/env python3
"""Builds DontDoThat/Data/SpellData.lua: the spells each supported class can learn, with ID, rank and level.

Source of spell facts: the game's own database tables, as published by wago.tools for a given build
(default: the newest WoW Forever build). Source of prices: a debug report written by the addon
(`/ddt export`) captured at a Hunter trainer and a Pet Trainer. Trainer prices are not in the game's
data files, so any spell whose price was never seen gets an estimate from its level.

Hunter rows are limited to the families the exported trainers were seen selling. Paladin has no trainer
export yet, so it lists every spell in its three talent trees plus Plate Mail, Mounts and Riding from the
game tables (the Judgement-of-X effect spells are marked kind = "effect" so they never count as purchases),
and its price estimates borrow the Hunter table until a Paladin trainer is exported.

Usage:
    tools/build-spell-data.py [--export debug.txt] [--build 1.60.1.70532] [--cache DIR] [--out FILE]
                              [--classes HUNTER,PALADIN] [--keep HUNTER]

--keep copies that class's block unchanged from the existing --out file, so adding a class does not
rewrite prices that came from an older trainer export.

Run it again when a new build ships or after exporting more trainers, then commit the result.
"""
import argparse
import collections
import csv
import json
import os
import re
import sys
import urllib.request

HUNTER_MASK = 4  # SkillLineAbility.ClassMask bit for Hunter
# Skill lines whose spells a Hunter buys or is taught. The three trees are the trainer's own headers;
# Beast Training is the hunter-side half of pet abilities; Dual Wield and Mail are trainer categories.
CLASS_LINES = {"Beast Mastery", "Marksmanship", "Survival", "Dual Wield", "Mail"}
PET_LINES = {"Beast Training", "Pet - Generic"}
TABLES = ["SpellName", "Spell", "SpellLevels", "SkillLine", "SkillLineAbility"]

PALADIN_MASK = 2
# The three trees, plus the trainer's Plate Mail entry and the mount spells.
PALADIN_LINES = {"Holy", "Protection", "Retribution", "Plate Mail", "Mounts", "Riding"}
PALADIN_EFFECT_PREFIXES = ("Judgement of ",)  # what a Judgement does, not something the trainer sells

# The other classes: skill lines the trainer teaches from (the three trees plus its proficiency entries),
# spells that belong to one race, and what a spell is called when it is an effect or a passive rather than
# something sold. Racial and effect rows get their own kind so they never count as purchases.
OTHER_CLASSES = {
    "MAGE": {"mask": 128, "lines": {"Arcane", "Fire", "Frost", "Comprehension"}, "racial": set()},
    "WARLOCK": {"mask": 256, "lines": {"Affliction", "Demonology", "Destruction", "Explorer Imp"}, "racial": set()},
    "PRIEST": {"mask": 16, "lines": {"Discipline", "Holy", "Shadow Magic"},
               "racial": {"Starshards", "Hex of Weakness", "Touch of Weakness", "Elune's Grace", "Feedback",
                          "Shadowguard", "Desperate Prayer", "Fear Ward", "Devouring Plague", "Chastise",
                          "Symbol of Hope", "Divine Grace", "Contingency Plan", "Dark Sacrifice", "Confounding Flash"}},
    "DRUID": {"mask": 1024, "lines": {"Balance", "Feral Combat", "Restoration"}, "racial": set()},
    "SHAMAN": {"mask": 64, "lines": {"Elemental Combat", "Enhancement", "Restoration", "Mail", "Dual Wield"}, "racial": set()},
    "ROGUE": {"mask": 8, "lines": {"Assassination", "Combat", "Subtlety", "Poisons", "Dual Wield"}, "racial": set()},
    "WARRIOR": {"mask": 1, "lines": {"Arms", "Fury", "Protection", "Plate Mail", "Dual Wield"}, "racial": set()},
}
EFFECT_NAME = re.compile(r"( Effect| Passive\d?|\(Passive\d?\)| Bleed)$")

# wago.tools answers Python's default User-Agent with HTTP 403.
USER_AGENT = {"User-Agent": "Mozilla/5.0"}


def get(url, timeout):
    return urllib.request.urlopen(urllib.request.Request(url, headers=USER_AGENT), timeout=timeout)


def fetch(table, build, cache):
    path = os.path.join(cache, f"{table}-{build}.csv")
    if not os.path.exists(path):
        url = f"https://wago.tools/db2/{table}/csv?build={build}"
        print(f"downloading {table} ...", file=sys.stderr)
        with get(url, 120) as resp, open(path, "wb") as out:
            out.write(resp.read())
    with open(path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def newest_forever_build():
    with get("https://wago.tools/api/builds", 60) as resp:
        return json.load(resp)["wowf"][0]["version"]


def parse_export(path):
    """Trainer rows from an addon report: {kind: {(name, rank): (level, cost)}}."""
    sections, current = [], None
    if not path or not os.path.exists(path):
        return {"class": {}, "pet": {}}
    for line in open(path, encoding="utf-8"):
        if re.match(r'\s+trainer ".*" \(t=', line):
            current = {"headers": [], "rows": []}
            sections.append(current)
        elif line.startswith("  talents (") or line.startswith("  purchase #"):
            current = None
        elif current is not None:
            h = re.match(r"\s+header #\d+ (.+)", line)
            if h:
                current["headers"].append(h.group(1).strip())
            m = re.match(r"\s+#\d+ (.+?) rank=(\S+) level=(\d+) cost=(\d+)c status=\S+", line)
            if m:
                rank = None if m.group(2) == "nil" else int(m.group(2))
                current["rows"].append((m.group(1), rank, int(m.group(3)), int(m.group(4))))
    out = {"class": {}, "pet": {}}
    for s in sections:
        kind = "pet" if "Beast Training" in s["headers"] else "class"
        for name, rank, level, cost in s["rows"]:
            out[kind][(name, rank)] = (level, cost)
    return out


def cost_by_level(rows):
    """Most common price at each level (a price is a function of level for ordinary trainer spells)."""
    seen = collections.defaultdict(collections.Counter)
    for (_, _), (level, cost) in rows.items():
        seen[level][cost] += 1
    return {level: counts.most_common(1)[0][0] for level, counts in sorted(seen.items())}


def lua_string(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def merge_rows(rows):
    """The same spell can exist under more than one ID (variants carried by the shared client data). Keep the
    lowest as the primary and list the rest as alternates; a spell counts as learned if any of them is known."""
    merged = {}
    for e in sorted(rows.values(), key=lambda e: e["id"]):
        key = (e["kind"], e["name"], e["rank"], e["level"])
        if key in merged:
            merged[key].setdefault("alt", []).append(e["id"])
            if "cost" in e and "cost" not in merged[key]:
                merged[key]["cost"], merged[key]["seen"] = e["cost"], True
        else:
            merged[key] = dict(e)
    return sorted(merged.values(), key=lambda e: (e["kind"], e["name"], e["rank"] or 0, e["id"]))


def emit_block(name, tables, ordered):
    out = [f"  {name} = {{"]
    for kind, table in tables.items():
        out.append(f"    costByLevel_{kind} = {{")
        out.append("      " + ", ".join(f"[{lvl}] = {cost}" for lvl, cost in table.items()))
        out.append("    },")
    out.append("    rows = {")
    for e in ordered:
        parts = [f"id = {e['id']}", f"name = {lua_string(e['name'])}"]
        if e["rank"] is not None:
            parts.append(f"rank = {e['rank']}")
        parts.append(f"level = {e['level']}")
        parts.append(f"kind = {lua_string(e['kind'])}")
        if "cost" in e:
            parts.append(f"cost = {e['cost']}")
        if e.get("alt"):
            parts.append("alt = { " + ", ".join(str(i) for i in e["alt"]) + " }")
        out.append("      { " + ", ".join(parts) + " },")
    out.append("    },")
    out.append("  },")
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--export", default="debug.txt")
    ap.add_argument("--build")
    ap.add_argument("--cache", default=os.path.join(os.path.dirname(__file__), ".cache"))
    ap.add_argument("--out", default=os.path.join(os.path.dirname(__file__), "..", "DontDoThat", "Data", "SpellData.lua"))
    ap.add_argument("--classes", default="HUNTER,PALADIN,MAGE,WARLOCK,PRIEST,DRUID,SHAMAN,ROGUE,WARRIOR")
    ap.add_argument("--keep", default="", help="classes whose block is copied unchanged from the existing --out file")
    args = ap.parse_args()
    os.makedirs(args.cache, exist_ok=True)
    build = args.build or newest_forever_build()
    classes = [c for c in args.classes.split(",") if c]
    keep = {c for c in args.keep.split(",") if c}

    t = {name: fetch(name, build, args.cache) for name in TABLES}
    names = {r["ID"]: r["Name_lang"] for r in t["SpellName"]}
    subtext = {r["ID"]: r["NameSubtext_lang"] for r in t["Spell"]}
    levels = {r["SpellID"]: r for r in t["SpellLevels"]}
    lines = {r["ID"]: r["DisplayName_lang"] for r in t["SkillLine"]}

    def rank_of(sid):
        m = re.search(r"(\d+)", subtext.get(sid, "") or "")
        return int(m.group(1)) if m else None

    def level_of(sid):
        r = levels.get(sid)
        return (int(r["SpellLevel"]) or int(r["BaseLevel"]) or 0) if r else 0

    blocks, counts = {}, {}

    if "HUNTER" in classes and "HUNTER" not in keep:
        export = parse_export(args.export)
        sold_families = {name for kind in export.values() for (name, _) in kind}
        rows = {}
        for r in t["SkillLineAbility"]:
            if not int(r["ClassMask"] or 0) & HUNTER_MASK:
                continue
            line = lines.get(r["SkillLine"], "")
            if line not in CLASS_LINES and line not in PET_LINES:
                continue
            sid = r["Spell"]
            name = names.get(sid, "")
            if not name:
                continue
            kind = "pet" if line in PET_LINES else "class"
            rank = rank_of(sid)
            level = level_of(sid)
            known = export[kind].get((name, rank))
            # Keep a spell if the trainers were seen selling this family, or it is one of the trainer's categories.
            if name not in sold_families and line not in ("Dual Wield", "Mail"):
                continue
            entry = {"id": int(sid), "name": name, "rank": rank, "level": level, "kind": kind}
            if known:
                entry["cost"] = known[1]
                entry["seen"] = True
            rows[int(sid)] = entry
        ordered = merge_rows(rows)
        tables = {kind: cost_by_level(export[kind]) for kind in ("class", "pet")}
        blocks["HUNTER"] = emit_block("HUNTER", tables, ordered)
        counts["HUNTER"] = f"{len(ordered)} spells ({sum(1 for e in ordered if e.get('seen'))} with a price seen at a trainer)"

    if "PALADIN" in classes and "PALADIN" not in keep:
        rows = {}
        for r in t["SkillLineAbility"]:
            if not int(r["ClassMask"] or 0) & PALADIN_MASK:
                continue
            if lines.get(r["SkillLine"], "") not in PALADIN_LINES:
                continue
            sid = r["Spell"]
            name = names.get(sid, "")
            if not name:
                continue
            kind = "effect" if name.startswith(PALADIN_EFFECT_PREFIXES) else "class"
            rows[int(sid)] = {"id": int(sid), "name": name, "rank": rank_of(sid), "level": level_of(sid), "kind": kind}
        ordered = merge_rows(rows)
        blocks["PALADIN"] = emit_block("PALADIN", {}, ordered)
        counts["PALADIN"] = f"{len(ordered)} spells (no prices seen)"

    for cls, cfg in OTHER_CLASSES.items():
        if cls not in classes or cls in keep:
            continue
        rows = {}
        for r in t["SkillLineAbility"]:
            if not int(r["ClassMask"] or 0) & cfg["mask"]:
                continue
            if lines.get(r["SkillLine"], "") not in cfg["lines"]:
                continue
            sid = r["Spell"]
            name = names.get(sid, "")
            if not name:
                continue
            kind = "effect" if EFFECT_NAME.search(name) else "racial" if name in cfg["racial"] else "class"
            rows[int(sid)] = {"id": int(sid), "name": name, "rank": rank_of(sid), "level": level_of(sid), "kind": kind}
        ordered = merge_rows(rows)
        blocks[cls] = emit_block(cls, {}, ordered)
        counts[cls] = f"{len(ordered)} spells (no prices seen)"

    existing = open(args.out, encoding="utf-8").read() if keep and os.path.exists(args.out) else ""
    for name in sorted(keep):
        m = re.search(rf"(?ms)^  {name} = \{{.*?^  \}},\n", existing)
        if not m:
            sys.exit(f"--keep {name}: no {name} block in {args.out}")
        blocks[name] = m.group(0).rstrip("\n").split("\n")
        counts[name] = "kept as it was"

    out = []
    out.append("local addonName, ns = ...")
    out.append("")
    out.append("-- GENERATED by tools/build-spell-data.py. Do not edit by hand; re-run the script.")
    out.append(f"-- Spell IDs, ranks and levels: the game's database tables for build {build} (via wago.tools).")
    out.append("-- cost (copper): the price seen at a real trainer (Classic Era 1.15.9). seen = true marks those.")
    out.append("-- A spell without cost has no price on record; costByLevel is the estimate for its level.")
    out.append("-- kind = \"effect\" marks a spell that is not sold (what a Judgement does) and kind = \"racial\" one that only some races learn; neither counts as a purchase.")
    out.append("ns.SpellTables = {")
    out.append(f"  build = {lua_string(build)},")
    order = ["HUNTER", "PALADIN"] + list(OTHER_CLASSES)
    for name in order:
        if name in blocks:
            out.extend(blocks[name])
    out.append("}")
    borrowers = [n for n in order[1:] if n in blocks]
    if borrowers and "HUNTER" in blocks:
        out.append("")
        out.append("-- UNVERIFIED: only a Hunter trainer has been exported, so every other class borrows Hunter's price estimates by level.")
        for name in borrowers:
            out.append(f"ns.SpellTables.{name}.costByLevel_class = ns.SpellTables.HUNTER.costByLevel_class")
    out.append("")
    with open(args.out, "w", encoding="utf-8") as f:
        f.write("\n".join(out))
    for name, text in counts.items():
        print(f"{name}: {text}")
    print(f"wrote {args.out} for build {build}")


if __name__ == "__main__":
    main()
