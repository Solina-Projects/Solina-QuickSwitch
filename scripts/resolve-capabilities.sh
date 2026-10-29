#!/usr/bin/env bash
# Pure, read-only capability resolver. It evaluates probe output; it never touches Android.
set -euo pipefail

fail() { printf 'ERROR: %s\n' "$1" >&2; exit 2; }
usage() { printf 'Usage: %s [--probe FILE]\n' "$0"; }

mode=stdin
probe_file=""
while (($#)); do
  case "$1" in
    --probe)
      (($# >= 2)) || fail "--probe requires a file"
      mode=file; probe_file=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

if [[ "$mode" == file ]]; then
  [[ -f "$probe_file" && -r "$probe_file" ]] || fail "probe file is not readable"
  input=$(cat -- "$probe_file")
else
  input=$(cat)
fi

api=""
manager="unknown"
pm_available="false"
probe_compatibility=""
while IFS='=' read -r key value || [[ -n "${key:-}" ]]; do
  [[ -z "${key:-}" || "$key" == \#* ]] && continue
  case "$key" in
    android_api) api=$value ;;
    root_manager) manager=$value ;;
    package_manager_available) pm_available=$value ;;
    compatibility) probe_compatibility=$value ;;
    mode|read_only|changes_made|note) : ;;
    *) fail "unexpected probe field: $key" ;;
  esac
done <<< "$input"

[[ "$api" =~ ^[0-9]+$ ]] || fail "missing or invalid android_api"
[[ "$manager" == unknown || "$manager" == KernelSU || "$manager" == Magisk || "$manager" == APatch ]] || fail "invalid root_manager"
[[ "$pm_available" == true || "$pm_available" == false ]] || fail "invalid package_manager_available"

if (( api < 28 )); then
  status="unsupported"
  reason="Android API below 28"
elif [[ "$pm_available" != true ]]; then
  status="blocked"
  reason="package manager unavailable"
elif [[ "$manager" == unknown ]]; then
  status="manual_review"
  reason="root manager could not be identified"
else
  # No verified launcher/version support matrix exists yet. Never label this supported.
  status="untested"
  reason="no verified launcher and root-manager support matrix"
fi

printf 'resolver_version=1\n'
printf 'capability_status=%s\n' "$status"
printf 'reason=%s\n' "$reason"
printf 'state_changes_allowed=false\n'
printf 'support_matrix=missing\n'
printf 'note=This is a conservative planning result, not a compatibility guarantee.\n'
