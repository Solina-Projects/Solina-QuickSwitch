# Solina-QuickSwitch

Solina-QuickSwitch is the planned Solina-maintained project for research, compatibility work, and future improvements around Quickstep integration on rooted Android devices.

> **Development status: planning/review only.** This repository does not yet contain an installable module. Do not install or distribute it as a working QuickSwitch replacement.

## Upstream project

The project being evaluated is [QuickSwitch by skittles9823](https://github.com/skittles9823/QuickSwitch). QuickSwitch is a systemless module intended to let supported third-party launchers use Android's Quickstep/Recents integration. It does not add Quickstep support to a launcher that does not implement it.

See [UPSTREAM_REVIEW.md](UPSTREAM_REVIEW.md) for the source and licensing review. No root-level upstream LICENSE file was found during the review, and licenses for the bundled APK and tools have not been established. Therefore, upstream code and binaries must not be copied or redistributed until permissions are clarified.

## Development policy

- Keep work on test branches; do not make unverified changes to `main`.
- Prefer written permission/licensing clarification or a clean-room implementation using independently authored code.
- Preserve appropriate attribution and all applicable third-party notices.
- Verify installer, upgrade, provider-switching, reboot, and uninstall behavior before device testing.
- Validate KernelSU compatibility and Android-version constraints on actual supported devices.
- Do not publish an installable Release artifact until the test path is proven.

## Current status

- [x] Create the `solina/bootstrap-test` development branch.
- [x] Review upstream README, module metadata, and installer structure.
- [x] Document licensing/redistribution uncertainty in [UPSTREAM_REVIEW.md](UPSTREAM_REVIEW.md).
- [x] Add a **Test** GitHub Actions workflow.
- [x] Add repository-policy validation and accidental artifact detection.
- [x] Draft the clean-room architecture, safety rules, test layers, and release gates in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
- [x] Add a read-only compatibility probe with simulated fixture tests.
- [x] Add a conservative capability resolver that blocks state changes for every currently unverified configuration.
- [ ] Verify licenses and permissions, or proceed with an independently authored clean-room implementation.
- [ ] Establish a documented launcher/Android/root-manager support matrix.
- [ ] Implement a non-mutating change-plan builder and recovery-plan output.
- [ ] Implement module/provider changes only after the support matrix and rollback method are verified.
- [ ] Build and validate a test package on a recoverable test device.
- [ ] Add the **Release** workflow only after the test path is proven.

## Read-only compatibility probe

On Android, run:

```bash
bash scripts/probe-device.sh
```

To use simulated fixture data on a computer:

```bash
bash scripts/probe-device.sh --fixture tests/fixtures/android16-kernelsu.properties
bash tests/test-probe.sh
```

The probe reads the Android API level, package-manager availability, and conventional root-manager marker paths. It never calls `su`, installs or removes packages, changes settings, switches providers, or reboots. Detection can be incomplete; `unknown` requires manual review. Fixture data is simulated, not evidence from a real device. The probe's `candidate_only` result is not a compatibility guarantee.

## Conservative capability resolver

The resolver consumes the probe's key/value output and returns a planning status without changing device state:

```bash
bash scripts/probe-device.sh | bash scripts/resolve-capabilities.sh
# Or evaluate a saved probe record:
bash scripts/resolve-capabilities.sh --probe path/to/probe-output.txt
bash tests/test-resolver.sh
```

Until an explicit launcher + Android API + root-manager support matrix is documented and tested, the resolver deliberately reports configurations as `untested`, `unsupported`, `blocked`, or `manual_review`. It always prints `state_changes_allowed=false`. This is a fail-closed safety scaffold, not proof that Quickstep will work.

## GitHub Actions

Only two workflows are intended:

1. **Test** — validates documentation and safeguards, then tests the probe and capability resolver using simulated fixtures.
2. **Release** — to be added only after the project has a legally distributable package and a tested recovery path.

A successful Test run is not a module build or a real-device compatibility test.

## Safety

Kernel modules and systemless overlays can affect launcher/Recents behavior and may leave a device needing recovery if installation or provider switching fails. Keep a recovery path available and do not install experimental builds on a primary device without a tested rollback plan.
