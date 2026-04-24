# Changelog

## Unreleased

### Added
- Modern repository documentation set in `docs/`
- Verified Leopard/PPC milestone tag `leopard-ppc-tuntap-v1`
- Added formal hardening documentation for lifecycle and stress-validation of the Leopard/PPC recovery line
- Added `tools/test_boot_cycle.sh` for reboot regression validation

### Changed
- Cleaned repository handling for legacy Xcode artifacts
- Normalized file modes across the repository
- Clarified active build root vs archival vendor tree
- Separated historical upstream base from the current recovery-line product version
- Defined `0.1.0` as the current `tntpsx` product version
- Renamed package output from historical `tuntap_*` naming to `tntpsx_0.1.0.*`
- Continued aligning installer and package identity with the `tntpsx` product name
- Extended the hardening process to include explicit boot/reboot regression testing
- Refined TAP reopen hardening tests to distinguish immediate, short-delay, and late-delay UP transitions
- Added isolated TAP reopen testing without `mDNSResponder`
- Reclassified previously observed TAP reopen "hard failures" as timing-sensitive state transitions where appropriate

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
- TUN data path verified with an outbound ICMP packet read from `/dev/tun0`
- TAP data path verified with an ARP broadcast frame read from `/dev/tap0`
- Full userspace smoke tests verified for both `tun` and `tap` after package reinstall
- Boot-cycle regression path verified using `tools/test_boot_cycle.sh`
- post-boot startup-item, kext, device-node, smoke-test, and reopen-test validation completed successfully
- calibrated TAP reopen hardening no longer reproduces hard failure in the current verified runs
- isolated TAP reopen hardening without `mDNSResponder` no longer reproduces hard failure in the current verified runs
- TAP reopen hardening now distinguishes immediate, short-delay, and late-delay visible `UP` transitions

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

### tntpsx-0.1.0-rc1
- release candidate status established for Leopard/PPC
- TUN packet data path verified
- TAP frame data path verified
- build, packaging, install, uninstall, reinstall, and runtime data path all verified together

