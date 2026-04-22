#!/bin/bash
set -u

ITERATIONS="${1:-20}"
FAILURES=0

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

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

wait_for_iface_absent() {
    iface="$1"
    tries=0
    while [ "$tries" -lt 10 ]; do
        if ! ifconfig "$iface" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        tries=$((tries + 1))
    done
    return 1
}

close_fd3() {
    exec 3>&- 2>/dev/null || true
    exec 3<&- 2>/dev/null || true
}

cleanup() {
    close_fd3
}
trap cleanup EXIT INT TERM

echo "==> TAP reopen hardening test"
echo "==> Iterations: $ITERATIONS"

i=1
while [ "$i" -le "$ITERATIONS" ]; do
    echo "==> Iteration $i/$ITERATIONS"

    if ! exec 3<> /dev/tap0; then
        echo "ERROR: Cannot open /dev/tap0"
        FAILURES=$((FAILURES + 1))
        i=$((i + 1))
        continue
    fi

    if ! wait_for_iface_present tap0; then
        echo "ERROR: tap0 did not appear after open"
        FAILURES=$((FAILURES + 1))
        close_fd3
        i=$((i + 1))
        continue
    fi

    if ! ifconfig tap0 inet 10.24.0.1 netmask 255.255.255.0 up >/dev/null 2>&1; then
        echo "ERROR: Could not configure tap0"
        FAILURES=$((FAILURES + 1))
        close_fd3
        i=$((i + 1))
        continue
    fi

    if ! ifconfig tap0 | grep -q 'UP'; then
        echo "ERROR: tap0 is not UP after configuration"
        FAILURES=$((FAILURES + 1))
    fi

    close_fd3

    if ! wait_for_iface_absent tap0; then
        echo "ERROR: tap0 did not disappear after close"
        FAILURES=$((FAILURES + 1))
    fi

    i=$((i + 1))
done

echo "==> TAP reopen test completed"
echo "==> Failures: $FAILURES"

if [ "$FAILURES" -ne 0 ]; then
    exit 1
fi

exit 0

