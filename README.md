# Sovereign Mobile

Sovereign Mobile is a personal, security-first mobile operating-system program derived from GrapheneOS. This repository is the manifest control plane for that work; it is not yet a distinct operating system or a release channel.

> **Pre-alpha:** no OS source changes, release signing keys, update service, or installable images exist yet. Do not use this work on a primary phone or for protecting irreplaceable secrets.

This project is independent and is not an official GrapheneOS project or release. It preserves upstream notices and will use its own identity before distributing binaries.

## Branch contract

| Branch | Purpose | Allowed changes |
| --- | --- | --- |
| `17` | Pristine tracking branch for `GrapheneOS/platform_manifest` | Fast-forward upstream sync only |
| `sovereign-17` | Integration branch for Sovereign Mobile | Reviewed project documentation, manifest overlays, and pinned component forks |
| Feature branches | One bounded experiment or component change | Changes intended for review into `sovereign-17` |

The upstream-generated `default.xml` and `config.yml` remain unchanged until an unmodified build has been reproduced and a component override is actually required.

## First milestone

The first milestone is intentionally plain: sync this fork, build the unmodified GrapheneOS development tree for the emulator, boot it, and record the exact resolved source manifest. Only then should the project fork its first component.

1. Use a dedicated x86-64 Linux build host with sufficient memory and storage.
2. Clone this branch and inspect the plan and threat model.
3. Run the host preflight check.
4. Initialize and sync the source tree from this fork.
5. Build and boot the emulator baseline.
6. Record hashes and the resolved manifest before introducing a delta.

```bash
git clone --branch sovereign-17 https://github.com/samsam380/platform_manifest.git
cd platform_manifest
./scripts/check-host.sh --path ..
./scripts/init-source.sh --sync ../sovereign-mobile-17
```

The sync is large. GrapheneOS currently documents at least 32 GiB memory, 136 GiB for a standard source sync plus 100 GiB of additional free space for a typical multi-architecture OS build. Read [`docs/BUILD.md`](docs/BUILD.md) before starting.

## Non-negotiable engineering principles

- Preserve verified boot, hardware-backed security, application sandboxing, exploit mitigations, and rapid security updates.
- Keep the custom delta small, reviewable, reversible, and continuously rebased on upstream security work.
- Pin and record every release input. A successful build without provenance is not a reproducible release.
- Own release keys and update infrastructure before enabling a production updater.
- Never place private signing keys, wallet seeds, recovery phrases, or other root secrets in this repository or on a general-purpose phone.
- Treat closed firmware, cellular infrastructure, fabrication, Git hosting, and upstream code as explicit dependencies—not as sovereignty already achieved.

## Project map

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — layers, trust boundaries, and repository strategy
- [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md) — assets, adversaries, assumptions, and limits
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — staged path from baseline build to future hardware
- [`docs/BUILD.md`](docs/BUILD.md) — first reproducible-build path
- [`docs/RELEASE_KEYS.md`](docs/RELEASE_KEYS.md) — key and update-channel policy
- [`docs/UPSTREAM.md`](docs/UPSTREAM.md) — upstream intake and component-fork workflow
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — change gates and review evidence

GrapheneOS's [build guide](https://grapheneos.org/build) remains authoritative for its fast-moving build commands and supported targets.
