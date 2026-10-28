# Solina-QuickSwitch

Solina-QuickSwitch is the planned Solina-maintained project for research, compatibility work, and future improvements around Quickstep integration on rooted Android devices.

> **Development status: bootstrap only.** This branch currently contains project planning documentation, not an installable module. Do not install or distribute it as a working QuickSwitch replacement.

## Upstream project

The project being evaluated is [QuickSwitch by skittles9823](https://github.com/skittles9823/QuickSwitch). QuickSwitch is a systemless module intended to let supported third-party launchers use Android's Quickstep/Recents integration. It does not add Quickstep support to a launcher that does not implement it.

The upstream project and its contributors retain their applicable rights and attribution. No upstream code, APK, signing material, or branding is being represented here as original Solina work.

## Project goals

- Review source provenance, licenses, and redistribution permissions before importing or modifying upstream files.
- Keep development and validation on a test branch; do not make unverified changes to `main`.
- Verify installer, upgrade, provider-switching, reboot, and uninstall behavior before considering device testing.
- Test KernelSU compatibility and Android-version constraints on real supported devices.
- Add CI checks before producing any installable package.
- When packaging is implemented, provide clearly separated Test and Release artifacts. A Release artifact must not be presented as production-ready until validation passes.

## Current status

- [x] Create the `solina/bootstrap-test` development branch.
- [ ] Confirm applicable license and permission for source and bundled APK redistribution.
- [ ] Import or implement code through a legally permitted path.
- [ ] Add shell/static checks and Android compatibility checks.
- [ ] Build and validate a test package.
- [ ] Prepare a release workflow only after the test path is proven.

## Safety

Kernel modules and systemless overlays can affect launcher/Recents behavior and may leave a device needing recovery if installation or provider switching fails. Keep a recovery path available and do not install experimental builds on a primary device without a tested rollback plan.
