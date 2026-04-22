#!/bin/bash
set -u

FAILURES=0

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

close_fd3() {
    exec 3>&- 2>/dev/null || true
    exec 3<&- 2>/dev/null || true
}

wait_for_iface_present() {
    iface="$1"
    tries=0
    while [ "$tries" -lt 10 ]; do
        if ifconfig "$iface" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        tries=$((tries + 1))
    done
    return 1
}

ensure_loaded() {
    bundle="$1"
    path="$2"

    if ! kextstat | grep -q "$bundle"; then
        echo "==> Loading $bundle"
        if ! kextload "$path"; then
            echo "ERROR: Could not load $path"
            FAILURES=$((FAILURES + 1))
            return 1
        fi
    fi

    return 0
}

test_one() {
    kind="$1"
    bundle="$2"
    kext_path="$3"
    dev="/dev/${kind}0"
    iface="${kind}0"

    echo "==> Testing unload-while-open for $kind"

    if ! ensure_loaded "$bundle" "$kext_path"; then
        return
    fi

    if ! exec 3<> "$dev"; then
        echo "ERROR: Cannot open $dev"
        FAILURES=$((FAILURES + 1))
        return
    fi

    if ! wait_for_iface_present "$iface"; then
        echo "ERROR: $iface did not appear after open"
        FAILURES=$((FAILURES + 1))
        close_fd3
        return
    fi

    echo "==> Attempting kextunload while $iface is open"
    if kextunload "$kext_path" >/dev/null 2>&1; then
        echo "WARNING: kextunload succeeded while $iface was still open"
        echo "WARNING: This should be reviewed carefully"
        FAILURES=$((FAILURES + 1))
    else
        echo "==> kextunload was blocked while $iface was open (good)"
    fi

    close_fd3
    sleep 1

    echo "==> Attempting kextunload after close"
    if kextstat | grep -q "$bundle"; then
        if ! kextunload "$kext_path"; then
            echo "ERROR: kextunload failed after closing $iface"
            FAILURES=$((FAILURES + 1))
        else
            echo "==> kextunload succeeded after close"
        fi
    else
        echo "==> Kext already unloaded"
    fi

    echo "==> Restoring loaded state for $kind"
    if ! kextload "$kext_path"; then
        echo "ERROR: Could not reload $kext_path"
        FAILURES=$((FAILURES + 1))
    fi
}

cleanup() {
    close_fd3
}
trap cleanup EXIT INT TERM

test_one "tun" "org.tntpsx.tun" "/Library/Extensions/tun.kext"
test_one "tap" "org.tntpsx.tap" "/Library/Extensions/tap.kext"

echo "==> Unload-while-open test completed"
echo "==> Failures: $FAILURES"

if [ "$FAILURES" -ne 0 ]; then
    exit 1
fi

exit 0

