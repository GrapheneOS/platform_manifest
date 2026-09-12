#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
project_dir="$(cd -- "$script_dir/.." && pwd -P)"
# shellcheck source=../config/sovereign.env
source "$project_dir/config/sovereign.env"

usage() {
    cat <<'EOF'
Usage: check-host.sh [--pixel] [--path DIRECTORY]

Report whether a host meets the documented baseline build prerequisites.
--pixel also checks Node.js 24 LTS and Yarn for Pixel vendor extraction.
No packages or host settings are changed.
EOF
}

pixel=0
check_path='.'
while (($#)); do
    case "$1" in
        --pixel)
            pixel=1
            shift
            ;;
        --path)
            (($# >= 2)) || { printf 'error: --path needs a directory\n' >&2; exit 2; }
            check_path="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'error: unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

[[ -d "$check_path" ]] || { printf 'error: path is not a directory: %s\n' "$check_path" >&2; exit 2; }

failures=0
warnings=0
pass() { printf 'PASS  %s\n' "$*"; }
warn() { printf 'WARN  %s\n' "$*"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL  %s\n' "$*"; failures=$((failures + 1)); }

arch="$(uname -m)"
if [[ "$arch" == 'x86_64' ]]; then
    pass "architecture: $arch"
else
    fail "architecture is $arch; upstream requires an x86_64 Linux build environment"
fi

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    os_key="${ID:-unknown}:${VERSION_ID:-rolling}"
    case "$os_key" in
        debian:12|ubuntu:24.04|ubuntu:24.10|arch:*)
            pass "upstream-listed host OS: ${PRETTY_NAME:-$os_key}"
            ;;
        *)
            warn "${PRETTY_NAME:-$os_key} is not in the upstream supported-host list checked on 2026-09-12"
            ;;
    esac
else
    warn 'cannot identify host OS from /etc/os-release'
fi

if [[ -r /proc/meminfo ]]; then
    memory_kib="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
    memory_gib=$((memory_kib / 1024 / 1024))
    if ((memory_kib >= MIN_MEMORY_GIB * 1024 * 1024)); then
        pass "memory: ${memory_gib} GiB (minimum ${MIN_MEMORY_GIB} GiB)"
    else
        fail "memory: ${memory_gib} GiB; at least ${MIN_MEMORY_GIB} GiB is required"
    fi
else
    fail 'cannot read total memory from /proc/meminfo'
fi

available_kib="$(df -Pk -- "$check_path" | awk 'NR == 2 {print $4}')"
if [[ "$available_kib" =~ ^[0-9]+$ ]]; then
    available_gib=$((available_kib / 1024 / 1024))
    if ((available_kib >= MIN_FREE_GIB * 1024 * 1024)); then
        pass "free storage at $check_path: ${available_gib} GiB (planning floor ${MIN_FREE_GIB} GiB)"
    else
        fail "free storage at $check_path: ${available_gib} GiB; plan for at least ${MIN_FREE_GIB} GiB"
    fi
else
    fail "cannot determine free storage at $check_path"
fi

required_commands=(repo python3 git gpg ssh-keygen rsync unzip zip openssl diff hostname)
for command_name in "${required_commands[@]}"; do
    if command -v "$command_name" >/dev/null 2>&1; then
        pass "command: $command_name"
    else
        fail "missing command: $command_name"
    fi
done

for command_name in curl sha256sum; do
    if command -v "$command_name" >/dev/null 2>&1; then
        pass "recommended command: $command_name"
    else
        warn "missing recommended command: $command_name"
    fi
done

if ((pixel)); then
    if command -v node >/dev/null 2>&1; then
        node_version="$(node --version)"
        node_major="${node_version#v}"
        node_major="${node_major%%.*}"
        if [[ "$node_major" == '24' ]]; then
            pass "Pixel vendor dependency: Node.js $node_version"
        else
            fail "Pixel vendor extraction currently requires Node.js 24 LTS; found $node_version"
        fi
    else
        fail 'Pixel vendor extraction requires Node.js 24 LTS'
    fi

    if command -v yarn >/dev/null 2>&1; then
        pass 'Pixel vendor dependency: yarn'
    elif command -v yarnpkg >/dev/null 2>&1; then
        pass 'Pixel vendor dependency: yarnpkg'
    else
        fail 'Pixel vendor extraction requires yarn or yarnpkg'
    fi
fi

printf '\nResult: %d failure(s), %d warning(s).\n' "$failures" "$warnings"
if ((failures)); then
    printf 'Review https://grapheneos.org/build#build-dependencies before building.\n' >&2
    exit 1
fi
