#!/usr/bin/env bash
set -euo pipefail
fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

bash "$root/scripts/build-plan.sh" --probe "$root/tests/fixtures/android16-kernelsu.properties" --state "$root/tests/fixtures/state-launcher-known.properties" > "$tmp"
grep -Fxq 'plan_status=blocked' "$tmp" || fail "plan must remain blocked"
grep -Fxq 'planned_actions=0' "$tmp" || fail "plan must contain zero actions"
grep -Fxq 'state_changes_allowed=false' "$tmp" || fail "state changes must remain disabled"
grep -Fxq 'executable_commands=none' "$tmp" || fail "plan must not emit executable commands"
grep -Fxq 'device_access=none' "$tmp" || fail "plan must not access a device"
grep -Fxq 'changes_made=false' "$tmp" || fail "plan must report no changes"
pass "known synthetic state produces a blocked, non-mutating preview"

bash "$root/scripts/build-plan.sh" --probe "$root/tests/fixtures/android16-kernelsu.properties" --state "$root/tests/fixtures/state-missing-provider.properties" > "$tmp"
grep -Fxq 'plan_status=blocked' "$tmp" || fail "incomplete state must remain blocked"
grep -Fxq 'synthetic_provider_state=unknown' "$tmp" || fail "unknown provider state must be preserved"
pass "incomplete synthetic state remains blocked"

if bash "$root/scripts/build-plan.sh" --probe "$root/tests/fixtures/android16-kernelsu.properties" --state "$root/tests/fixtures/state-malformed.properties" > "$tmp" 2>&1; then
  fail "malformed state must be rejected"
fi
pass "malformed synthetic state is rejected"
printf '\nAll plan-builder tests passed using simulated fixtures only.\n'
