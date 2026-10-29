# Device test report template

> **Do not use this template as permission to install or modify anything.** Complete it only for an approved test on a recoverable test device. Do not include passwords, tokens, account identifiers, private keys, or unredacted sensitive logs. Never mark a test PASS unless the step was actually performed and its evidence was reviewed.

## 1. Report metadata

- Report ID:
- Test date and time (include timezone):
- Tester:
- Reviewer:
- Review date:
- Project branch and commit SHA:
- Test status: **INCOMPLETE** / PASS / FAIL
- Test type: documentation / static review / simulated fixture / real-device

## 2. Exact test environment

- Device manufacturer/model:
- Device codename:
- Android version:
- Android API level:
- Full build fingerprint (review for unnecessary identifiers before sharing):
- Root manager:
- Root manager exact version:
- Launcher name:
- Launcher package name:
- Launcher version:
- Quickstep/Recents integration evidence:
- Package name/version under test (if an approved package exists):
- Package SHA-256 (if applicable):
- Package provenance and license approval reference:

Write `Not collected` or `Not applicable` rather than guessing. Never present simulated fixture values as device facts.

## 3. Preconditions and recovery

- Licensing/redistribution review cleared by:
- Exact configuration reviewed against the support matrix:
- Backup completed and verified:
- Recovery method:
- Recovery path tested on this configuration? yes / no
- Baseline launcher/provider state recorded:
- Baseline evidence location (redacted):
- Device is a dedicated/recoverable test device? yes / no
- Stop conditions understood:
- Reviewer approval to begin testing:

**Do not proceed with state-changing tests** if licensing is uncleared, the exact setup is unknown, baseline state is missing, or recovery has not been verified.

## 4. Test results

For each row, select PASS only when actually executed and attach a redacted evidence reference. Otherwise select NOT RUN or INCOMPLETE.

| Test | Result (PASS / FAIL / NOT RUN / N/A) | Evidence / notes |
|---|---|---|
| Preflight and baseline capture | NOT RUN | |
| Install on approved test setup | NOT RUN | |
| No-op update | NOT RUN | |
| Upgrade from prior approved version | NOT RUN | |
| Simulated/observed failed apply handling | NOT RUN | |
| Rollback to baseline | NOT RUN | |
| Recovery after simulated failure | NOT RUN | |
| Reboot persistence | NOT RUN | |
| Recents gesture | NOT RUN | |
| Overview display and interaction | NOT RUN | |
| App switching | NOT RUN | |
| Provider reset / restore | NOT RUN | |
| Uninstall and post-uninstall state | NOT RUN | |
| Post-test baseline comparison | NOT RUN | |

For a test marked N/A, explain why and obtain reviewer agreement. Never perform a destructive or state-changing test without explicit project approval and a verified recovery path.

## 5. Findings

- Expected behavior:
- Actual behavior:
- Reproduction steps (non-sensitive):
- Errors or warnings:
- Regression observed:
- Follow-up issue URL:
- Logs/evidence references (redacted):

## 6. Final assessment

- Overall result: **INCOMPLETE** / PASS / FAIL
- Exact configuration this report covers:
- Known limitations:
- Recovery was successfully demonstrated? yes / no / not run
- Reviewer conclusion:
- Support-matrix change proposed: no / yes (link evidence and review)
- Approval for any future state-changing work: no / separately reviewed

A passing report covers only the exact tested configuration and tested commit/package. It does not automatically authorize a release or establish support for other devices or versions.
