# Upstream and Fork Maintenance

GrapheneOS is a security upstream, not a one-time code import. Patch latency and maintained-delta size are product security metrics.

## Remote and branch policy

```bash
git remote add upstream https://github.com/GrapheneOS/platform_manifest.git
git fetch --prune upstream
```

- `upstream/17` is GrapheneOS's moving Android 17 development line.
- `origin/17` mirrors it without custom commits.
- `origin/sovereign-17` contains the derivative's integration work.
- Releases will be tied to verified upstream release tags and immutable component revisions, not merely a moving branch name.

## Sync the pristine branch

```bash
git switch 17
git merge --ff-only upstream/17
git diff --exit-code upstream/17 17
git push origin 17
```

If `--ff-only` fails, stop. Do not resolve it by force-pushing or adding a merge commit; first determine why the supposedly pristine branch diverged.

## Integrate an upstream update

Perform intake on a temporary feature branch. Review manifest changes, sync the complete tree, build the emulator baseline, and run regression checks before merging into `sovereign-17`.

```bash
git switch sovereign-17
git switch -c intake/grapheneos-YYYYMMDD
git merge --no-ff 17
./scripts/validate-scaffold.sh
```

Security releases take priority over feature work. If the custom delta blocks prompt upstream intake, reduce or remove the delta.

## Fork one component

The manifest describes hundreds of repositories. Do not fork them all. When a real change is ready:

1. Identify the exact project `name`, `path`, remote, and revision in the resolved manifest.
2. Fork that repository with complete history and retain its upstream remote.
3. Create a matching integration branch, normally `sovereign-17` for development.
4. Add one `<remove-project>` and one replacement `<project>` entry to a reviewed local manifest.
5. Sync, verify the resolved URL and commit, build, and test rollback to the upstream project.
6. Record the fork, owner, purpose, upstream base, license, tests, and patch-latency commitment.

The inert template at `sovereign/local_manifests/sovereign.xml.example` defines the custom GitHub remote but intentionally overrides no project. The adjacent README shows the pattern without enabling a nonexistent fork.

## Release intake

For a release candidate:

- select the correct stable GrapheneOS tag for the target device;
- verify the tag as documented by GrapheneOS;
- resolve every project to a commit hash with `repo manifest -r`;
- archive the resolved manifest, tool versions, build metadata, and artifact hashes;
- confirm all component forks contain the required upstream security changes;
- sign only after build and review gates pass.

The source and build documentation at [grapheneos.org/source](https://grapheneos.org/source) and [grapheneos.org/build](https://grapheneos.org/build) should be reviewed on every cycle because supported targets and commands change.
