#!/usr/bin/env bash
set -euo pipefail

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

for path in README.md UPSTREAM_REVIEW.md docs/ARCHITECTURE.md docs/SUPPORT_MATRIX.md scripts/probe-device.sh scripts/resolve-capabilities.sh scripts/build-plan.sh tests/test-probe.sh tests/test-resolver.sh tests/test-plan.sh tests/fixtures/state-launcher-known.properties tests/fixtures/state-missing-provider.properties tests/fixtures/state-malformed.properties; do
  [[ -f "$path" ]] || fail "required project file is missing: $path"
done
pass "required docs, scripts, fixtures, and tests exist"

grep -Fq 'planning/review only' README.md || fail "README must clearly state the project is not installable"
grep -Fq 'must not be copied or redistributed' README.md || fail "README must retain upstream redistribution warning"
grep -Fq 'Do not publish an installable Release artifact until the test path is proven.' README.md || fail "README must retain release gate"
pass "project status, licensing caution, and release gate are documented"

grep -Fq 'Do not copy, modify, repackage, or redistribute upstream source' UPSTREAM_REVIEW.md || fail "upstream review is missing source/binary restrictions"
grep -Fq 'recovery/rollback' UPSTREAM_REVIEW.md || fail "upstream review is missing recovery test requirements"
pass "upstream review retains licensing and device-safety requirements"

grep -Fq 'no configuration is currently verified as supported' docs/SUPPORT_MATRIX.md || fail "support matrix must default to no verified support"
grep -Fq 'Poco F3 (Alioth)' docs/SUPPORT_MATRIX.md || fail "support matrix must record the intended target"
grep -Fq 'NOT TESTED' docs/SUPPORT_MATRIX.md || fail "support matrix must mark the target untested"
pass "support matrix defaults to unverified and identifies the target for testing"

grep -Fq 'Never invokes su or changes device state' scripts/probe-device.sh || fail "probe must document read-only behavior"
grep -Fq 'changes_made=false' scripts/probe-device.sh || fail "probe must report no changes"
grep -Fq 'state_changes_allowed=false' scripts/resolve-capabilities.sh || fail "resolver must block state changes"
grep -Fq 'plan_status=blocked' scripts/build-plan.sh || fail "plan builder must fail closed"
grep -Fq 'executable_commands=none' scripts/build-plan.sh || fail "plan builder must not emit runnable commands"
grep -Fq 'changes_made=false' scripts/build-plan.sh || fail "plan builder must report no changes"
pass "probe, resolver, and plan builder retain read-only safeguards"

if find . -type f \( -iname '*.apk' -o -iname '*.zip' \) -not -path './.git/*' -print -quit | grep -q .; then
  fail "unexpected APK/ZIP artifact found before an approved build pipeline"
fi
pass "no unverified APK/ZIP artifacts are present"

printf '\nProject validation passed. This is not a module build or device-compatibility test.\n'
