#!/usr/bin/env bash
# Read-only Android compatibility probe. Never invokes su or changes device state.
set -euo pipefail

usage() {
  printf 'Usage: %s [--fixture FILE]\n' "$0"
  printf 'Live mode only reads Android properties and package-manager availability.\n'
}

fail() { printf 'ERROR: %s\n' "$1" >&2; exit 2; }

mode=live
fixture=""
while (($#)); do
  case "$1" in
    --fixture)
      (($# >= 2)) || fail "--fixture requires a file"
      mode=fixture
      fixture=$2
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

api=""
manager="unknown"
pm_available="false"

if [[ "$mode" == fixture ]]; then
  [[ -f "$fixture" && -r "$fixture" ]] || fail "fixture is not a readable file"
  while IFS='=' read -r key value || [[ -n "${key:-}" ]]; do
    [[ -z "${key:-}" || "$key" == \#* ]] && continue
    [[ "$value" != *"="* ]] || fail "invalid fixture line for $key"
    case "$key" in
      android_api) api=$value ;;
      root_manager) manager=$value ;;
      package_manager_available) pm_available=$value ;;
      *) fail "unsupported fixture key: $key" ;;
    esac
  done < "$fixture"
else
  command -v getprop >/dev/null 2>&1 || fail "getprop is unavailable; run on Android or use --fixture for simulation"
  api=$(getprop ro.build.version.sdk 2>/dev/null || true)
  if command -v pm >/dev/null 2>&1 && pm path android >/dev/null 2>&1; then
    pm_available="true"
  fi
  # Deliberately do not infer root-manager identity from generic root access.
  if [[ -d /data/adb/ksu ]]; then manager="KernelSU"; fi
  if [[ -d /data/adb/ap ]]; then manager="APatch"; fi
  if [[ "$manager" == unknown && -d /data/adb/magisk ]]; then manager="Magisk"; fi
fi

[[ "$api" =~ ^[0-9]+$ ]] || fail "Android API level is missing or invalid"
[[ "$manager" == unknown || "$manager" == KernelSU || "$manager" == Magisk || "$manager" == APatch ]] || fail "unsupported root_manager value"
[[ "$pm_available" == true || "$pm_available" == false ]] || fail "package_manager_available must be true or false"

if (( api < 28 )); then compatibility="unsupported_api"
elif [[ "$pm_available" != true ]]; then compatibility="incomplete_probe"
elif [[ "$manager" == unknown ]]; then compatibility="needs_manual_review"
else compatibility="candidate_only"
fi

printf 'mode=%s\n' "$mode"
printf 'android_api=%s\n' "$api"
printf 'root_manager=%s\n' "$manager"
printf 'package_manager_available=%s\n' "$pm_available"
printf 'compatibility=%s\n' "$compatibility"
printf 'read_only=true\n'
printf 'changes_made=false\n'
printf 'note=This probe does not verify launcher support or prove module compatibility.\n'
