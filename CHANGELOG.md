# Changelog

## Unreleased

### Added
- Modern repository documentation set in `docs/`
- Verified Leopard/PPC milestone tag `leopard-ppc-tuntap-v1`

### Changed
- Cleaned repository handling for legacy Xcode artifacts
- Normalized file modes across the repository
- Clarified active build root vs archival vendor tree

### Fixed
- Leopard/PPC ioctl callback signature mismatch in `tuntap_if_ioctl`
- Leopard/PPC linker failure caused by unsupported `-kext` flag
- PPC-only build flow restored for `tap.kext` and `tun.kext`

### Verified
- `tap.kext` builds on Leopard 10.5.8 PPC
- `tun.kext` builds on Leopard 10.5.8 PPC
- both kexts load successfully
- `/dev/tap*` and `/dev/tun*` device nodes are created
- opening the devices creates working `tapX` and `tunX` interfaces
- runtime interface configuration works with appropriate privilege

## Verified Milestones

### leopard-ppc-tuntap-v1
- Leopard/PPC build restored
- runtime verified for `tap.kext` and `tun.kext`

### leopard-ppc-installer-roundtrip-v1
- installer package built successfully
- package install verified
- uninstall script verified
- reinstall verified
- startup item resources carried through package installation
