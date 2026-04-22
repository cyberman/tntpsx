# Known Issues

## 1. Device Nodes Are Root-Owned By Default

After loading the kexts, the device nodes are created as root-owned character devices.

Typical form:

- owner: `root`
- group: `wheel`
- mode: `660`

A normal user cannot open them without adjusted permissions or elevated privileges.

## 2. Interface Configuration Still Requires Privilege

Even when a non-root user is allowed to open `/dev/tun0` or `/dev/tap0`, configuring the resulting network interface with `ifconfig` still requires privilege.

This is expected.

## 3. Legacy Kext Workflow

This project currently depends on the classic Leopard-era kernel extension loading model.

No modern signing/notarization path is involved.

## 4. Startup Item Flow Not Fully Re-verified

The repository contains legacy startup item material, but the current milestone only verified:

- build
- manual install
- manual `kextload`
- runtime open/configure tests

Boot-time startup behaviour still needs a fresh verification pass.

## Startup Item Localization on Leopard

On the verified Mac OS X Leopard 10.5.8 PPC target, `/etc/rc.common` defines:

`alias ConsoleMessage=echo`

This means startup item `ConsoleMessage` output is not localized through `Resources/*.lproj/Localizable.strings` on this target.

As a result, localized startup item resource folders may still be installed and preserved, but the startup console messages themselves remain effectively English unless a custom localization layer is introduced.

## 5. Installer Package Path Not Yet Re-verified

Legacy packaging material is present in `pkg/`, but the current milestone did not yet re-verify the full installer/package workflow on Leopard/PPC.

## 6. Xcode Legacy Noise

Legacy Xcode workflows may generate per-user and build-index artifacts.

These should not be committed.

Ignored examples:

- `build/`
- `*.pbxuser`

## 7. SMB/CIFS Working Copies Need Care

When working on the repository over an SMB/CIFS-mounted Leopard volume, file mode noise can appear.

Repository-local mitigation used during recovery:

```sh
git config core.fileMode false
````

## 8. Archival Tree vs Active Tree

The repository contains both:

- active root-level sources
    
- archival `vendor/tuntap/`
    

This is intentional, but future contributors must avoid editing the wrong tree by accident.

---
