# Solina Launcher Quickstep integration audit

Status: **source-level investigation only; runtime support NOT TESTED**.

## Goal

Make Solina Launcher the intended and explicitly tested launcher for Solina-QuickSwitch. Do not treat Nova Launcher as the target. The device's default HOME activity was Nova at the time of inventory, but changing providers or rebooting is not authorized while compatibility and recovery remain unverified.

## Evidence collected

### Installed device package

User-provided read-only device output identified:

- Device: Poco F3 (Alioth)
- Android release: `17`; API: `37`
- Root manager: KernelSU; `su -c 'ksud -V'` returned `ksud 3.2.5`
- Installed Solina Launcher debug package: `com.solina.launcher.debug`
- Solina Launcher version: `16.Dev.(#60)`
- Current HOME activity at the time of inspection: `com.teslacoilsw.launcher/.NovaLauncher`

These facts identify the environment; they do not show Quickstep runtime functionality.

#### Repository rename confirmed

The canonical launcher repository is now [Solina-Launcher](https://github.com/Solina-Projects/Solina-Launcher) (default branch `main`). The repository API confirms the renamed repository is public and its current `main` commit is `cbd58321761781fcdaea5e9e517ef99875ed5ed4`. This identifies the source currently available for review; it does **not** establish that installed version `16.Dev.(#60)` was built from this exact commit.

## Source-level evidence

The renamed Solina-Launcher repository's README documents the build task:

`assembleLawnWithQuickstepGithubDebug`

The source tree contains Launcher3/Quickstep compatibility classes, but there are now **two separate blockers** in the current `main` build configuration:

1. `quickstepMinSdk = "35"` and `quickstepMaxSdk = "36"`, while the target phone reports API 37. API 37 is outside the configured Quickstep range.
2. `androidComponents.beforeVariants` enables only `solinaWithoutQuickstepGithubDebug` and `solinaWithoutQuickstepGithubRelease`, and the repository CI builds those same `WithoutQuickstep` variants. Therefore the current published CI artifacts are explicitly built **without Quickstep**. A Quickstep-related source tree or old installed APK does not prove the current branch produces a Quickstep-enabled APK.

These are source/build-configuration blockers, not a confirmed runtime failure report. The installed debug APK `16.Dev.(#60)` has not been mapped to the current source commit; inspect its provenance separately.

The upstream QuickSwitch README says a launcher must implement Quickstep support itself; the module cannot add that implementation to an otherwise incompatible launcher. It also explicitly cautions that Nova is unlikely to support QuickSwitch. This project therefore prioritizes Solina Launcher.

References:
- [Solina Launcher README](https://github.com/Solina-Projects/Solina-Launcher/blob/main/README.md)
- [Solina Launcher manifest](https://github.com/Solina-Projects/Solina-Launcher/blob/main/AndroidManifest.xml)
- [Upstream QuickSwitch README](https://github.com/skittles9823/QuickSwitch/blob/master/README.md)

## Required next steps (in order)

1. **Pin the exact Solina Launcher source revision** that produced `16.Dev.(#60)`; capture its commit SHA and build variant. If it cannot be mapped to a source revision, build a fresh debug APK from the reviewed Solina Launcher branch before attributing behavior to source.
2. **Restore a deliberate Quickstep build path:** the current `beforeVariants` allowlist and CI matrix only build `solinaWithoutQuickstepGithubDebug/Release`. Review the intended build flavors and manifest merge before enabling any Quickstep variant; confirm the resulting APK actually includes Quickstep components. Do not rely on the README's old task name alone.
3. **Resolve the API 37 blocker:** current `build.gradle` caps Quickstep support at SDK 36 (`quickstepMaxSdk = "36"`), while the target device is API 37. Do not raise this cap blindly; inspect API 37 framework changes and Quickstep APIs, implement the necessary compatibility path in Solina Launcher on a separate feature branch, and build/test it before proceeding.
4. **Establish licensing/provenance** for the QuickSwitch module and bundled APK/tools. Do not copy or redistribute upstream code or binaries until permissions and licenses are clarified; prefer a documented permission path or an independently authored clean-room implementation.
5. **Define and review a recovery path** for this exact Poco F3/ROM/KernelSU setup. Record the baseline provider and confirm how to restore it before any state-changing test.
6. **Prepare a test-only plan** with explicit approval and evidence capture. Initially verify build/package metadata and non-mutating checks only. Do not switch providers, install overlays/modules, or reboot as part of this audit.
7. Only after steps 1–6 pass, perform an approved real-device test on a recoverable setup. Test Recents gesture, overview display, app switching, launcher restarts, reboot persistence, provider restoration, rollback, and uninstall. Keep the status NOT TESTED until a report is reviewed.

## Current decision

- Intended launcher: **Solina Launcher**
- Device combination: Poco F3 / Android 17 API 37 / KernelSU 3.2.5 / Solina Launcher debug 16.Dev.(#60)
- Build variant: current CI allowlist builds `WithoutQuickstep` variants only (**BLOCKED: current CI artifacts do not provide Quickstep integration**)
- Source-level API range: current Quickstep configuration is SDK 35–36; target API 37 is outside range (**BLOCKED pending launcher compatibility work**)
- Runtime compatibility: **NOT TESTED**
- State-changing operations: **DISABLED**
- Installable QuickSwitch package available from this project: **NO**
- Release permitted: **NO**

A successful source build or CI run is not proof of device compatibility or bug-free behavior.


## Update from the Solina-Launcher API 37 audit (2026-10-29)

The separate development branch [`feature/quickstep-api37-audit`](https://github.com/Solina-Projects/Solina-Launcher/tree/feature/quickstep-api37-audit) now has an **experimental, debug-only** `solinaQuickstepGithubDebug` variant. Its CI run [40815028487](https://github.com/Solina-Projects/Solina-Launcher/actions/runs/40815028487) succeeded and produced a Quickstep-enabled APK artifact. The binary manifest was inspected and includes the Quickstep service/action and Recents activity declarations.

This narrows the earlier build-path blocker: an experimental Quickstep-enabled APK can now be built on that branch. It does **not** resolve API 37 runtime compatibility, grant system/signature privileges, establish ROM provider registration, or make the artifact a release-ready installer. The release SDK support bounds remain 35–36; the debug variant's widened bounds are test-only. The source audit has not identified a confirmed API-37-only change requiring a new compat factory, and device gesture/Recents tests remain NOT RUN. Do not install a QuickSwitch module or switch the active HOME provider on the strength of this build alone.
