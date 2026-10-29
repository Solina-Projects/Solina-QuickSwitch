# Solina-QuickSwitch support matrix

Status: **no configuration is currently verified as supported**. This file is a test-planning record, not a compatibility claim.

## Known target to investigate

| Device | Android | Root manager | Launcher and version | Result | Evidence |
|---|---|---|---|---|---|
| Poco F3 (Alioth) | Android 17 (device reports release `17`, API 37) | KernelSU `ksud 3.2.5` | Nova Launcher `8.9.6` (version code `89600`), package `com.teslacoilsw.launcher` | NOT TESTED | Read-only on-device commands shared on 2026-10-29; no functional Quickstep/Recents test report |

### Additional on-device inventory findings

The following were observed from commands executed by the user on the target phone with root access. They are inventory facts, not a compatibility result:

- HOME activity candidates included:
  - `com.android.launcher3/.uioverrides.QuickstepLauncher`
  - `com.solina.launcher.debug/app.lawnchair.LawnchairLauncher`
  - `com.teslacoilsw.launcher/.NovaLauncher`
  - `com.android.settings/.FallbackHome`
- `cmd package resolve-activity --user 0 ... HOME` resolved to `com.teslacoilsw.launcher/.NovaLauncher`, identifying Nova Launcher as the current default HOME activity at the time of the check.
- Installed Solina Launcher debug package reports `versionName=16.Dev.(#60)`.
- `getprop ro.build.version.release` returned `17`; `getprop ro.build.version.sdk` returned `37`.
- `su -c id` confirmed root command execution as `uid=0(root)` under KernelSU.
- The presence of `com.android.launcher3/.uioverrides.QuickstepLauncher` does not prove that Nova Launcher or Solina Launcher integrates with Quickstep, nor that Solina-QuickSwitch is compatible.
- Android build fingerprint and actual Recents/Quickstep behavior remain unverified. `su -c 'ksud -V'` returned `ksud 3.2.5`; package inspection returned Nova `versionName=89600 (8.9.6)`. These are inventory facts only.

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
