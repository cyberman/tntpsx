# HARDENING

## Purpose

This document defines the hardening mindset and stress-validation approach for `tntpsx`.

`tntpsx` is not treated as a cosmetic recovery project. It is treated as infrastructure.

Because this code is intended to serve as a foundation for later VPN-related work on Mac OS X Leopard 10.5.8 PowerPC, the project is validated like a system component under controlled stress, repeated lifecycle testing, and targeted break-point probing.

The goal is not to "hope it works".

The goal is to determine:

- where the recovered code is already robust
- where timing sensitivity exists
- where lifecycle behavior is deterministic
- where further strengthening is required

## Hardening Philosophy

`tntpsx` uses a material-testing approach.

Known risk zones from code review are combined with repeatable runtime stress tests.

This means:

- code review identifies plausible break zones
- hardening tests attempt to provoke those zones
- results are documented
- only real findings are escalated into deeper investigation or code changes

This approach is preferred over manual trial-and-error because it conserves operator effort and yields clearer evidence.

## Scope

The hardening process covers:

- repeated open/close lifecycle behavior
- repeated device/interface creation and teardown
- unload behavior while interfaces are still open
- unload behavior after close
- reinstall and roundtrip validation
- packet/frame data-path validation
- reboot/boot-path validation
- future stress testing under longer traffic runs

## Verified Hardening Results So Far

The following behaviors have already been verified on the Leopard/PPC target:

### 1. Reopen behavior

- `tap` reopen hardening test completed successfully across repeated iterations
- `tun` reopen hardening test completed successfully across repeated iterations
- one rare short `tun` visibility delay was observed, but no hard failure was reproduced
- no persistent interface loss or broken state was observed

### 2. Unload behavior

- unloading while `tun0` or `tap0` is still open is blocked
- unloading after close succeeds
- reloading after unload succeeds

This is treated as a strong positive hardening result.

### 3. Data-path behavior

- TUN data path verified using an outbound ICMP packet
- TAP data path verified using an ARP broadcast frame
- userspace readers successfully received real traffic from both device types

### 4. Packaging lifecycle

- package build verified
- package install verified
- uninstall verified
- reinstall verified
- post-reinstall data-path verified

## Current Hardening Interpretation

Current evidence indicates that the recovered Leopard/PPC line is functionally robust in the tested lifecycle and data-path scenarios.

At present, the project shows:

- strong basic lifecycle behavior
- strong unload protection behavior
- verified userspace-visible data-path behavior
- no reproduced hard stability failure in the active hardening tests so far
- `tun` reopen hardening shows rare timing-sensitive visible `UP` delays, but no reproduced hard failure
- `tap` reopen hardening no longer reproduces hard failure in the calibrated 3-stage test flow
- `tap` reopen behavior can still show rare short or late visible `UP` transitions under rapid reopen churn
- isolated `tap` testing without `mDNSResponder` confirms the absence of reproduced hard failures in the current recovery line

The current interpretation is therefore:

- `tun` shows a minor timing-sensitive state characteristic
- `tap` shows a minor timing-sensitive reopen characteristic
- neither behavior is currently treated as a confirmed stability defect in the verified recovery line

## Hardening Test Sets

The repository includes dedicated test tools under `tools/`.

Current hardening-oriented tools include:

- `test_tun.sh`
- `test_tap.sh`
- `test_reopen_tun.sh`
- `test_reopen_tap.sh`
- `test_reopen_tap_isolated.sh`
- `test_unload_while_open.sh`
- `test_gauntlet.sh`
- `test_boot_cycle.sh`

These tools are not throwaway helpers. They are part of the validation strategy of the recovery line.

## Hardening Rules

### Rule 1

Do not treat one successful smoke test as proof of robustness.

### Rule 2

Do not treat one suspicious code pattern as proof of real failure unless it can be logically proven or practically reproduced.

### Rule 3

Prefer automated repeatable stress tests over manual repeated terminal work.

### Rule 4

When a failure occurs, preserve the evidence first, then narrow the cause.

### Rule 5

If a warning is reproducible but non-fatal, document it clearly instead of hiding it.

## Next Hardening Targets

The next recommended hardening targets are:

### 1. Boot/Reboot validation

A dedicated reboot regression flow is part of the hardening strategy.

The goal is to verify that `tntpsx` survives a real system restart without manual intervention and still provides the expected runtime state afterward.

The repository includes:

- `tools/test_boot_cycle.sh`

This tool supports a two-phase boot-cycle test:

- `prep` or `prep-reboot` before restart
- `verify` after restart

The boot-cycle verification checks:

- startup items are still present
- `org.tntpsx.tun` is loaded after boot
- `org.tntpsx.tap` is loaded after boot
- `/dev/tun0` exists after boot
- `/dev/tap0` exists after boot
- TUN data-path smoke test passes after boot
- TAP data-path smoke test passes after boot
- TUN reopen hardening passes after boot
- TAP reopen hardening passes after boot

This makes reboot validation part of the same material-testing philosophy as the other hardening tools.

### 2. Longer-duration stress

- repeated data-path traffic over longer sessions
- repeated lifecycle churn over larger iteration counts
- watch for degradation, leaks, or state drift

### 3. Code review focus areas

The highest-priority review areas remain:

- locking / sleep / wakeup behavior
- error-path cleanup symmetry
- queueing and object lifetime
- user/kernel boundary handling
- unload-time safety

## Non-Goals

Hardening is not the same as feature growth.

At this stage, the project does not prioritize:

- additional networking features
- new protocol layers
- large upstream merges
- feature expansion ahead of robustness

## Summary

`tntpsx` is hardened by combining:

- code-derived risk mapping
- automated runtime stress
- documented findings
- conservative interpretation of evidence

This turns the recovery line into a measured infrastructure component rather than a one-off porting success.
