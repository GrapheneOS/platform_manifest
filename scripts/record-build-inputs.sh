#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage: record-build-inputs.sh [OUTPUT_DIRECTORY]

Run from the root of a fully synced Android source tree. The default output is
build-metadata/YYYYMMDDTHHMMSSZ. Existing or non-empty output is never replaced.
EOF
}

if (($# > 1)); then
    usage >&2
    exit 2
fi
if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
    usage
    exit 0
fi

[[ -d .repo/manifests ]] || {
    printf 'error: run this script from the Android source-tree root\n' >&2
    exit 1
}
command -v repo >/dev/null 2>&1 || { printf 'error: repo command not found\n' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { printf 'error: sha256sum not found\n' >&2; exit 1; }

captured_at="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="${1:-build-metadata/$captured_at}"
if [[ -e "$output_dir" && ! -d "$output_dir" ]]; then
    printf 'error: output exists and is not a directory: %s\n' "$output_dir" >&2
    exit 1
fi
mkdir -p -- "$output_dir"
if [[ -n "$(find "$output_dir" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    printf 'error: output directory is not empty: %s\n' "$output_dir" >&2
    exit 1
fi

resolved_manifest="$output_dir/resolved-manifest.xml"
repo manifest -r -o "$resolved_manifest"
sha256sum "$resolved_manifest" > "$output_dir/SHA256SUMS"

manifest_commit="$(git -C .repo/manifests rev-parse HEAD)"
manifest_branch="$(git -C .repo/manifests symbolic-ref --quiet --short HEAD || printf 'detached')"
repo_version="$(repo version 2>&1 | head -n 1)"

{
    printf 'captured_at_utc=%q\n' "$captured_at"
    printf 'manifest_branch=%q\n' "$manifest_branch"
    printf 'manifest_commit=%q\n' "$manifest_commit"
    printf 'repo_version=%q\n' "$repo_version"
    printf 'host_kernel=%q\n' "$(uname -srmo)"
    printf 'build_target=%q\n' "${TARGET_PRODUCT:-not-selected}"
    printf 'build_variant=%q\n' "${TARGET_BUILD_VARIANT:-not-selected}"
    printf 'build_datetime=%q\n' "${BUILD_DATETIME:-not-set}"
    printf 'build_number=%q\n' "${BUILD_NUMBER:-not-set}"
} > "$output_dir/build-inputs.env"

if [[ -f out/build_date.txt ]]; then
    cp -- out/build_date.txt "$output_dir/"
fi
if [[ -f out/build_number.txt ]]; then
    cp -- out/build_number.txt "$output_dir/"
fi

printf 'Recorded build inputs in %s\n' "$output_dir"
printf 'Keep this directory with the corresponding build artifacts and logs.\n'
