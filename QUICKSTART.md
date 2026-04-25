# tntpsx - Quick Start

## Build

Open the legacy Xcode project:

` tntpsx.xcodeproj `

or build from the shell:

```sh
make
````

Expected build products in the repository root:

- `tap.kext`
    
- `tun.kext`
    

## Install

```sh
sudo cp -R tap.kext /Library/Extensions/
sudo cp -R tun.kext /Library/Extensions/
sudo chown -R root:wheel /Library/Extensions/tap.kext /Library/Extensions/tun.kext
sudo chmod -R 755 /Library/Extensions/tap.kext /Library/Extensions/tun.kext
```

## Load

```sh
sudo kextload /Library/Extensions/tap.kext
sudo kextload /Library/Extensions/tun.kext
```

## Check

```sh
kextstat | grep -i -E 'tap|tun'
ls -la /dev/tap* /dev/tun*
```
