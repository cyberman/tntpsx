#!/bin/bash
set -u

ITERATIONS="${1:-20}"
FAILURES=0
IMMEDIATE_UP=0
DELAYED_UP=0
HARD_FAIL=0
LOGFILE="${2:-tools/test_reopen_tun.log}"

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    echo "[$(timestamp)] $*" | tee -a "$LOGFILE"
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

wait_for_up_flag() {
    iface="$1"
    tries=0
    while [ "$tries" -lt 10 ]; do
        if ifconfig "$iface" 2>/dev/null | grep -q 'UP'; then
            return 0
        fi
        sleep 0.1
        tries=$((tries + 1))
    done
    return 1
}

close_fd3() {
    exec 3>&- 2>/dev/null || true
    exec 3<&- 2>/dev/null || true
}

dump_diag() {
    iter="$1"

    log "---- BEGIN DIAGNOSTICS (iteration $iter) ----"

    log "ifconfig tun0:"
    ifconfig tun0 2>&1 | tee -a "$LOGFILE"

    log "kextstat grep org.tntpsx:"
    kextstat | grep -i 'org.tntpsx' 2>&1 | tee -a "$LOGFILE" || true

    log "device node state:"
    ls -la /dev/tun0 2>&1 | tee -a "$LOGFILE" || true

    log "recent system log:"
    tail -n 20 /var/log/system.log 2>&1 | tee -a "$LOGFILE" || true

    log "---- END DIAGNOSTICS (iteration $iter) ----"
}

cleanup() {
    close_fd3
}
trap cleanup EXIT INT TERM

: > "$LOGFILE"

log "TUN reopen hardening test"
log "Iterations: $ITERATIONS"
log "Logfile: $LOGFILE"

i=1
while [ "$i" -le "$ITERATIONS" ]; do
    log "Iteration $i/$ITERATIONS"

    if ! exec 3<> /dev/tun0; then
        log "ERROR: Cannot open /dev/tun0"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
        i=$((i + 1))
        continue
    fi

    if ! wait_for_iface_present tun0; then
        log "ERROR: tun0 did not appear after open"
        dump_diag "$i"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
        close_fd3
        i=$((i + 1))
        continue
    fi

    if ! ifconfig tun0 10.23.0.1 10.23.0.2 up >/dev/null 2>&1; then
        log "ERROR: Could not configure tun0"
        dump_diag "$i"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
        close_fd3
        i=$((i + 1))
        continue
    fi

    if ifconfig tun0 | grep -q 'UP'; then
        log "STATUS: tun0 is immediately UP"
        IMMEDIATE_UP=$((IMMEDIATE_UP + 1))
    elif wait_for_up_flag tun0; then
        log "STATUS: tun0 became UP after short delay"
        DELAYED_UP=$((DELAYED_UP + 1))
    else
        log "ERROR: tun0 never reached UP state"
        dump_diag "$i"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
    fi

    close_fd3

    if ! wait_for_iface_absent tun0; then
        log "ERROR: tun0 did not disappear after close"
        dump_diag "$i"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
    fi

    i=$((i + 1))
done

log "TUN reopen test completed"
log "Failures: $FAILURES"
log "Immediate UP: $IMMEDIATE_UP"
log "Delayed UP: $DELAYED_UP"
log "Hard failures: $HARD_FAIL"

if [ "$FAILURES" -ne 0 ]; then
    exit 1
fi

exit 0
