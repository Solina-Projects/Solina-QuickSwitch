#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

probe=$(bash scripts/probe-device.sh --fixture tests/fixtures/android16-kernelsu.properties) || fail "modern probe fixture failed"
out=$(printf '%s\n' "$probe" | bash scripts/resolve-capabilities.sh) || fail "resolver rejected modern probe output"
grep -Fxq 'capability_status=untested' <<<"$out" || fail "unverified combination must remain untested"
grep -Fxq 'state_changes_allowed=false' <<<"$out" || fail "resolver must block state changes"
grep -Fxq 'support_matrix=missing' <<<"$out" || fail "resolver must disclose missing support matrix"
pass "modern fixture remains untested and blocks state changes"

probe=$(bash scripts/probe-device.sh --fixture tests/fixtures/android-old.properties) || fail "old probe fixture failed"
out=$(printf '%s\n' "$probe" | bash scripts/resolve-capabilities.sh) || fail "resolver rejected old probe output"
grep -Fxq 'capability_status=unsupported' <<<"$out" || fail "old API must be unsupported"
pass "old API is rejected"

probe=$(bash scripts/probe-device.sh --fixture tests/fixtures/unknown-manager.properties) || fail "unknown-manager fixture failed"
out=$(printf '%s\n' "$probe" | bash scripts/resolve-capabilities.sh) || fail "resolver rejected unknown-manager output"
grep -Fxq 'capability_status=manual_review' <<<"$out" || fail "unknown manager must require manual review"
pass "unknown manager requires manual review"

out=$(bash scripts/resolve-capabilities.sh --probe tests/fixtures/incomplete-probe.properties) || fail "resolver rejected incomplete probe"
grep -Fxq 'capability_status=blocked' <<<"$out" || fail "incomplete probe must be blocked"
pass "incomplete probe is blocked"

if bash scripts/resolve-capabilities.sh --probe tests/fixtures/malformed-probe.properties >/dev/null 2>&1; then
  fail "malformed API value must be rejected"
fi
pass "malformed probe data is rejected"

printf '\nCapability resolver tests passed. All inputs are simulated; no device state was changed.\n'
