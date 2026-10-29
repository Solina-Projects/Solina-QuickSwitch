# Upstream review: QuickSwitch

Review date: 2026-10-29

Upstream repository: https://github.com/skittles9823/QuickSwitch

## Findings

- The upstream README describes QuickSwitch as a Magisk/KernelSU/APatch module that enables supported launchers to access Android's Recents/Quickstep APIs.
- The README says Android 9+ and a current supported root manager are required.
- The upstream module metadata identifies version v4.0.3, module ID `quickswitch`, and an update JSON URL pointing to the upstream repository.
- The installer script extracts overlays, system files, helper tools, module metadata, and the `quickswitch` shell backend; it also installs a bundled `QuickSwitch.apk` unless configured otherwise.
- No root-level `LICENSE` file was found through the repository contents endpoint during this review. This does not prove that every file is unlicensed, nor does it identify the license of the APK, bundled binaries, or third-party components.

## Decision

Do not copy, modify, repackage, or redistribute upstream source, the APK, signing tools, or bundled binaries into Solina-QuickSwitch until applicable licensing and redistribution permissions are established.

The safe paths are:

1. Obtain explicit permission or written licensing clarification from the relevant rights holders and confirm licenses for every bundled component; or
2. Build a clean-room implementation from independently authored code, using public Android/KernelSU/Magisk interfaces and documentation, without copying protected implementation code or redistributing upstream binaries.

A clean-room implementation is not automatically compatible or safe simply because it is independently written. Installer behavior, provider switching, overlays, SELinux policy, rollback, and Android-version support require design and device testing.

## Device validation

No installable artifact has been produced by this project yet. Do not flash this repository or any CI archive as a module. A test plan must include recovery/rollback, module upgrade, provider reset, uninstall, reboot, and KernelSU-specific checks on supported devices before any release is considered.
