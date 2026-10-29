# Solina-QuickSwitch: clean-room implementation plan

Status: design only. This document is not an implementation specification for flashing a device; unresolved platform details must be verified against official Android and root-manager documentation before code is written.

## Goals

- Independently implement a small, auditable integration layer for supported launchers and Android versions.
- Keep the default behavior non-destructive: no silent launcher/provider changes, no deletion of user data, and no automatic modification of unrelated system files.
- Make every state-changing operation explicit, logged, reversible, and testable.
- Separate platform-specific behavior from module packaging and user-facing controls.

## Non-goals

- Making an unsupported launcher implement Quickstep APIs by itself.
- Shipping copied upstream scripts, APKs, overlays, signing tools, or binaries without verified permission and licenses.
- Claiming compatibility solely because a device is rooted or because a package installs.

## Proposed components

1. **Compatibility probe** — gathers Android API level, build fingerprint, root-manager environment, active launcher, and relevant package/provider information. Read-only; reports unknown values rather than guessing.
2. **Capability resolver** — compares probe results with an explicit, versioned support table. Unknown combinations must be marked unsupported/untested and block state changes by default.
3. **Plan builder** — prepares a proposed change and a recovery plan without applying it. The plan lists each file/property/provider that would change and the expected prior state.
4. **Apply/rollback controller** — only after the user confirms a supported plan, applies changes transactionally where possible, records original state, and restores it on failure. Must be idempotent.
5. **Health check** — after reboot or provider change, verifies that the selected launcher and Recents interaction remain available; failure must provide a clear rollback path.
6. **Uninstaller** — removes only files owned by this module and restores recorded original state. Never removes files merely because their names look related.

## State and safety rules

- Do not assume a specific system partition layout or overlay mechanism across Android versions and root managers.
- Do not guess package names. Discover them from device state and validate against an allowlist/support table.
- Never overwrite a prior state snapshot; use versioned snapshots and integrity checks.
- Reject partial/corrupt state records instead of attempting speculative restoration.
- A failed preflight must stop before any write.
- Apply operations must support dry-run output and explicit confirmation.
- Logs must avoid secrets and unnecessary personal/device identifiers.
- No installer, service, boot script, SELinux policy, overlay, or provider mutation is considered safe until individually reviewed and tested.

## Test layers

### Layer A — repository/host checks
- Validate required documentation and release gates.
- Run shell linting and unit tests for pure parsing/state logic when such code exists.
- Ensure test runs never require root or mutate the host.

### Layer B — fixture tests
- Feed synthetic device-probe records for supported, unsupported, incomplete, and malformed environments.
- Verify unknown API levels, absent packages, and corrupt snapshots fail closed.
- Verify a second apply/rollback attempt is idempotent.

### Layer C — disposable device tests
- Use a recoverable test device or emulator where the required root-manager behavior is available.
- Capture baseline launcher/provider state and confirm recovery access before applying changes.
- Test install, no-op update, upgrade, failed apply, rollback, reboot, provider reset, and uninstall.
- Verify logs, permissions, ownership, and only-module-owned file cleanup.

### Layer D — target-device validation
- Test the user's Poco F3 / Alioth and installed KernelSU setup only after earlier layers pass.
- Record exact Android build, KernelSU version, launcher package/version, and test result.
- A successful install alone is not a pass; Recents gestures, overview, app switching, reboot persistence, rollback, and uninstall must all pass.

## Release gates

A release package must not be produced until all of the following are true:

- Source and third-party licensing/permissions are documented.
- The compatibility table names exact tested combinations.
- Automated tests and static analysis pass.
- Install/upgrade/failure rollback/uninstall have been exercised on a recoverable test setup.
- The target-device test report is recorded.
- Package contents are reproducible and contain no unapproved upstream binaries.
- A separate Release workflow validates a tagged, reviewed commit and publishes checksums plus a test report.

## Open decisions

- Which Android API levels and root-manager versions are in scope for the first prototype?
- Which exact Quickstep integration points are supported by the intended launcher?
- Which platform behaviors can be implemented using documented interfaces, and which require privileged overlays or policy changes?
- What is the verified restoration mechanism for each supported environment?

Until these are answered with source references and tests, this repository remains documentation and validation scaffolding, not a flashable module.
