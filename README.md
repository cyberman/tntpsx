# tntpsx

## 1. Overview

`tntpsx` restores native TUN/TAP kernel extensions for Mac OS X Leopard 10.5.8 on PowerPC.

This repository is not just a historical mirror. It is an active Leopard/PPC recovery line based on the old `tuntaposx` code base.

The current verified recovery status includes:

- `tap.kext` builds on Leopard/PPC
- `tun.kext` builds on Leopard/PPC
- both kexts load successfully
- `/dev/tap*` and `/dev/tun*` device nodes are created
- opening the devices creates working `tapX` and `tunX` interfaces
- package installation works on Leopard/PPC
- uninstall works cleanly
- reinstall works cleanly
- startup item resources are carried correctly through package installation

Verified milestone tags:

- `leopard-ppc-tuntap-v1`
- `leopard-ppc-installer-roundtrip-v1`

## 2. Historical Basis

`tntpsx` is based on the historical `tuntaposx` Leopard-era code line, with the current repository aligned to the `20090913` generation as its practical base.

The current recovery-line product version is `0.1.0`.

See:

- `docs/BASIS.md`

The upstream `tuntaposx` project was abandoned long ago. This repository keeps a vendor copy for historical reference in `vendor/tuntap`.

## 3. Project Status

Current status: **Leopard/PPC build path, runtime path, and installer roundtrip verified**

Verified environment:

- Mac OS X Leopard 10.5.8
- PowerPC
- Xcode 3 legacy build flow
- kernel extensions loaded manually via `kextload`

This project currently focuses on:

- restoring a stable Leopard/PPC build path
- documenting the repaired toolchain and runtime path
- preserving a reproducible native TUN/TAP foundation for further networking work

Startup item resource localization is preserved in the repository, but Leopard 10.5.8 PPC does not localize `ConsoleMessage` output through `/etc/rc.common` on the verified target.

## 4. What This Repo Provides

This repo builds two kernel extensions:

- `tap.kext`  
  Ethernet-style virtual network interface (`/dev/tapX`)

- `tun.kext`  
  IP tunnel-style virtual network interface (`/dev/tunX`)

These are infrastructure components. They are not a VPN by themselves. They provide the virtual network devices that later userspace tools can build on.

## 5. Verified Runtime Result

The current milestone has been verified with the following outcomes:

- `kextload` succeeds for both `tap.kext` and `tun.kext`
- `kextstat` shows both loaded
- `/dev/tap0` ... `/dev/tap15` exist
- `/dev/tun0` ... `/dev/tun15` exist
- opening `/dev/tap0` creates `tap0`
- opening `/dev/tun0` creates `tun0`
- `tap0` and `tun0` can be configured with `ifconfig` when run with sufficient privileges

## 6. Verified Installer Roundtrip

A full installer lifecycle has been verified on Leopard/PPC:

- package build via PackageMaker succeeds
- package install succeeds
- installed kexts appear in `/Library/Extensions`
- installed startup items appear in `/Library/StartupItems`
- startup item resource trees are preserved during installation
- uninstall via `scripts/uninstall-tntpsx.sh` removes installed components cleanly
- reinstall from package restores the full working state

Verified milestone tag:

`leopard-ppc-installer-roundtrip-v1`

## 7. Current Scope

This repository currently documents and preserves:

- the repaired Leopard/PPC build path
    
- the restored runtime path for native TUN/TAP devices
    
- the verified milestone tag `leopard-ppc-tuntap-v1`
    

The recovery line is also validated through a dedicated hardening process. See `docs/HARDENING.md`.

It does **not** yet provide:

- a fully polished installer identity and presentation layer
- automated permissions handling for non-root users
- a userspace networking utility using `/dev/tunX` or `/dev/tapX`

The current package/release identity for the active recovery line is `tntpsx 0.1.0`.
## 8. Milestone Tags

- `leopard-ppc-tuntap-v1`
- `leopard-ppc-installer-roundtrip-v1`
- `org-tntpsx-identity-v1`

Current product version:

`0.1.0`

---

