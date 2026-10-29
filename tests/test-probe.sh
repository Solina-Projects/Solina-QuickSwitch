#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

out=$(bash scripts/probe-device.sh --fixture tests/fixtures/android16-kernelsu.properties) || fail "modern fixture probe failed"
grep -Fxq 'android_api=36' <<<"$out" || fail "API level was not parsed"
grep -Fxq 'root_manager=KernelSU' <<<"$out" || fail "manager was not parsed"
grep -Fxq 'compatibility=candidate_only' <<<"$out" || fail "expected candidate-only status"
grep -Fxq 'changes_made=false' <<<"$out" || fail "probe must report no changes"
pass "modern Android fixture is parsed without device changes"

out=$(bash scripts/probe-device.sh --fixture tests/fixtures/android-old.properties) || fail "old fixture probe failed"
grep -Fxq 'compatibility=unsupported_api' <<<"$out" || fail "old API must be marked unsupported"
pass "old Android API is marked unsupported"

out=$(bash scripts/probe-device.sh --fixture tests/fixtures/unknown-manager.properties) || fail "unknown-manager fixture probe failed"
grep -Fxq 'compatibility=needs_manual_review' <<<"$out" || fail "unknown manager must require manual review"
pass "unknown root manager requires manual review"

if bash scripts/probe-device.sh --fixture tests/fixtures/android16-kernelsu.properties --unexpected >/dev/null 2>&1; then
  fail "unknown command-line arguments must fail"
fi
pass "invalid command-line arguments are rejected"

printf '\nProbe tests passed. Fixtures are simulated and do not certify any real device.\n'
