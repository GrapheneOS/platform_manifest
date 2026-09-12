#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
project_dir="$(cd -- "$script_dir/.." && pwd -P)"
# shellcheck source=../config/sovereign.env
source "$project_dir/config/sovereign.env"

usage() {
    cat <<EOF
Usage: init-source.sh [--sync] [--jobs NUMBER] DIRECTORY

Initialize an empty Android source directory with:
  manifest: $MANIFEST_URL
  branch:   $MANIFEST_BRANCH

The large source sync runs only when --sync is supplied.
EOF
}

sync_now=0
jobs="$DEFAULT_SYNC_JOBS"
destination=''

while (($#)); do
    case "$1" in
        --sync)
            sync_now=1
            shift
            ;;
        --jobs)
            (($# >= 2)) || { printf 'error: --jobs needs a positive integer\n' >&2; exit 2; }
            jobs="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --*)
            printf 'error: unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
        *)
            [[ -z "$destination" ]] || { printf 'error: provide exactly one destination\n' >&2; exit 2; }
            destination="$1"
            shift
            ;;
    esac
done

[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { printf 'error: jobs must be a positive integer\n' >&2; exit 2; }
[[ -n "$destination" ]] || { usage >&2; exit 2; }
command -v repo >/dev/null 2>&1 || { printf 'error: repo command not found\n' >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'error: git command not found\n' >&2; exit 1; }

if [[ -e "$destination" && ! -d "$destination" ]]; then
    printf 'error: destination exists and is not a directory: %s\n' "$destination" >&2
    exit 1
fi

mkdir -p -- "$destination"
if [[ -n "$(find "$destination" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    printf 'error: destination is not empty: %s\n' "$destination" >&2
    printf 'Use a new directory; this script never deletes an existing source tree.\n' >&2
    exit 1
fi

destination="$(cd -- "$destination" && pwd -P)"
printf 'Initializing %s in %s\n' "$SOVEREIGN_NAME" "$destination"
cd -- "$destination"
repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH"

if ((sync_now)); then
    printf 'Syncing the full source tree with %s jobs. This can take a long time.\n' "$jobs"
    repo sync -j"$jobs"
    printf 'Source sync completed.\n'
else
    printf 'Manifest initialized. Review it, then run:\n  cd %q\n  repo sync -j%s\n' "$destination" "$jobs"
fi
