# Basis

## Purpose

This document defines the concrete historical basis of the current `tntpsx` repository.

It exists to answer a simple but important question:

**What exactly is this repo built on?**

## Historical Base

The current Leopard/PPC recovery line is based on the historical `tuntaposx` code line, with the repository aligned to the `20090913` generation as the practical Leopard-focused foundation.

This choice was intentional:

- it is historically closer to the Mac OS X 10.4/10.5 era
- it avoids later drift toward newer Darwin/Xcode assumptions
- it provides a better starting point for Leopard/PPC recovery than later branches aimed at newer systems

## What This Repository Is

`tntpsx` is not intended as a generic mirror of all later `tuntaposx` development.

It is a focused Leopard/PPC recovery branch that:

- preserves a historical `tuntaposx` foundation
- applies Leopard/PPC-specific repair work
- documents the recovered build and runtime path
- keeps a separate archival vendor tree for reference

## Active Tree vs Archival Tree

### Active tree

The active build root is the repository top level.

This is the code path used for:

- `tap.kext`
- `tun.kext`
- Leopard/PPC build fixes
- Leopard/PPC runtime verification

### Archival tree

`vendor/tuntap/` is retained as archival reference material.

It is useful for:

- historical comparison
- upstream structure reference
- patch archaeology

It is **not** the primary active build root.

## Recovery-Specific Changes

The current Leopard/PPC line includes repairs beyond the historical base.

These include at least:

- PPC-only build path cleanup
- legacy Xcode compatibility adjustments
- Leopard ioctl callback signature repair
- removal of an unsupported linker flag for Leopard
- repository hygiene and documentation cleanup

## Practical Interpretation

The repo should be understood as:

**historical `tuntaposx` Leopard-era base + modern recovery work for Leopard/PPC**

It is therefore both:

- historical in origin
- active in maintenance intent

## Milestone Reference

The first fully verified Leopard/PPC recovery milestone is:

`leopard-ppc-tuntap-v1`

