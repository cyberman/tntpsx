# Repository Layout

## Overview

This repository contains an active Leopard/PPC recovery line for native TUN/TAP kernel extensions.

The active build root is the repository top level.

The `vendor/` tree is archival.

## Top-Level Layout

### `README.md`

Current project overview and status.

### `Makefile`

Root build entry point.

The root makefile drives the build of:

- `tap.kext`
- `tun.kext`

### `tntpsx.xcodeproj/`

Legacy Xcode wrapper project around the make-based build flow.

Used for Leopard/Xcode 3 workflows.

### `docs/`

Project documentation for:

- build flow
- runtime verification
- repository structure
- known issues

## Active Source Tree

### `src/`

Shared active source code.

This is the main active code root.

### `src/tap/`

Source and build files for:

- `tap.kext`

### `src/tun/`

Source and build files for:

- `tun.kext`

### `startup_item/`

Legacy startup item material for boot-time loading support.

This path has not yet been fully re-verified in the current Leopard/PPC recovery line.

### `pkg/`

Legacy package/installer resources.

Useful for historical packaging flow and possible future revalidation.

## Archival Tree

### `vendor/tuntap/`

Archival upstream-style snapshot.

This directory is kept for reference and comparison.

It is **not** the primary active build root.

Do not treat `vendor/tuntap/` as the main edit target unless a specific comparison or recovery task requires it.

## Build Outputs

Expected root-level build outputs:

- `tap.kext`
- `tun.kext`

These are generated into the repository root, not into `vendor/`.

## Practical Rule

If you are working on the current Leopard/PPC line, work here first:

- root `Makefile`
- `src/`
- `tntpsx.xcodeproj/`
- `docs/`

Treat `vendor/tuntap/` as reference material.

For the concrete historical basis of the active recovery line, see `docs/BASIS.md`.

