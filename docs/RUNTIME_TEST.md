# Runtime Verification

## Purpose

This document records the runtime verification path used for the Leopard/PPC milestone.

The goal is to prove that the built kernel extensions are not just compilable, but actually usable.

## Tested Platform

- Mac OS X Leopard 10.5.8
- PowerPC

## 1. Build Products Confirmed

The following bundles were confirmed in the repository root:

- `tap.kext`
- `tun.kext`

Each bundle contained:

- `Contents/Info.plist`
- `Contents/MacOS/<binary>`

## 2. Built Binary Verification

The binaries were confirmed as PowerPC Mach-O objects:

```sh
file tap.kext/Contents/MacOS/tap
file tun.kext/Contents/MacOS/tun
````

Verified result:

- `Mach-O object ppc`
    

## 3. Install Into Extensions Directory

```sh
sudo cp -R tap.kext /Library/Extensions/
sudo cp -R tun.kext /Library/Extensions/
sudo chown -R root:wheel /Library/Extensions/tap.kext /Library/Extensions/tun.kext
sudo chmod -R 755 /Library/Extensions/tap.kext /Library/Extensions/tun.kext
```

## 4. Load Test

```sh
sudo kextload -t /Library/Extensions/tap.kext
sudo kextload -t /Library/Extensions/tun.kext
```

Verified result:

- both extensions appeared loadable
    
- both loaded successfully
    

## 5. Loaded Kext Verification

```sh
kextstat | grep -i -E 'tap|tun'
```

Verified result included:

- `foo.tap (1.0)`
    
- `foo.tun (1.0)`
    

## 6. Device Node Verification

```sh
ls -la /dev/tap* /dev/tun*
```

Verified result:

- `/dev/tap0` ... `/dev/tap15`
    
- `/dev/tun0` ... `/dev/tun15`
    

## 7. Root-Level Open Test

### TUN

```sh
sudo -s
exec 3<> /dev/tun0
ifconfig -a | grep tun0
exec 3>&-
exec 3<&-
exit
```

Verified result:

- opening `/dev/tun0` created `tun0`
    
- `tun0` appeared as a point-to-point interface
    

Observed interface form:

```text
tun0: flags=8850<POINTOPOINT,RUNNING,SIMPLEX,MULTICAST> mtu 1500
```

### TAP

```sh
sudo -s
exec 3<> /dev/tap0
ifconfig -a | grep tap0
exec 3>&-
exec 3<&-
exit
```

Verified result:

- opening `/dev/tap0` created `tap0`
    
- `tap0` appeared as a broadcast interface
    

Observed interface form:

```text
tap0: flags=8842<BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
```

## 8. Non-root Device Access Test

Device ownership was adjusted temporarily to allow the `admin` user to open the devices directly:

```sh
sudo chgrp admin /dev/tun* /dev/tap*
sudo chmod 660 /dev/tun* /dev/tap*
```

After this, `admin` could open:

- `/dev/tun0`
    
- `/dev/tap0`
    

without `sudo`.

## 9. Interface Configuration Test

### TUN

```sh
exec 3<> /dev/tun0
sudo ifconfig tun0 10.23.0.1 10.23.0.2 up
ifconfig tun0
exec 3>&-
exec 3<&-
```

Verified result:

```text
tun0: flags=8851<UP,POINTOPOINT,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	inet 10.23.0.1 --> 10.23.0.2 netmask 0xff000000
	open (pid ...)
```

### TAP

```sh
exec 3<> /dev/tap0
sudo ifconfig tap0 inet 10.24.0.1 netmask 255.255.255.0 up
ifconfig tap0
exec 3>&-
exec 3<&-
```

Verified result:

```text
tap0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	inet 10.24.0.1 netmask 0xffffff00 broadcast 10.24.0.255
	ether ...
	open (pid ...)
```

## Conclusion

The Leopard/PPC runtime milestone is verified.

Confirmed working:

- kext build
    
- kext load
    
- device node creation
    
- interface creation on open
    
- userspace device open
    
- interface configuration via `ifconfig`
    

Leopard selects localized resources from the user's ordered AppleLanguages preference list and uses the first matching .lproj directory.

This milestone is tagged as:

`leopard-ppc-tuntap-v1`

## 10. Roundtrip Verification

A full installer roundtrip was verified:

- install from package
- runtime validation
- uninstall via `scripts/uninstall-tntpsx.sh`
- clean-state verification
- reinstall from package
- post-reinstall verification

Milestone tag:

`leopard-ppc-installer-roundtrip-v1`

## 11. Data-Path Smoke Tests

After build, install, uninstall, reinstall, and namespace verification, a final data-path smoke test was performed for both `tun` and `tap`.

### TUN data-path smoke test

A userspace reader opened `/dev/tun0`, the interface was configured, and a single ICMP echo request was triggered toward the peer address.

Test flow:

```sh id="q8d3tz"
./tools/test_tun.sh
````

Observed result:

- `/dev/tun0` opened successfully
    
- `tun0` was configured successfully
    
- an 84-byte packet was read from the device
    
- the packet began with `45 00`, indicating an IPv4 header
    
- the payload included an ICMP echo request
    

Observed hex prefix:

```text
45 00 00 54 ...
```

Conclusion:

- kernel-to-userspace packet delivery through `tun0` is working
    
- the TUN data path is functionally verified on Leopard/PPC
    

### TAP data-path smoke test

A userspace reader opened `/dev/tap0`, the interface was configured, and traffic was triggered toward a non-present host to provoke layer-2 activity.

Test flow:

```sh
./tools/test_tap.sh
```

Observed result:

- `/dev/tap0` opened successfully
    
- `tap0` was configured successfully
    
- a 42-byte frame was read from the device
    
- the frame began with broadcast destination MAC `ff ff ff ff ff ff`
    
- EtherType `08 06` indicated ARP traffic
    

Observed hex prefix:

```text
ff ff ff ff ff ff ... 08 06 ...
```

Conclusion:

- kernel-to-userspace frame delivery through `tap0` is working
    
- the TAP data path is functionally verified on Leopard/PPC
    

## 12. Boot-Cycle Regression Test

A dedicated reboot regression flow was added for the Leopard/PPC recovery line.

Tool:

```sh id="46118"
./tools/test_boot_cycle.sh prep
./tools/test_boot_cycle.sh verify
````

or, for immediate reboot preparation:

```sh
./tools/test_boot_cycle.sh prep-reboot
```

### Purpose

The boot-cycle test verifies that `tntpsx` remains operational after an actual restart without requiring manual post-boot recovery steps.

### Post-Boot Verification Scope

The verification phase checks:

- `/Library/StartupItems/tap` exists
    
- `/Library/StartupItems/tun` exists
    
- `org.tntpsx.tun` is loaded
    
- `org.tntpsx.tap` is loaded
    
- `/dev/tun0` exists
    
- `/dev/tap0` exists
    

It then reruns:

- `./tools/test_tun.sh`
    
- `./tools/test_tap.sh`
    
- `./tools/test_reopen_tun.sh 20`
    
- `./tools/test_reopen_tap.sh 20`
    

### Interpretation

A successful boot-cycle test means that the Leopard/PPC recovery line is not only installable and runtime-functional in-session, but also survives a real restart and returns to a verified working state through the intended startup path.

## Final Runtime Conclusion

The Leopard/PPC recovery line is now verified across:

- build
    
- package build
    
- package install
    
- uninstall
    
- reinstall
    
- kext loading
    
- device node creation
    
- interface creation
    
- interface configuration
    
- TUN packet data path
    
- TAP frame data path
    

This establishes `tntpsx` as a functionally verified Leopard/PPC TUN/TAP recovery line.

---
