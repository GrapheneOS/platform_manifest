# Roadmap

The roadmap is gated by evidence rather than dates. A phase does not advance because its code exists; it advances when its exit criteria are repeatable and documented.

| Phase | Objective | Exit criteria | Status |
| --- | --- | --- | --- |
| 0. Control plane | Establish fork, branch contract, threat model, and safe workflow | Pristine `17`; dedicated `sovereign-17`; scaffold validation passes | Complete |
| 1. Baseline build | Reproduce an unmodified upstream-derived build | Resolved manifest archived; emulator boots; build metadata and hashes recorded twice | Next |
| 2. First bounded delta | Fork exactly one low-risk component for a real need | Small reviewed patch; tests; clean rollback; upstream rebase demonstrated | Planned |
| 3. Device lab | Move from emulator to a supported spare Pixel | Recovery rehearsed; vendor inputs recorded; userdebug test build boots; primary phone untouched | Planned |
| 4. Release integrity | Produce a signed `user` build and controlled updates | Offline key ceremony; verified boot; owned updater URL; testing → beta → stable rollout | Planned |
| 5. Sovereign apps and AI | Add sandboxed applications and local-first inference | Permission/data-flow review; exportable formats; model provenance; offline behavior tested | Planned |
| 6. Cross-device stack | Integrate mobile with the sovereign desktop and services | Compatible identity, backup, sync, audit, and recovery protocols without shared single points of failure | Planned |
| 7. Hardware research | Define and prototype increasingly controlled hardware | Written threat/requirements model; open interfaces; reproducible firmware where possible; supply-chain tests | Future |

## Phase 0 — control plane

- Verify the GitHub fork ancestry and upstream branch identity.
- Reserve `17` for upstream synchronization only.
- Establish change gates, threat model, provenance capture, key policy, and component-overlay pattern.
- Keep GrapheneOS-generated manifest inputs unchanged.

## Phase 1 — unmodified baseline

- Provision a supported x86-64 Linux build host.
- Sync `sovereign-17` and record the resolved manifest.
- Build `sdk_phone64_x86_64-cur-userdebug` with no component overrides.
- Boot the emulator, run basic platform checks, and preserve build logs and hashes.
- Repeat from a clean output directory. Investigate differences before customization.

## Phase 2 — first delta selection

Choose a change that satisfies all of these:

- It solves a current personal need, not a speculative product feature.
- It does not weaken verified boot, SELinux, sandboxing, exploit mitigations, or update speed.
- It can live in one component repository with a small patch.
- It has an objective test and a one-step rollback.
- It does not require release signing or a primary device to evaluate.

Branding or a small unprivileged application is safer than beginning with cryptography, the kernel, the boot chain, privileged services, or permission policy.

## Phase 3 and 4 — hardware and releases

Select an exact supported spare Pixel only after the emulator pipeline is repeatable. Record the model, codename, bootloader state, firmware baseline, recovery procedure, and support horizon. Development uses `userdebug`; a deployed build must be a signed `user` build with its own update service and tested rollback/recovery path.

## Long-term hardware path

Custom hardware begins with requirements and interfaces, not fabrication. Progression should be incremental: documented peripheral choices, repairable carrier boards, auditable boot firmware, an open compute module or development board, FPGA prototypes where useful, and only later a custom board or silicon effort. Cellular certification, radio firmware, secure boot roots, memory safety features, manufacturing test, and long-term component availability are first-class constraints.
