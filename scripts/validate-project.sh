#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

[[ -f README.md ]] || fail "README.md is missing"
[[ -f UPSTREAM_REVIEW.md ]] || fail "UPSTREAM_REVIEW.md is missing"
[[ -f docs/ARCHITECTURE.md ]] || fail "architecture document is missing"
[[ -f scripts/probe-device.sh ]] || fail "read-only probe is missing"
[[ -f tests/test-probe.sh ]] || fail "probe tests are missing"
pass "required project documentation and probe files exist"

grep -Fq 'planning/review only' README.md || fail "README must clearly state the project is not installable"
grep -Fq 'must not be copied or redistributed' README.md || fail "README must retain the upstream redistribution warning"
grep -Fq 'Do not publish an installable Release artifact until the test path is proven.' README.md || fail "README must retain the release gate"
pass "project status, licensing caution, and release gate are documented"

grep -Fq 'Do not copy, modify, repackage, or redistribute upstream source' UPSTREAM_REVIEW.md || fail "upstream review is missing the source/binary restriction"
grep -Fq 'recovery/rollback' UPSTREAM_REVIEW.md || fail "upstream review is missing recovery test requirements"
pass "upstream review retains licensing and device-safety requirements"

grep -Fq 'Never invokes su or changes device state' scripts/probe-device.sh || fail "probe must document its read-only behavior"
grep -Fq 'changes_made=false' scripts/probe-device.sh || fail "probe must report that it made no changes"
pass "compatibility probe retains read-only safeguards"

if find . -type f \( -iname '*.apk' -o -iname '*.zip' \) -not -path './.git/*' -print -quit | grep -q .; then
  fail "unexpected APK/ZIP artifact found before the project has an approved build pipeline"
fi
pass "no unverified APK/ZIP artifacts are present"

printf '\nProject validation passed. This is a repository-policy check, not a module build or device-compatibility test.\n'
