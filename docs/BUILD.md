# Build Notes

## Purpose

This document records the repaired Leopard/PPC build path for `tntpsx`.

The goal is reproducibility, not archaeology.

## Verified Build Environment

- Mac OS X Leopard 10.5.8
- PowerPC
- Xcode 3 legacy project flow
- legacy `make`-based build backend

## Build Entry Points

Two build paths are available:

### 1. Xcode

Open:

` tntpsx.xcodeproj `

This project is configured as a legacy external build wrapper around the existing make-based layout.

### 2. Shell

From the repository root:

```sh
make
````

Expected output:

- `tap.kext`
    
- `tun.kext`
    

Both bundles are produced in the repository root.

## Leopard/PPC Repair Notes

The restored Leopard/PPC build path required these key changes.

### 1. PPC-only build path

The original build flags were reduced to PowerPC only.

Removed from both `src/tap/Makefile` and `src/tun/Makefile`:

- `-arch i386`
    
- `-arch x86_64`
    

Retained:

- `-arch ppc`
    

### 2. Legacy Xcode action compatibility

The root `Makefile` was updated to support the legacy Xcode action flow.

Added:

```make
build: all

installhdrs:
	@true

installsrc:
	@true
```

This prevents Xcode legacy actions from failing on unsupported action names.

### 3. Leopard ioctl callback signature fix

A Leopard-specific callback signature mismatch was fixed in:

- `src/tuntap.h`
    
- `src/tuntap.cc`
    

The key adjustment was changing the callback parameter type from:

- `long unsigned int`
    

to:

- `u_int32_t`
    

for `tuntap_if_ioctl(...)`

This matches Leopard's expected callback form for the ifnet initialization path.

### 4. Unsupported linker flag removed

The linker flag:

- `-Xlinker -kext`
    

was removed from:

- `src/tap/Makefile`
    
- `src/tun/Makefile`
    

Leopard's linker rejected that flag.

## Build Products

After a successful build, the repository root should contain:

- `tap.kext`
    
- `tun.kext`
    

Each bundle should contain:

- `Contents/Info.plist`
    
- `Contents/MacOS/tap`
    
- `Contents/MacOS/tun`
    

The built binaries should be Mach-O PowerPC objects.

Example verification:

```sh
file tap.kext/Contents/MacOS/tap
file tun.kext/Contents/MacOS/tun
```

Expected result:

- `Mach-O object ppc`
    

## Notes About File Modes

The repository was normalized to remove incorrect executable bits from non-executable files.

Relevant consequences:

- build outputs may need explicit executable permissions after build verification
    
- Xcode-generated user/build artifacts should not be committed
    

Ignored paths now include:

- `build/`
    
- `*.pbxuser`
    

## Recommended Build Verification

After building:

```sh
ls -la tap.kext tun.kext
find tap.kext -maxdepth 3 -print
find tun.kext -maxdepth 3 -print
```

## Milestone

The repaired and verified Leopard/PPC build path is captured in the tag:

`leopard-ppc-tuntap-v1`

---
