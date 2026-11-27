.PHONY: test check plan

# luajit tests/run.lua [pattern] runs a subset, e.g. luajit tests/run.lua trainer
test:
	@luajit tests/run.lua

# The in-game test plans, checked with the installed CheckThat tools (AGENTS.md, Testing). make test and make check
# never need them. A plan's replay hooks are plans/<name>.hooks.lua when that file exists; its offline block runs
# when the plan has one.
CT ?= ct
PLANS ?= plans/dontdothat.yaml plans/dontdothat.purchases.yaml plans/dontdothat-pr72.yaml
plan:
	@command -v "$(CT)" >/dev/null 2>&1 || { echo "plan: no CheckThat tools ($(CT) not found); install them with make install-skill BIN_DIR=\$$HOME/bin in CheckThat, or set CT=<path to ct>" >&2; exit 1; }
	@mkdir -p build
	@set -e; for plan in $(PLANS); do \
		name=$$(basename "$$plan" .yaml); \
		hooks=""; [ -f "plans/$$name.hooks.lua" ] && hooks="--hooks plans/$$name.hooks.lua"; \
		echo "== $$plan"; \
		"$(CT)" validate "$$plan" --addon-src DontDoThat; \
		"$(CT)" compile "$$plan" -o "build/$$name.ct"; \
		"$(CT)" replay-flow "$$plan" $$hooks; \
		"$(CT)" lines "$$plan" --addon-src DontDoThat || true; \
		if grep -q '^offline:' "$$plan"; then "$(CT)" offline "$$plan" --client both; fi; \
	done

# The same checks the release workflow runs.
check:
	@for toc in DontDoThat/DontDoThat_*.toc; do sh tools/check-toc.sh "$$toc" || exit 1; done
	@sh tools/check-tocs-match.sh
	@bash tools/check-embeds.sh
	@sh tools/check-version.sh
