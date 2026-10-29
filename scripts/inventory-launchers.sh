#!/usr/bin/env bash
# Read-only inventory of Android HOME activity candidates. Never invokes su or changes state.
set -euo pipefail

fail() { printf 'ERROR: %s\n' "$1" >&2; exit 2; }
usage() { printf 'Usage: %s [--fixture FILE]\n' "$0"; }
mode=live
fixture=""
while (($#)); do
  case "$1" in
    --fixture) (($# >= 2)) || fail "--fixture requires a file"; mode=fixture; fixture=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

declare -a packages=()
declare -A versions=()
if [[ "$mode" == fixture ]]; then
  [[ -r "$fixture" ]] || fail "fixture is not readable"
  while IFS='=' read -r key value || [[ -n "${key:-}" ]]; do
    [[ -z "${key:-}" || "$key" == \#* ]] && continue
    case "$key" in
      home_candidate)
        [[ "$value" =~ ^[A-Za-z0-9_]+([.][A-Za-z0-9_]+)+$ ]] || fail "invalid home_candidate package"
        packages+=("$value") ;;
      launcher_version)
        pkg="${value%%:*}"; ver="${value#*:}"
        [[ "$pkg" =~ ^[A-Za-z0-9_]+([.][A-Za-z0-9_]+)+$ && "$value" == *:* ]] || fail "invalid launcher_version entry"
        versions["$pkg"]="$ver" ;;
      *) fail "unsupported fixture key: $key" ;;
    esac
  done < "$fixture"
else
  command -v cmd >/dev/null 2>&1 || fail "cmd is unavailable; run on Android or use --fixture"
  command -v dumpsys >/dev/null 2>&1 || fail "dumpsys is unavailable; run on Android or use --fixture"
  result=$(cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null) || fail "Android package manager could not query HOME activities"
  while IFS= read -r line; do
    # Activity component lines normally use package.name/.Activity or package.name/package.name.Activity.
    component="${line%%[[:space:]]*}"
    if [[ "$component" == */* ]]; then
      pkg="${component%%/*}"
      [[ "$pkg" =~ ^[A-Za-z0-9_]+([.][A-Za-z0-9_]+)+$ ]] && packages+=("$pkg")
    fi
  done <<< "$result"
  if (("${#packages[@]}" == 0)); then
    # Some Android builds format query results differently; report unknown rather than guessing.
    printf 'mode=live\n'
    printf 'home_candidate_count=unknown\n'
    printf 'active_home=not_identified\n'
    printf 'quickstep_support=not_verified\n'
    printf 'read_only=true\nchanges_made=false\n'
    printf 'note=HOME query returned no parseable package names; inspect output manually.\n'
    exit 0
  fi
  mapfile -t packages < <(printf '%s\n' "${packages[@]}" | sort -u)
  for pkg in "${packages[@]}"; do
    ver=$(dumpsys package "$pkg" 2>/dev/null | sed -n 's/.*versionName=\([^ ]*\).*/\1/p' | head -n 1 || true)
    versions["$pkg"]="${ver:-unknown}"
  done
fi

mapfile -t packages < <(printf '%s\n' "${packages[@]}" | sed '/^$/d' | sort -u)
printf 'mode=%s\n' "$mode"
printf 'home_candidate_count=%s\n' "${#packages[@]}"
i=0
for pkg in "${packages[@]}"; do
  ((i+=1))
  printf 'home_candidate_%s_package=%s\n' "$i" "$pkg"
  printf 'home_candidate_%s_version=%s\n' "$i" "${versions[$pkg]:-unknown}"
done
printf 'active_home=not_identified\n'
printf 'quickstep_support=not_verified\n'
printf 'read_only=true\nchanges_made=false\n'
printf 'note=HOME candidates are not proof of the active launcher or Quickstep support.\n'
