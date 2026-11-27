import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import revision3  # noqa: E402


def rows(*levels):
    return [{"rank": i + 1, "level": lv} for i, lv in enumerate(levels)]


# One class with two specs. Family 1 "Bolt" has core rotation for spec A only; family 2 "Wave" is core for neither.
RULES = {"T": {
    "specs": {"A": {"core": [1]}, "B": {"core": []}},
    "families": {
        "1": {"name": "Bolt", "rows": rows(1, 10, 20, 30, 40)},
        "2": {"name": "Wave", "rows": rows(4, 12, 24, 36)},
        "3": {"name": "Aura", "rows": rows(6, 16, 26)},
    },
}}
GUIDE = {"class": "T", "source": "wowhead"}


def entry(kind, specs=None, source="guide", **numbers):
    e = {"source": source, "reason": dict(kind=kind, **numbers)}
    if specs:
        e["specs"] = specs
    return e


def build(statements, v2=None):
    return revision3.build_revision3(RULES, {}, {"T": v2 or {}}, [dict(GUIDE, **s) for s in statements])


def skipped(entries, fid, rank, spec):
    """The (source, kind) a spec skips the rank for in revision 3's changed list, 'unchanged' or None (bought)."""
    ents = entries.get("T", {}).get(fid, {}).get(rank)
    if ents is None:
        return "unchanged"
    for e in ents:
        if spec in (e.get("specs") or ["A", "B"]):
            return (e["source"], e["reason"]["kind"])
    return None


class Revision3Test(unittest.TestCase):
    def test_rank_one_is_never_skipped(self):
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "first"}])
        self.assertEqual(skipped(entries, 2, 1, "B"), "unchanged")
        self.assertEqual(skipped(entries, 2, 2, "B"), ("guideForever", "guideFirstRankOnly"))

    def test_a_statement_touches_only_its_own_spec(self):
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "first"}])
        self.assertEqual(skipped(entries, 2, 2, "A"), None)
        self.assertEqual(entries["T"][2][2][0]["specs"], ["B"])

    def test_all_removes_revision_2s_skip_for_that_spec_only(self):
        v2 = {2: {3: [entry("smallStep", pct=10, source="computed")]}}
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "all"}], v2)
        self.assertEqual(skipped(entries, 2, 3, "B"), None)
        self.assertEqual(skipped(entries, 2, 3, "A"), ("computed", "smallStep"))

    def test_an_optional_spell_in_the_core_rotation_is_held(self):
        entries, report = build([{"spec": "A", "spell": "Bolt", "op": "optfirst"}])
        self.assertEqual(entries, {})
        self.assertEqual(len(report["held"]), 1)

    def test_any_operation_marked_optional_is_held_in_the_core_rotation(self):
        entries, report = build([{"spec": "A", "spell": "Bolt", "op": "skip", "arg": [2, 3], "optional": True}])
        self.assertEqual(entries, {})
        self.assertEqual(len(report["held"]), 1)
        entries, _ = build([{"spec": "B", "spell": "Bolt", "op": "skip", "arg": [2, 3], "optional": True}])
        self.assertEqual(skipped(entries, 1, 2, "B"), ("guideForever", "guideNotTrained"))

    def test_skip_names_only_the_listed_ranks_and_keeps_revision_2_for_the_rest(self):
        v2 = {2: {2: [entry("guideFirstRankOnly")], 3: [entry("guideFirstRankOnly")]}}
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "skip", "arg": [3]}], v2)
        self.assertEqual(skipped(entries, 2, 2, "B"), "unchanged")  # revision 2's skip stays
        self.assertEqual(skipped(entries, 2, 3, "B"), ("guideForever", "guideNotTrained"))
        self.assertEqual(skipped(entries, 2, 4, "B"), "unchanged")

    def test_a_target_rank_table_at_the_top_rank_says_nothing(self):
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "top", "arg": 4}])
        self.assertEqual(entries, {})
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "top", "arg": 2}])
        self.assertEqual(skipped(entries, 2, 3, "B"), ("guideForever", "guideUpToRank"))
        self.assertEqual(skipped(entries, 2, 2, "B"), "unchanged")

    def test_a_level_list_is_used_only_when_every_level_is_a_rank_level(self):
        entries, report = build([{"spec": "B", "spell": "Wave", "op": "lv", "arg": [12, 25]}])
        self.assertEqual(entries, {})
        self.assertEqual(len(report["ignored"]), 1)
        entries, report = build([{"spec": "B", "spell": "Wave", "op": "lv", "arg": [12, 36]}])
        self.assertEqual(report["ignored"], [])
        self.assertEqual(skipped(entries, 2, 3, "B"), ("guideForever", "guideNotTrained"))  # level 24 is not listed
        self.assertEqual(skipped(entries, 2, 2, "B"), "unchanged")  # level 12 is listed and revision 2 bought it
        self.assertEqual(skipped(entries, 2, 1, "B"), "unchanged")

    def test_an_open_list_leaves_ranks_above_its_last_level_alone(self):
        v2 = {2: {4: [entry("waitForMount", source="computed")]}}
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "lv", "arg": [24], "open": True}], v2)
        self.assertEqual(skipped(entries, 2, 2, "B"), ("guideForever", "guideNotTrained"))  # level 12 is below the last level and not listed
        self.assertEqual(skipped(entries, 2, 4, "B"), "unchanged")  # level 36, above it: revision 2 stays

    def test_after_a_level_skips_only_later_ranks_and_names_the_level(self):
        entries, _ = build([{"spec": "B", "spell": "Aura", "op": "after", "arg": 10, "source": "method"}])
        self.assertEqual(skipped(entries, 3, 2, "B"), ("guideMethod", "guideUselessAfter"))
        self.assertEqual(skipped(entries, 3, 1, "B"), "unchanged")

    def test_after_a_level_never_skips_rank_one_even_when_it_unlocks_later(self):
        entries, _ = build([{"spec": "B", "spell": "Wave", "op": "after", "arg": 2, "source": "method"}])
        self.assertEqual(skipped(entries, 2, 1, "B"), "unchanged")
        self.assertEqual(skipped(entries, 2, 2, "B"), ("guideMethod", "guideUselessAfter"))

    def test_unknown_spells_are_reported_not_applied(self):
        entries, report = build([{"spec": "B", "spell": "Nothing", "op": "first"}])
        self.assertEqual(entries, {})
        self.assertEqual(report["unmatched"], ["T Nothing"])

    def test_the_shipped_statements_name_real_guide_pages(self):
        path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "revision3.json")
        with open(path) as f:
            statements = json.load(f)["statements"]
        for s in statements:
            self.assertTrue(s["page"].startswith("https://www."), s)
            self.assertRegex(s["updated"], r"^2026-\d\d-\d\d$")
            self.assertIn(s["source"], revision3.SOURCES)


if __name__ == "__main__":
    unittest.main()
