"""Revision 3 of the rank-skip list: revision 2 corrected by the WoW Forever leveling guides.

Revision 3 inherits revision 2 and lists only the ranks whose skip decision changed for at least one spec. The
statements come from tools/skip-revision/revision3.json, one per spell and spec, each naming the guide page it was read
from. The rules that combine them with revision 2 are in tools/skip-revision/README.md ("Revision 3").
"""
import collections
import json
import os

TOOLS = os.path.dirname(os.path.abspath(__file__))
SOURCES = {"wowhead": "guideForever", "method": "guideMethod"}


def norm(name):
    return name.lower().replace("'", "").replace(chr(8217), "")


def rev2_state(rules, v1, v2):
    """{ (class, familyId, rank): { spec: (source, reason json) } } for revision 2: v2's list for a rank replaces v1's."""
    state = {}
    for cls, data in rules.items():
        specs = sorted(data["specs"])
        for fid_s, fam in data["families"].items():
            fid = int(fid_s)
            for row in fam["rows"]:
                rank = row["rank"]
                ents = v2.get(cls, {}).get(fid, {}).get(rank)
                if ents is None:
                    ents = v1.get(cls, {}).get(fid, {}).get(rank, [])
                per = {}
                for e in ents:
                    for spec in e.get("specs") or specs:
                        per[spec] = (e["source"], json.dumps(e["reason"], sort_keys=True))
                state[(cls, fid, rank)] = per
    return state


def apply_statement(st, fam, core, report):
    """What one statement decides, as { rank: reason or None } for the ranks it speaks about, or None when it leaves
    revision 2's decision alone. A rank it does not speak about keeps revision 2's decision."""
    rows = sorted(fam["rows"], key=lambda r: r["rank"])
    op, arg = st["op"], st.get("arg")
    who = f"{st['class']} {st['spec']} {fam['name']}"
    ranks = [r["rank"] for r in rows]
    out = {}
    if (st.get("optional") or op == "optfirst") and fam["fid"] in core:
        report["held"].append(f"{who}: the guide calls it optional, but it is core rotation here")
        return None
    if op == "all":
        out = {rank: None for rank in ranks}
    elif op in ("first", "optfirst"):
        out = {rank: ({"kind": "guideFirstRankOnly"} if rank >= 2 else None) for rank in ranks}
    elif op == "skip":
        out = {rank: {"kind": "guideNotTrained"} for rank in ranks if rank in arg}
    elif op == "up":
        out = {rank: ({"kind": "guideUpToRank", "n": arg} if rank > arg else None) for rank in ranks}
    elif op == "top":
        # a table that gives only the highest rank to reach says nothing about the ranks in between
        out = {rank: {"kind": "guideUpToRank", "n": arg} for rank in ranks if rank > arg}
        if not out:
            return None
    elif op == "after":
        out = {r["rank"]: {"kind": "guideUselessAfter", "n": arg} for r in rows if r["level"] > arg}
    elif op == "lv":
        levels = {r["level"] for r in rows}
        bad = [lv for lv in arg if lv not in levels and lv != 1]
        if bad:
            report["ignored"].append(f"{who}: guide levels {bad} do not match the rank levels {sorted(levels)}")
            return None
        trained = set(arg) | {rows[0]["level"]}
        top = max(arg)
        for r in rows:
            if st.get("open") and r["level"] > top:
                continue  # the list stops before this rank; the guide says nothing about it
            out[r["rank"]] = None if r["level"] in trained else {"kind": "guideNotTrained"}
    else:
        raise ValueError(f"unknown op {op} for {who}")
    out.pop(rows[0]["rank"], None)  # rank 1 is never skipped
    return out


def build_revision3(rules, v1, v2, statements=None):
    """Returns (entries, report): entries = { class: { familyId: { rank: [entry, ...] } } } for the changed ranks.
    statements defaults to revision3.json; tests pass their own."""
    if statements is None:
        statements = json.load(open(os.path.join(TOOLS, "revision3.json")))["statements"]
    old = rev2_state(rules, v1, v2)
    report = {"held": [], "ignored": [], "unmatched": [], "statements": len(statements)}
    by_name = {}
    for cls, data in rules.items():
        for fid_s, fam in data["families"].items():
            by_name[(cls, norm(fam["name"]))] = dict(fam, fid=int(fid_s))
    applied = {}  # (class, fid, spec) -> { rank: (source, reason json) | None }, only for the ranks a statement speaks about
    for st in statements:
        fam = by_name.get((st["class"], norm(st["spell"])))
        if fam is None:
            report["unmatched"].append(f"{st['class']} {st['spell']}")
            continue
        core = set(rules[st["class"]]["specs"][st["spec"]].get("core") or [])
        got = apply_statement(st, fam, core, report)
        if got is None:
            continue
        slot = applied.setdefault((st["class"], fam["fid"], st["spec"]), {})
        for rank, reason in got.items():
            slot[rank] = None if reason is None else (SOURCES[st["source"]], json.dumps(reason, sort_keys=True))
    entries = {}
    stats = {"added": 0, "dropped": 0, "relabelled": 0, "skipped": 0, "rev2_skipped": 0}
    per_class = collections.defaultdict(lambda: {"rev2": 0, "rev3": 0, "added": 0, "dropped": 0, "relabelled": 0})
    for (cls, fid, rank), per in sorted(old.items()):
        specs = sorted(rules[cls]["specs"])
        new = {}
        changed = False
        for spec in specs:
            slot = applied.get((cls, fid, spec))
            state = slot[rank] if slot is not None and rank in slot else per.get(spec)
            new[spec] = state
            pc = per_class[cls]
            pc["rev2"] += per.get(spec) is not None
            pc["rev3"] += state is not None
            if state != per.get(spec):
                changed = True
                if per.get(spec) is None:
                    stats["added"] += 1
                    pc["added"] += 1
                elif state is None:
                    stats["dropped"] += 1
                    pc["dropped"] += 1
                else:
                    stats["relabelled"] += 1
                    pc["relabelled"] += 1
        stats["skipped"] += sum(1 for s in specs if new[s] is not None)
        stats["rev2_skipped"] += sum(1 for s in specs if per.get(s) is not None)
        if not changed:
            continue
        groups = collections.OrderedDict()
        for spec in specs:
            if new[spec] is not None:
                groups.setdefault(new[spec], []).append(spec)
        ents = []
        for (source, reason), sp in groups.items():
            e = {"source": source, "reason": json.loads(reason)}
            if sp != specs:
                e["specs"] = sp
            ents.append(e)
        entries.setdefault(cls, {}).setdefault(fid, {})[rank] = ents
    report["stats"] = stats
    report["per_class"] = dict(per_class)
    return entries, report
