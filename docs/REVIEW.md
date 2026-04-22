## Purpose

This document defines a practical review checklist for `tntpsx`.

It is intentionally focused on real Leopard/PPC kernel-extension risks, not generic style commentary.

The goal is to review the project in a way that improves:

- stability
- maintainability
- unload safety
- kernel/userspace boundary correctness
- confidence in the recovered Leopard/PPC line

---

## Review Scope

Primary review targets:

- `src/tuntap.*`
- `src/tuntap_mgr.*`
- `src/tap/*`
- `src/tun/*`
- shared locking, queueing, and memory helpers

Secondary review targets:

- installer/runtime integration
- startup items
- documentation consistency
- packaging identity

---

## Review Status

- [ ] Not started
- [ ] In progress
- [ ] First pass completed
- [ ] Follow-up fixes completed
- [ ] Re-verified after fixes

---

# 1. Namespace and Symbol Visibility

## Goal

Reduce accidental symbol exposure and keep internal helpers private.

## Checks

- [ ] All file-local helper functions are marked `static` where possible
- [ ] No unnecessary globally visible symbols remain
- [ ] Symbol names are specific enough to avoid collisions
- [ ] No generic helper names remain in active kernel code
- [ ] No new identifiers use leading underscores

## Notes

- Favor local visibility wherever possible
- Keep exported identity aligned with `org.tntpsx.*`

---

# 2. Bundle Identity Consistency

## Goal

Ensure runtime identity, plist identity, and package identity match.

## Checks

- [ ] `src/tap/Info.plist` uses `org.tntpsx.tap`
- [ ] `src/tun/Info.plist` uses `org.tntpsx.tun`
- [ ] PackageMaker identifiers use `org.tntpsx.*`
- [ ] `kextstat` shows the expected identifiers
- [ ] No active-path references remain to `foo.tap`, `foo.tun`, or `tuntap.*`

## Notes

- Vendor/archive paths do not count unless intentionally reactivated

---

# 3. Header and API Discipline

## Goal

Keep the active code path as close as practical to kernel-appropriate APIs.

## Checks

- [ ] No obvious user-space-only headers are used in active kernel code
- [ ] Includes are minimal and relevant
- [ ] Leopard-era private assumptions are documented where unavoidable
- [ ] Suspicious compatibility hacks are marked clearly in comments
- [ ] No hidden dependency on accidental build environment behavior remains

## Notes

- Distinguish clearly between:
  - necessary Leopard compatibility logic
  - historical hacks that should be revisited

---

# 4. Locking, Sleep, and Wakeup

## Goal

Identify race conditions, lock misuse, and fragile wait behavior.

## Checks

- [ ] Every lock acquisition has a clear release path
- [ ] No obvious lock leak exists on error paths
- [ ] Sleep/wakeup behavior is documented where non-trivial
- [ ] Open/close paths are safe under repeated use
- [ ] Open/close vs unload interaction is reviewed
- [ ] Queue access under concurrent conditions is reviewed
- [ ] Gate/condition-style logic is understandable and bounded

## High-Risk Review Points

- [ ] device open path
- [ ] device close path
- [ ] queue wait path
- [ ] wakeup path
- [ ] unload path while descriptors may still be open

## Notes

This is one of the highest-priority review zones.

---

# 5. Error Paths and Cleanup Symmetry

## Goal

Make initialization and teardown symmetric and predictable.

## Checks

- [ ] Each allocation has a clear cleanup path
- [ ] Partial initialization failures roll back cleanly
- [ ] Interface creation failures do not leave stale state
- [ ] Device creation failures do not leave half-registered objects
- [ ] Teardown removes everything it created
- [ ] Error returns do not silently skip required cleanup

## Notes

Look specifically for:

- early returns
- multi-step init functions
- nested allocation/setup sequences
- failure after partial registration

---

# 6. Stack and Local Object Discipline

## Goal

Avoid fragile stack-heavy behavior in kernel code.

## Checks

- [ ] No suspiciously large local arrays are used on the stack
- [ ] No recursive logic exists in active kernel paths
- [ ] Deep call chains are reviewed for local object weight
- [ ] Local structures are bounded and intentional

## Notes

Prefer explicit bounded behavior over convenience.

---

# 7. User/Kernel Boundary Review

## Goal

Make all boundary crossings explicit, validated, and conservative.

## Checks

- [ ] All `ioctl`-related paths are reviewed
- [ ] Input lengths and argument assumptions are validated
- [ ] User-supplied data is not trusted implicitly
- [ ] Copying between spaces is bounded and checked
- [ ] Invalid input fails safely

## Notes

Anything crossing the user/kernel boundary deserves extra suspicion.

---

# 8. Queueing and Data-Path Robustness

## Goal

Verify that packet/frame handling remains correct beyond the happy path.

## Checks

- [ ] Queue insertion failure behavior is clear
- [ ] Queue draining behavior is clear
- [ ] Packet/frame ownership is clear at each step
- [ ] mbuf/frame lifetime is accounted for
- [ ] Slow readers do not obviously leak or deadlock
- [ ] Burst traffic behavior is at least reasoned about, even if not benchmarked

## Notes

The smoke tests prove functional delivery.
This review step asks whether behavior remains sane under stress or delay.

---

# 9. Unload Safety

## Goal

Ensure the kext can leave the system cleanly.

## Checks

- [ ] Unload after open/close cycling is reviewed
- [ ] Unload while devices are inactive is clean
- [ ] Unload while device nodes exist is clean
- [ ] Unload does not leave stale interface state
- [ ] Unload does not leave stale queue state
- [ ] Unload failure behavior is understandable

## Notes

A kernel extension is not truly trustworthy until unload behavior is understood.

---

# 10. Legacy Hack Register

## Goal

Identify old workarounds and separate them from deliberate design.

## Checks

- [ ] Historical hacks are clearly commented
- [ ] Each non-obvious workaround explains why it exists
- [ ] Leopard/Tiger-specific workarounds are marked as such
- [ ] Struct-size assumptions are called out explicitly
- [ ] Known fragile compatibility hacks are collected in one place

## Recommended Comment Style

Use comments of this form:

```c
/*
 * Leopard compatibility workaround:
 * Reason:
 * Risk:
 * Replaceable later:
 */
````

## Notes

The point is not to eliminate every old workaround immediately.  
The point is to make them visible and reviewable.

---

# 11. Installer and Runtime Integration

## Goal

Ensure the polished release path matches the verified runtime path.

## Checks

-  Package installs the expected kexts
    
-  Package installs the expected startup items
    
-  Uninstall script removes installed components cleanly
    
-  Reinstall restores the verified working state
    
-  Runtime identifiers match package identifiers
    
-  Known PackageMaker warnings are documented, not ignored silently
    

## Notes

This review item is lower risk than kernel locking or queueing, but important for trust.

---

# 12. Documentation Consistency

## Goal

Keep repo claims aligned with verified reality.

## Checks

-  `README.md` matches current verified state
    
-  `CHANGELOG.md` reflects actual milestones
    
-  `docs/RUNTIME_TEST.md` includes current smoke-test evidence
    
-  `docs/KNOWN_ISSUES.md` includes the PackageMaker warning
    
-  `NOTICE` and `LICENSE` remain aligned with shipped identity
    
-  No active documentation still describes the project as raw `tuntap`
    

---

# Review Priority Order

## Phase 1 — Highest Risk

-  Locking, sleep, wakeup
    
-  Error paths and cleanup symmetry
    
-  User/kernel boundary handling
    
-  Unload safety
    

## Phase 2 — Operational Confidence

-  Queueing and data-path robustness
    
-  Stack/local object discipline
    
-  Namespace/symbol visibility
    

## Phase 3 — Product Polish

-  Installer/runtime integration
    
-  Documentation consistency
    
-  Legacy hack register cleanup
    

---

# Review Findings Log

## Open Findings

-  None yet
    

## Resolved Findings

-  None yet
    

---

# Reviewer Notes

Use this section for free-form notes during review passes.

## Notes

---

# Exit Criteria for a Stronger Post-RC Build

A stronger post-RC build should ideally have:

-  first-pass review completed for all high-risk areas
    
-  no unexplained legacy hacks in critical paths
    
-  no obvious cleanup asymmetry in init/teardown
    
-  no unresolved unload-safety concern in normal operation
    
-  smoke-test documentation still matching current code
    
