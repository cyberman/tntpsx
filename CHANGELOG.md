# Changelog

## Unreleased

### Added
- Modern repository documentation set in `docs/`
- Verified Leopard/PPC milestone tag `leopard-ppc-tuntap-v1`

### Changed
- Cleaned repository handling for legacy Xcode artifacts
- Normalized file modes across the repository
- Clarified active build root vs archival vendor tree
- Separated historical upstream base from the current recovery-line product version
- Defined `0.1.0` as the current `tntpsx` product version
- Renamed package output from historical `tuntap_*` naming to `tntpsx_0.1.0.*`
- Continued aligning installer and package identity with the `tntpsx` product name

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
- PackageMaker package build succeeds on Leopard/PPC
- package install succeeds
- uninstall via `scripts/uninstall-tntpsx.sh` succeeds
- reinstall succeeds
- startup item resources are preserved through package installation
- `tntpsx 0.1.0` package naming and release identity verified on the Leopard/PPC recovery line

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
- full install/uninstall/reinstall roundtrip verified
