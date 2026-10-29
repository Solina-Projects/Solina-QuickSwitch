# Solina-QuickSwitch support matrix

Status: **no configuration is currently verified as supported**. This file is a test-planning record, not a compatibility claim.

## Intended target: Solina Launcher

Solina Launcher is the intended launcher for this project; its renamed canonical repository is [Solina-Projects/Solina-Launcher](https://github.com/Solina-Projects/Solina-Launcher). The current reviewed `main` source snapshot is `cbd58321761781fcdaea5e9e517ef99875ed5ed4`, but the installed `16.Dev.(#60)` APK has not been mapped to that exact commit. **Two important blockers:** current `build.gradle` configures Quickstep for SDK 35–36 (`quickstepMaxSdk = "36"`), whereas the phone reports API 37; additionally, the current `androidComponents` allowlist and CI workflow build only `WithoutQuickstep` variants. The current CI APK artifacts therefore do not provide Quickstep integration. Do not enable or install a QuickSwitch module on this setup until a deliberate Quickstep-enabled build and reviewed API 37 compatibility implementation exist. The repository documents a build task named `assembleLawnWithQuickstepGithubDebug`, and its source tree contains Launcher3/Quickstep compatibility code. This is source-level evidence that a Quickstep build path exists, **not** proof that the installed package is correctly integrated with the device's Android 17 Recents implementation. See [SOLINA_LAUNCHER_INTEGRATION.md](SOLINA_LAUNCHER_INTEGRATION.md) for the audit and required checks.

The upstream QuickSwitch README states that launchers must implement Quickstep support themselves and notes that Nova is unlikely to support QuickSwitch. Therefore, Nova is not the intended integration target for this project.

## Known target to investigate

| Device | Android | Root manager | Launcher and version | Result | Evidence |
|---|---|---|---|---|---|
| Poco F3 (Alioth) | Android 17 (device reports release `17`, API 37) | KernelSU `ksud 3.2.5` | **Solina Launcher debug** `16.Dev.(#60)`, package `com.solina.launcher.debug` | NOT TESTED | Installed package inventory plus source-level Quickstep build-path evidence; no functional Quickstep/Recents test report |

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


## Update: experimental Quickstep build evidence (2026-10-29)

The separate [Solina-Launcher API 37 audit branch](https://github.com/Solina-Projects/Solina-Launcher/tree/feature/quickstep-api37-audit) now builds an experimental, debug-only `solinaQuickstepGithubDebug` variant. CI run [40815028487](https://github.com/Solina-Projects/Solina-Launcher/actions/runs/40815028487) succeeded, and the artifact's decoded manifest includes Quickstep service/action and Recents declarations. This means the earlier claim that no Quickstep-enabled APK build path exists is no longer current for that feature branch.

The result remains **NOT TESTED at runtime**. The API 37 debug SDK-range override is not a release compatibility declaration; production support bounds remain API 35–36. The OS/ROM privilege grants, service binding, Recents, gestures, animation callbacks, rollback, and module licensing remain unresolved. No installable QuickSwitch module is produced by this evidence.
