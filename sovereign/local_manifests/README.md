# Local Manifest Overlays

The first baseline uses no local manifest. `sovereign.xml.example` is intentionally inert: it declares the `samsam380` GitHub remote but does not replace any GrapheneOS project.

When the first component fork actually exists, copy a reviewed overlay into the Android source tree:

```bash
mkdir -p .repo/local_manifests
cp .repo/manifests/sovereign/local_manifests/sovereign.xml.example \
  .repo/local_manifests/sovereign.xml
```

Then add an override using the exact project name and path from `repo manifest -r`. For example, only after a real `platform_packages_apps_Settings` fork and branch exist:

```xml
<remove-project name="platform_packages_apps_Settings" />
<project
    name="platform_packages_apps_Settings"
    path="packages/apps/Settings"
    remote="sovereign"
    revision="refs/heads/sovereign-17" />
```

Run `repo sync`, inspect the checked-out remote and commit, and capture a new resolved manifest. Never activate a placeholder project or silently fall back to an unintended remote.
