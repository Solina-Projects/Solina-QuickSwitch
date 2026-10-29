#!/usr/bin/env bash
set -euo pipefail

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

for path in README.md UPSTREAM_REVIEW.md docs/ARCHITECTURE.md docs/SUPPORT_MATRIX.md docs/DEVICE_TEST_REPORT_TEMPLATE.md scripts/probe-device.sh scripts/inventory-launchers.sh scripts/resolve-capabilities.sh scripts/build-plan.sh tests/test-probe.sh tests/test-launcher-inventory.sh tests/test-resolver.sh tests/test-plan.sh tests/fixtures/home-candidates.properties tests/fixtures/home-invalid.properties tests/fixtures/state-launcher-known.properties tests/fixtures/state-missing-provider.properties tests/fixtures/state-malformed.properties; do
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
grep -Fq 'docs/test-reports/' docs/SUPPORT_MATRIX.md || fail "support matrix must require separate test reports"
pass "support matrix defaults to unverified and identifies the target for testing"

grep -Fq 'experimental, debug-only' docs/SOLINA_LAUNCHER_INTEGRATION.md || fail "launcher integration audit must identify Quickstep build as experimental/debug-only"
grep -Fq 'NOT TESTED' docs/SOLINA_LAUNCHER_INTEGRATION.md || fail "launcher integration audit must not imply runtime compatibility"
grep -Fq 'API 37' docs/SOLINA_LAUNCHER_INTEGRATION.md || fail "launcher integration audit must explicitly cover API 37"
grep -Fq 'does not yet contain an installable module' README.md || fail "README must distinguish launcher APK build evidence from a QuickSwitch module"
pass "launcher integration evidence remains explicitly experimental, API 37 runtime-unverified, and not an installable module"

grep -Fq 'Do not use this template as permission to install or modify anything' docs/DEVICE_TEST_REPORT_TEMPLATE.md || fail "device report template must warn against unauthorized changes"
grep -Fq 'build fingerprint' docs/DEVICE_TEST_REPORT_TEMPLATE.md || fail "device report template is missing build identification"
grep -Fq 'Root manager exact version' docs/DEVICE_TEST_REPORT_TEMPLATE.md || fail "device report template is missing root-manager version capture"
grep -Fq 'Rollback to baseline' docs/DEVICE_TEST_REPORT_TEMPLATE.md || fail "device report template is missing rollback coverage"
grep -Fq 'Recovery after simulated failure' docs/DEVICE_TEST_REPORT_TEMPLATE.md || fail "device report template is missing recovery coverage"
grep -Fq 'Provider reset / restore' docs/DEVICE_TEST_REPORT_TEMPLATE.md || fail "device report template is missing provider reset coverage"
grep -Fq 'Overall result' docs/DEVICE_TEST_REPORT_TEMPLATE.md || fail "device report template is missing final assessment"
pass "device report template includes identity, recovery, required tests, and assessment gates"

grep -Fq 'Never invokes su or changes device state' scripts/probe-device.sh || fail "probe must document read-only behavior"
grep -Fq 'changes_made=false' scripts/probe-device.sh || fail "probe must report no changes"
grep -Fq 'Never invokes su or changes state' scripts/inventory-launchers.sh || fail "launcher inventory must document read-only behavior"
grep -Fq 'active_home=not_identified' scripts/inventory-launchers.sh || fail "launcher inventory must not guess active launcher"
grep -Fq 'quickstep_support=not_verified' scripts/inventory-launchers.sh || fail "launcher inventory must not infer Quickstep support"
grep -Fq 'state_changes_allowed=false' scripts/resolve-capabilities.sh || fail "resolver must block state changes"
grep -Fq 'plan_status=blocked' scripts/build-plan.sh || fail "plan builder must fail closed"
grep -Fq 'executable_commands=none' scripts/build-plan.sh || fail "plan builder must not emit runnable commands"
grep -Fq 'changes_made=false' scripts/build-plan.sh || fail "plan builder must report no changes"
pass "probe, launcher inventory, resolver, and plan builder retain safety safeguards"

if find . -type f \( -iname '*.apk' -o -iname '*.zip' \) -not -path './.git/*' -print -quit | grep -q .; then
  fail "unexpected APK/ZIP artifact found before an approved build pipeline"
fi
pass "no unverified APK/ZIP artifacts are present"

printf '\nProject validation passed. This is not a module build or device-compatibility test.\n'
