# Contributing

Sovereign Mobile begins as a personal system, but every change should be reviewable as though another person must safely maintain it during an incident.

## Change flow

1. Never commit custom work directly to `17`.
2. Update `17` only by fast-forwarding from `GrapheneOS/platform_manifest`.
3. Create a narrowly scoped feature branch from `sovereign-17`.
4. State the user need, threat-model effect, upstream divergence, rollback path, and test evidence.
5. Run `./scripts/validate-scaffold.sh` and the relevant upstream tests.
6. Merge only after checking whether a configuration or application-layer solution could meet the need with less privileged code.

## Required evidence

A change proposal should answer:

- What concrete need does this solve?
- Which trust boundary or attack surface changes?
- Which upstream repository and revision is the base?
- How large is the maintained delta?
- What tests fail before and pass after the change?
- How is the change disabled or rolled back?
- Does it affect verified boot, SELinux policy, sandboxing, permissions, networking, cryptography, updates, or signing?
- Which licenses and notices apply?

Changes affecting the boot chain, SELinux enforcement, cryptography, release signing, the updater, or privileged services require a written design and a dedicated test device. “Works on my phone” is not sufficient evidence.

## Dependency and licensing rule

Fork only repositories that are actually modified. Preserve their complete histories, licenses, attribution, and notices. Do not add a project-wide license that implies relicensing of upstream work; licensing is evaluated per component before redistribution.

## Secret handling

Never commit credentials or key material. This includes Android signing keys, AVB keys, SSH release keys, keystores, wallet material, API tokens, device backups, and recovery codes. `.gitignore` is only a guardrail, not a secret-management system.
