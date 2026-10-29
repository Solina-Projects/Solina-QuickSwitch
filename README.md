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
- [x] Document the licensing/redistribution uncertainty in [UPSTREAM_REVIEW.md](UPSTREAM_REVIEW.md).
- [x] Add a **Test** GitHub Actions workflow for repository-policy checks.
- [x] Add a local validation script for project status, licensing safeguards, and accidental artifact detection.
- [ ] Confirm applicable licenses and permissions, or proceed with a clean-room implementation.
- [ ] Implement module and provider-switching functionality.
- [ ] Add implementation-level static checks and automated tests.
- [ ] Build and validate a test package on supported devices.
- [ ] Add the **Release** workflow only after the test path is proven.

## GitHub Actions

Only two workflows are intended for this project:

1. **Test** — checks repository documentation and safety gates on pushes, pull requests, and manual dispatch.
2. **Release** — to be added later, only after there is a tested and legally distributable package.

The current Test workflow is deliberately not a build workflow. A green result does **not** mean that an installable module exists or that Quickstep integration works on a phone.

## Safety

Kernel modules and systemless overlays can affect launcher/Recents behavior and may leave a device needing recovery if installation or provider switching fails. Keep a recovery path available and do not install experimental builds on a primary device without a tested rollback plan.
