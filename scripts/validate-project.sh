#!/usr/bin/env bash
set -euo pipefail

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

for path in README.md UPSTREAM_REVIEW.md docs/ARCHITECTURE.md scripts/probe-device.sh scripts/resolve-capabilities.sh tests/test-probe.sh tests/test-resolver.sh; do
  [[ -f "$path" ]] || fail "required project file is missing: $path"
done
pass "required documentation, probe, resolver, and test files exist"

grep -Fq 'planning/review only' README.md || fail "README must clearly state the project is not installable"
grep -Fq 'must not be copied or redistributed' README.md || fail "README must retain upstream redistribution warning"
grep -Fq 'Do not publish an installable Release artifact until the test path is proven.' README.md || fail "README must retain release gate"
pass "project status, licensing caution, and release gate are documented"

grep -Fq 'Do not copy, modify, repackage, or redistribute upstream source' UPSTREAM_REVIEW.md || fail "upstream review is missing source/binary restrictions"
grep -Fq 'recovery/rollback' UPSTREAM_REVIEW.md || fail "upstream review is missing recovery test requirements"
pass "upstream review retains licensing and device-safety requirements"

grep -Fq 'Never invokes su or changes device state' scripts/probe-device.sh || fail "probe must document read-only behavior"
grep -Fq 'changes_made=false' scripts/probe-device.sh || fail "probe must report no changes"
grep -Fq 'state_changes_allowed=false' scripts/resolve-capabilities.sh || fail "resolver must block state changes"
pass "probe and resolver retain read-only safeguards"

if find . -type f \( -iname '*.apk' -o -iname '*.zip' \) -not -path './.git/*' -print -quit | grep -q .; then
  fail "unexpected APK/ZIP artifact found before an approved build pipeline"
fi
pass "no unverified APK/ZIP artifacts are present"

printf '\nProject validation passed. This is not a module build or device-compatibility test.\n'
