# Threat Model

## Scope

This threat model covers the manifest, build and signing process, future update service, installed OS, and operator workflow. It will be revised whenever a new privileged component, network service, hardware target, or distribution channel is introduced.

## Assets

- Integrity and confidentiality of user data
- Integrity of the boot chain, OS images, and update metadata
- Release signing and Android Verified Boot private keys
- Reproducible source and build provenance
- Recovery access and the ability to return to a known-good release
- The operator's identity, location history, communications, and authentication tokens
- High-value secrets kept outside the phone, including wallet recovery material

## Adversaries and failure modes

| Threat | Representative path | Primary controls |
| --- | --- | --- |
| Remote attacker | Browser, media, messaging, radio, or kernel vulnerability | Rapid upstream updates, exploit mitigations, sandboxing, least privilege |
| Malicious application | Permission abuse, IPC attack, accessibility abuse, data exfiltration | App sandbox, profiles, permission discipline, network controls, minimal app set |
| Supply-chain attacker | Compromised Git account, dependency, build host, prebuilt, or update server | Pinned revisions, signature checks, reproducible records, two-person review where possible, offline signing |
| Lost or stolen device | Offline extraction, shoulder surfing, coercion | Strong unlock secret, hardware-backed encryption, short exposure window, remote-account recovery planning |
| Rollback or counterfeit update | Old vulnerable image or forged channel metadata | Verified boot, rollback protection, stable signing-key continuity, owned update endpoint |
| Operator error | Wrong target, leaked key, updater pointed at upstream, untested image on primary device | Checklists, safe defaults, spare device, staged rollout, rehearsed recovery |
| Availability failure | Broken build, key loss, hosting outage, upstream disappearance | Multiple verified backups, source mirrors, full packages, recovery images, documented rebuild path |

## Security invariants

A change is rejected if it knowingly breaks one of these without a new, explicitly approved threat model:

- Verified boot remains meaningful; production devices are not locked to public test keys.
- SELinux stays enforcing and application sandbox boundaries are not bypassed for convenience.
- Debug variants are not treated as production releases.
- Security updates are integrated quickly enough that maintaining the fork does not create a chronic patch gap.
- Release key continuity and rollback behavior are understood before a device is enrolled.
- The updater never points a differently signed derivative at GrapheneOS infrastructure.
- Build and release inputs can be traced to immutable revisions.
- Private keys and irreplaceable recovery secrets are not present on general-purpose online systems.

## Explicit assumptions

- The selected device remains supported by GrapheneOS and receives complete firmware, kernel, and device-specific security updates.
- Hardware roots of trust, boot ROM, secure elements, and vendor-signed firmware behave as documented.
- Upstream GrapheneOS and AOSP code are dependencies that require ongoing monitoring and review.
- The operator can maintain a dedicated build environment and a separate signing boundary.
- A source-available build can still contain necessary proprietary firmware and vendor files.

## Out of scope for the first phases

- Defeating a hardware implant, malicious fabrication facility, or compromised boot ROM
- Making cellular networks, the baseband, satellites, DNS, or internet transit sovereign
- Guaranteeing secrecy after a device is unlocked under observation or coercion
- Claiming anonymous use merely because the OS is custom
- Replacing cold, redundant custody for high-value cryptographic root secrets
- Supporting arbitrary Android hardware without current firmware, kernel, verified-boot, and security-feature coverage

## Compromise response

A suspected release-key, build-host, manifest, or update-channel compromise stops distribution immediately. Preserve logs and artifacts, publish the affected revision range, isolate credentials, determine whether key continuity can be trusted, and require a clean rebuild from independently verified inputs. If a signing key is lost or compromised, assume devices may require a factory-image migration and data reset; do not improvise key rotation on enrolled devices.
