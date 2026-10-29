#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

out=$(bash scripts/inventory-launchers.sh --fixture tests/fixtures/home-candidates.properties) || fail "fixture inventory failed"
grep -Fxq 'home_candidate_count=2' <<<"$out" || fail "expected two HOME candidates"
grep -Fxq 'home_candidate_1_package=com.android.launcher3' <<<"$out" || fail "launcher package candidate missing"
grep -Fxq 'home_candidate_1_version=unknown' <<<"$out" || fail "unknown version must remain explicit"
grep -Fxq 'home_candidate_2_package=com.example.solinalauncher' <<<"$out" || fail "Solina fixture candidate missing"
grep -Fxq 'active_home=not_identified' <<<"$out" || fail "inventory must not guess active launcher"
grep -Fxq 'quickstep_support=not_verified' <<<"$out" || fail "inventory must not infer Quickstep support"
grep -Fxq 'changes_made=false' <<<"$out" || fail "inventory must remain read-only"
pass "fixture HOME candidates are listed without claiming active launcher or Quickstep support"

if bash scripts/inventory-launchers.sh --fixture tests/fixtures/home-invalid.properties >/dev/null 2>&1; then
  fail "malformed package names must be rejected"
fi
pass "malformed fixture package names are rejected"
printf '\nLauncher inventory tests passed. Fixtures are simulated, not device evidence.\n'
