#!/usr/bin/env bash
# Non-mutating plan preview. This script never connects to or changes a device.
set -euo pipefail
fail() { printf 'ERROR: %s\n' "$1" >&2; exit 2; }
probe_file=""; state_file=""
while (($#)); do
  case "$1" in
    --probe) (($# >= 2)) || fail "--probe requires a file"; probe_file=$2; shift 2 ;;
    --state) (($# >= 2)) || fail "--state requires a file"; state_file=$2; shift 2 ;;
    -h|--help) printf 'Usage: %s --probe FILE --state FILE\n' "$0"; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done
[[ -n "$probe_file" && -r "$probe_file" ]] || fail "readable --probe file is required"
[[ -n "$state_file" && -r "$state_file" ]] || fail "readable --state file is required"

resolver_output=$(bash "$(dirname "$0")/resolve-capabilities.sh" --probe "$probe_file") || fail "capability resolver failed"
capability_status=""; state_changes_allowed=""; support_matrix=""
while IFS='=' read -r key value || [[ -n "${key:-}" ]]; do
  case "$key" in
    capability_status) capability_status=$value ;;
    state_changes_allowed) state_changes_allowed=$value ;;
    support_matrix) support_matrix=$value ;;
  esac
done <<< "$resolver_output"
[[ -n "$capability_status" && -n "$state_changes_allowed" && -n "$support_matrix" ]] || fail "resolver output incomplete"

launcher_known=""; provider_state=""; backup_available=""
while IFS='=' read -r key value || [[ -n "${key:-}" ]]; do
  [[ -z "${key:-}" || "$key" == \#* ]] && continue
  case "$key" in
    launcher_known) launcher_known=$value ;;
    provider_state) provider_state=$value ;;
    backup_available) backup_available=$value ;;
    *) fail "unexpected state field: $key" ;;
  esac
done < "$state_file"
[[ "$launcher_known" == true || "$launcher_known" == false ]] || fail "launcher_known must be true or false"
[[ "$provider_state" == known || "$provider_state" == unknown ]] || fail "provider_state must be known or unknown"
[[ "$backup_available" == true || "$backup_available" == false ]] || fail "backup_available must be true or false"

printf 'plan_version=1\n'
printf 'plan_status=blocked\n'
printf 'capability_status=%s\n' "$capability_status"
printf 'planned_actions=0\n'
printf 'state_changes_allowed=false\n'
printf 'executable_commands=none\n'
printf 'synthetic_launcher_state=%s\n' "$launcher_known"
printf 'synthetic_provider_state=%s\n' "$provider_state"
printf 'synthetic_backup_available=%s\n' "$backup_available"
printf 'block_reason=licensing, support matrix, and rollback are not yet verified\n'
printf 'required_before_review=license clearance; tested support matrix; verified recovery and rollback procedure\n'
printf 'recovery_checklist=confirm recovery path; record current launcher and provider; verify backup restoration; test removal and reboot recovery on a disposable device\n'
printf 'device_access=none\n'
printf 'changes_made=false\n'
