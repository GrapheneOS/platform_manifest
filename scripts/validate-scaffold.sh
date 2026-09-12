#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
project_dir="$(cd -- "$script_dir/.." && pwd -P)"
cd -- "$project_dir"
# shellcheck source=../config/sovereign.env
source config/sovereign.env

failures=0
pass() { printf 'PASS  %s\n' "$*"; }
warn() { printf 'WARN  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*"; failures=$((failures + 1)); }

while IFS= read -r -d '' script; do
    if bash -n "$script"; then
        pass "bash syntax: $script"
    else
        fail "bash syntax: $script"
    fi
done < <(find scripts -type f -name '*.sh' -print0 | sort -z)

if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck scripts/*.sh; then
        pass 'ShellCheck'
    else
        fail 'ShellCheck'
    fi
else
    warn 'ShellCheck not installed; bash syntax was still checked'
fi

if python3 - sovereign/local_manifests/sovereign.xml.example <<'PY'
import sys
import xml.etree.ElementTree as ET

for path in sys.argv[1:]:
    root = ET.parse(path).getroot()
    if root.tag != "manifest":
        raise SystemExit(f"{path}: root element must be <manifest>")
PY
then
    pass 'local manifest XML'
else
    fail 'local manifest XML'
fi

if bash -u -c 'source config/sovereign.env; [[ $MANIFEST_BRANCH == sovereign-17 && $UPSTREAM_BRANCH == 17 ]]'; then
    pass 'bootstrap configuration'
else
    fail 'bootstrap configuration'
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git diff --check && git diff --cached --check; then
        pass 'Git whitespace check'
    else
        fail 'Git whitespace check'
    fi

    base_ref="${BASE_REF:-$UPSTREAM_BASE_COMMIT}"
    if git rev-parse --verify --quiet "$base_ref^{commit}" >/dev/null; then
        protected=(default.xml config.yml GLOBAL-PREUPLOAD.cfg COPPERHEAD-NOTICE)
        if git diff --quiet "$base_ref" -- "${protected[@]}"; then
            pass "protected upstream files match $base_ref"
        else
            fail "protected upstream files differ from $base_ref"
        fi
    else
        warn "cannot verify protected files because $base_ref is unavailable"
    fi
fi

key_pattern='(\.pem|\.pk8|\.p12|\.jks|\.keystore|(^|/)id_ed25519(\.pub)?$|(^|/)keys/)'
key_files="$(find . -path './.git' -prune -o -type f -print | awk -v pattern="$key_pattern" '$0 ~ pattern')"
if [[ -z "$key_files" ]]; then
    pass 'no key-shaped files detected'
else
    printf '%s\n' "$key_files" >&2
    fail 'key-shaped files detected; inspect before committing'
fi

if ((failures)); then
    printf '\nValidation failed with %d error(s).\n' "$failures" >&2
    exit 1
fi
printf '\nScaffold validation passed.\n'
