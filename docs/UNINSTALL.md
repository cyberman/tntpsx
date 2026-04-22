# Uninstall

## Purpose

This document describes the supported manual removal path for `tntpsx` on Mac OS X Leopard 10.5.8 PowerPC.

The goal is a clean rollback of:

- kernel extensions
- startup items
- optional installer receipts

## Scope

This uninstall path removes:

- `/Library/Extensions/tap.kext`
- `/Library/Extensions/tun.kext`
- `/Library/StartupItems/tap`
- `/Library/StartupItems/tun`

It also removes known legacy locations if they still exist:

- `/System/Library/Extensions/tap.kext`
- `/System/Library/Extensions/tun.kext`
- `/System/Library/StartupItems/tap`
- `/System/Library/StartupItems/tun`

## Recommended Method

Use the provided uninstall script:

```sh
sudo ./scripts/uninstall-tntpsx.sh
````

## Manual Removal

If you prefer a fully manual path, use the following sequence.

### 1. Unload the kernel extensions

```sh
sudo kextunload /Library/Extensions/tap.kext 2>/dev/null || true
sudo kextunload /Library/Extensions/tun.kext 2>/dev/null || true
```

### 2. Remove installed files

```sh
sudo rm -rf /Library/Extensions/tap.kext
sudo rm -rf /Library/Extensions/tun.kext
sudo rm -rf /Library/StartupItems/tap
sudo rm -rf /Library/StartupItems/tun
```

### 3. Remove legacy historical locations if present

```sh
sudo rm -rf /System/Library/Extensions/tap.kext
sudo rm -rf /System/Library/Extensions/tun.kext
sudo rm -rf /System/Library/StartupItems/tap
sudo rm -rf /System/Library/StartupItems/tun
```

### 4. Optional: remove old installer receipts

```sh
sudo rm -rf /Library/Receipts/tuntap*.pkg
sudo rm -rf /Library/Receipts/TunTap*.pkg
```

## Verification

After uninstall, the following checks should show that the components are gone:

```sh
ls -ld /Library/Extensions/tap.kext /Library/Extensions/tun.kext
ls -ld /Library/StartupItems/tap /Library/StartupItems/tun
kextstat | grep -i -E 'foo.tap|foo.tun|tap|tun'
ls -la /dev/tap* /dev/tun*
```

Expected result:

- installed paths no longer exist
    
- `foo.tap` and `foo.tun` no longer appear in `kextstat`
    
- `/dev/tap*` and `/dev/tun*` are no longer present after unload
    

## Notes

- Removing the files without unloading first is not recommended.
    
- Device nodes may disappear immediately after unloading, or after the system fully settles.
    
- This uninstall path is intentionally conservative and explicit.
    

---
