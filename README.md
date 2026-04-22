# tntpsx

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

## Historical Basis

`tntpsx` is based on the historical `tuntaposx` Leopard-era code line. The current product version is `0.1.0`, while the historical upstream base remains aligned to the `20090913` generation.

See:

- `docs/BASIS.md`

## Project Status

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

## What This Repo Provides

This repo builds two kernel extensions:

- `tap.kext`  
  Ethernet-style virtual network interface (`/dev/tapX`)

- `tun.kext`  
  IP tunnel-style virtual network interface (`/dev/tunX`)

These are infrastructure components. They are not a VPN by themselves. They provide the virtual network devices that later userspace tools can build on.

## Verified Runtime Result

The current milestone has been verified with the following outcomes:

- `kextload` succeeds for both `tap.kext` and `tun.kext`
- `kextstat` shows both loaded
- `/dev/tap0` ... `/dev/tap15` exist
- `/dev/tun0` ... `/dev/tun15` exist
- opening `/dev/tap0` creates `tap0`
- opening `/dev/tun0` creates `tun0`
- `tap0` and `tun0` can be configured with `ifconfig` when run with sufficient privileges

## Verified Installer Roundtrip

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

## Quick Start

### Build

Open the legacy Xcode project:

` tntpsx.xcodeproj `

or build from the shell:

```sh
make
````

Expected build products in the repository root:

- `tap.kext`
    
- `tun.kext`
    

### Install

```sh
sudo cp -R tap.kext /Library/Extensions/
sudo cp -R tun.kext /Library/Extensions/
sudo chown -R root:wheel /Library/Extensions/tap.kext /Library/Extensions/tun.kext
sudo chmod -R 755 /Library/Extensions/tap.kext /Library/Extensions/tun.kext
```

### Load

```sh
sudo kextload /Library/Extensions/tap.kext
sudo kextload /Library/Extensions/tun.kext
```

### Check

```sh
kextstat | grep -i -E 'tap|tun'
ls -la /dev/tap* /dev/tun*
```

## Repository Layout

See:

- `docs/BUILD.md`
    
- `docs/RUNTIME_TEST.md`
    
- `docs/REPO_LAYOUT.md`
    
- `docs/KNOWN_ISSUES.md`
    

## Current Scope

This repository currently documents and preserves:

- the repaired Leopard/PPC build path
    
- the restored runtime path for native TUN/TAP devices
    
- the verified milestone tag `leopard-ppc-tuntap-v1`
    

It does **not** yet provide:

- a fully polished installer identity and presentation layer
- automated permissions handling for non-root users
- a userspace networking utility using `/dev/tunX` or `/dev/tapX`

## Historical Note

The upstream `tuntaposx` project was abandoned long ago. This repository keeps a vendor copy for historical reference, but the active build root is the repository top level, not `vendor/tuntap`.

## Milestone Tags

- `leopard-ppc-tuntap-v1`
- `leopard-ppc-installer-roundtrip-v1`

---

