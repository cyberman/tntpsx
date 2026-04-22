#!/bin/sh
#
# uninstall-tntpsx.sh
#
# Clean removal script for tntpsx on Mac OS X Leopard / PowerPC.
#

set -u

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

log() {
    echo "==> $*"
}

require_root() {
    if [ "$(id -u)" != "0" ]; then
        fail "This script must be run as root. Use: sudo $0"
    fi
}

unload_kext_if_present() {
    kext_path="$1"

    if [ -d "$kext_path" ]; then
        log "Attempting to unload $kext_path"
        if kextunload "$kext_path" 2>/dev/null; then
            log "Unloaded $kext_path"
        else
            log "Could not unload $kext_path (continuing)"
        fi
    fi
}

remove_path_if_present() {
    target="$1"

    if [ -e "$target" ] || [ -L "$target" ]; then
        log "Removing $target"
        rm -rf "$target" || fail "Failed to remove $target"
    else
        log "Not present: $target"
    fi
}

main() {
    require_root

    log "Starting tntpsx uninstall"

    unload_kext_if_present "/Library/Extensions/tap.kext"
    unload_kext_if_present "/Library/Extensions/tun.kext"
    unload_kext_if_present "/System/Library/Extensions/tap.kext"
    unload_kext_if_present "/System/Library/Extensions/tun.kext"

    remove_path_if_present "/Library/Extensions/tap.kext"
    remove_path_if_present "/Library/Extensions/tun.kext"
    remove_path_if_present "/Library/StartupItems/tap"
    remove_path_if_present "/Library/StartupItems/tun"

    remove_path_if_present "/System/Library/Extensions/tap.kext"
    remove_path_if_present "/System/Library/Extensions/tun.kext"
    remove_path_if_present "/System/Library/StartupItems/tap"
    remove_path_if_present "/System/Library/StartupItems/tun"

    #
    # Old PackageMaker receipts are optional cleanup.
    #
    for receipt in /Library/Receipts/tuntap*.pkg /Library/Receipts/TunTap*.pkg; do
        if [ -e "$receipt" ]; then
            log "Removing receipt $receipt"
            rm -rf "$receipt" || fail "Failed to remove receipt $receipt"
        fi
    done

    log "Verification summary"
    ls -ld /Library/Extensions/tap.kext /Library/Extensions/tun.kext 2>/dev/null
    ls -ld /Library/StartupItems/tap /Library/StartupItems/tun 2>/dev/null
    kextstat | grep -i -E 'foo.tap|foo.tun|tap|tun' || true
    ls -la /dev/tap* /dev/tun* 2>/dev/null || true

    log "tntpsx uninstall completed"
}

main "$@"
