# First Build Path

This runbook creates the first unmodified development baseline. It intentionally stops before release signing, updater enablement, or flashing a physical phone.

GrapheneOS's [official build guide](https://grapheneos.org/build) is authoritative. The requirements and commands below were checked against it on 2026-09-12 and will age; review upstream before every build cycle.

## 1. Prepare a dedicated host

The current upstream guide lists Arch Linux, Debian 12, Ubuntu 24.10, and Ubuntu 24.04 LTS as supported x86-64 build hosts. It specifies:

- at least 32 GiB memory;
- at least 136 GiB storage for a normal source sync, or 90 GiB for a lightweight sync;
- at least 100 GiB of additional free storage for a typical full multi-architecture OS build;
- `repo`, Python 3, Git, GnuPG, OpenSSH, `rsync`, `unzip`, `zip`, OpenSSL, `diff`, `hostname`, fonts/fontconfig, and other host packages described upstream;
- Node.js 24 LTS and Yarn when extracting Pixel vendor files.

Use fast local SSD storage and leave margin beyond the documented minimum. On the cloned manifest scaffold, run:

```bash
./scripts/check-host.sh --path /path/to/build-volume
```

The script reports prerequisites; it does not install packages or alter the host.

## 2. Initialize from the fork

From a clone of `sovereign-17`:

```bash
./scripts/init-source.sh /path/to/sovereign-mobile-17
cd /path/to/sovereign-mobile-17
repo sync -j8
```

Or pass `--sync` to make the script perform the large sync after initialization. It runs the equivalent of:

```bash
repo init -u https://github.com/samsam380/platform_manifest.git -b sovereign-17
```

An interrupted `repo sync` can normally be run again; do not discard a partial tree merely because the network failed.

## 3. Confirm the clean baseline

Before building, confirm that no component override is active and that the protected upstream manifest inputs are unchanged:

```bash
git -C .repo/manifests diff --exit-code \
  75ae9fb65fa78389ea4a4d5f21aa1ba4be88e287 HEAD -- \
  default.xml config.yml GLOBAL-PREUPLOAD.cfg COPPERHEAD-NOTICE
find .repo/local_manifests -maxdepth 1 -type f -print 2>/dev/null || true
```

The second command should print nothing for the first baseline. Record the resolved inputs before the build:

```bash
.repo/manifests/scripts/record-build-inputs.sh
```

Keep the generated `build-metadata/` directory with the build artifacts, not in this manifest repository.

## 4. Build the emulator baseline

Upstream recommends the `sdk_phone64_x86_64` emulator target in `userdebug` or `eng` form for most development. Use Bash or Zsh:

```bash
source build/envsetup.sh
lunch sdk_phone64_x86_64-cur-userdebug
m
```

The emulator is a development target; it does not provide every production hardware security feature or full device-specific firmware coverage. Its value here is a low-risk test of source, build, boot, and provenance.

## 5. Acceptance record

Do not call the baseline complete until the record includes:

- manifest branch and commit;
- resolved manifest with immutable project revisions and its SHA-256 digest;
- host OS, kernel, CPU architecture, memory, and free-space report;
- exact lunch target and build command;
- complete build log and exit status;
- hashes of the tested artifacts;
- proof that the emulator booted and basic networking, storage, and app launch worked;
- confirmation that no Sovereign component override or private signing key was present.

Repeat from a clean `out/` directory before accepting the toolchain as reproducible. Byte-for-byte comparison may require matching `BUILD_DATETIME`, `BUILD_NUMBER`, and signing inputs as described by upstream.

## Physical-device gate

A Pixel build requires an exact supported codename, vendor extraction with `adevtool`, generation-specific build targets, and a recovery plan. Select a spare device first, then follow the current upstream target instructions. Do not flash a primary phone, lock a bootloader around public test keys, or generate production keys as an experiment.

For a production derivative, start from a verified stable GrapheneOS release tag rather than treating the moving `17` branch as a release, use a signed `user` build, and complete [`RELEASE_KEYS.md`](RELEASE_KEYS.md).
