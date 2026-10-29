# Solina-QuickSwitch support matrix

Status: **no configuration is currently verified as supported**. This file is a test-planning record, not a compatibility claim.

## Known target to investigate

| Device | Android | Root manager | Launcher and version | Result | Evidence |
|---|---|---|---|---|---|
| Poco F3 (Alioth) | Android 16 (reported target) | KernelSU (reported target; version not recorded here) | Not recorded | NOT TESTED | No on-device test report exists |

The row above identifies a proposed test target only. It does not mean the current project works on this device.

## Support status definitions

- **SUPPORTED** — exact combination has a reviewed test report covering install, Quickstep/Recents behavior, reboot persistence, rollback, upgrade, and uninstall; licensing and package provenance are cleared.
- **UNSUPPORTED** — a documented technical or policy blocker exists for this exact combination.
- **NOT TESTED** — evidence is incomplete or the required test suite has not been run. This is the default status.
- **BLOCKED** — testing or release is prohibited pending a required prerequisite, such as licensing, a recovery path, or missing baseline information.

## Evidence required before changing a row to SUPPORTED

1. Exact device model/codename and Android build fingerprint/API level.
2. Exact KernelSU version and relevant configuration.
3. Exact launcher package name and version, plus confirmation that it implements the required Quickstep integration.
4. The relevant platform/root-manager interface documentation and implementation review.
5. Baseline launcher/provider state captured without exposing secrets.
6. Test report for installation, no-op update, upgrade, failed apply, rollback, reboot, Recents gesture, overview, app switching, provider reset, and uninstall.
7. Confirmation that recovery works after a simulated failure.
8. Cleared source and third-party licenses, plus package-content provenance.

Do not infer support from root access, a successful build, a passing fixture test, or a package installing.

## Test report process

1. Start from [DEVICE_TEST_REPORT_TEMPLATE.md](DEVICE_TEST_REPORT_TEMPLATE.md).
2. Only after test authorization and a verified recovery method, save a separate completed report under `docs/test-reports/`, using a unique descriptive filename.
3. Mark unexecuted tests as NOT RUN or INCOMPLETE. Include only redacted evidence and do not include secrets or unnecessary device/account identifiers.
4. Submit the report for review before changing any support status. Do not add a completed report for a test that did not happen.

Until an evidence-backed report is reviewed, all combinations remain NOT TESTED and state-changing features remain disabled.
