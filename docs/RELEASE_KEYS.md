# Release Keys and Update Policy

No release keys should be generated during baseline bring-up. This document is a gate: key creation begins only after an exact spare device target, clean reproducible build, independent backup locations, owned updater endpoint, and recovery rehearsal exist.

## Why continuity matters

Android release keys protect far more than an update file. They participate in application identity, privileged trust relationships, verified boot, and installation continuity. GrapheneOS documents that the same per-device keys must be reused for later builds and that changing them requires flashing factory images again, which performs a factory reset.

Each supported device variant receives its own key set. Public test keys are acceptable only for unlocked, disposable development devices; they do not provide meaningful ownership of a locked verified-boot chain.

## Key classes

The current upstream process creates Android signing keys for release, platform, shared, media, network stack, Bluetooth, SDK sandbox, compatibility components, NFC, and other target-specific packages; an AVB key and public metadata; and an Ed25519 SSH key used to sign factory images. Follow the exact, current [GrapheneOS key-generation instructions](https://grapheneos.org/build#generating-release-signing-keys) when the gate is approved rather than copying an old command list from this repository.

## Required operating model

1. Generate keys on a dedicated offline signing system from trusted installation media.
2. Use strong passphrases and encrypted storage. Disable swap during signing, or use correctly configured encrypted ephemeral swap.
3. Keep the online build host and update host unable to read private keys.
4. Maintain multiple encrypted, verified backups under separate physical custody. Test restoration without exposing the production originals.
5. Inventory public-key fingerprints and bind them to device codename, creation ceremony, and first release.
6. Sign only reviewed target-files packages whose resolved manifests and hashes are archived.
7. Decrypt into temporary memory only for the signing operation, then verify cleanup.
8. Rehearse loss and compromise response before enrolling a device.

Do not assume multisignature or secret-sharing software is compatible with Android's expected key formats and GrapheneOS release scripts. Redundant custody is mandatory; a threshold scheme requires a separate, tested design before adoption.

## Updater isolation

A derivative signed with different keys cannot use GrapheneOS's official updater service. Before setting `OFFICIAL_BUILD=true`, change the Updater configuration to an endpoint controlled by this project and verify its signed metadata and channel behavior. Pointing a custom build at the official URL causes repeated downloads that cannot verify and abuses upstream infrastructure.

Use staged channels:

1. internal testing on dedicated devices;
2. beta after install and future-update testing;
3. stable only after beta evidence and recovery validation.

Preserve signed target-files packages for both full and delta updates. The update service is replaceable distribution infrastructure; the signing keys are the durable root of release identity.

## Prohibited repository content

Never commit private or encrypted production key files, passphrases, device backups, key-ceremony recordings that expose secrets, or wallet recovery material. Encrypted keys still create an offline attack target and do not belong in public Git hosting.
