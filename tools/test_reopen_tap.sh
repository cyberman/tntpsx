#!/bin/bash
set -u

ITERATIONS="${1:-20}"
FAILURES=0
IMMEDIATE_UP=0
SHORT_DELAY_UP=0
LATE_DELAY_UP=0
HARD_FAIL=0
LOGFILE="${2:-tools/test_reopen_tap.log}"

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

classify_up_transition() {
    iface="$1"
    tries=0

    if ifconfig "$iface" 2>/dev/null | grep -q 'UP'; then
        echo "immediate"
        return 0
    fi

    while [ "$tries" -lt 30 ]; do
        sleep 0.1
        tries=$((tries + 1))

        if ifconfig "$iface" 2>/dev/null | grep -q 'UP'; then
            if [ "$tries" -le 10 ]; then
                echo "short"
            else
                echo "late"
            fi
            return 0
        fi
    done

    echo "timeout"
    return 1
}

close_fd3() {
    exec 3>&- 2>/dev/null || true
    exec 3<&- 2>/dev/null || true
}

dump_diag() {
    iter="$1"

    log "---- BEGIN DIAGNOSTICS (iteration $iter) ----"

    log "ifconfig tap0:"
    ifconfig tap0 2>&1 | tee -a "$LOGFILE"

    log "kextstat grep org.tntpsx:"
    kextstat | grep -i 'org.tntpsx' 2>&1 | tee -a "$LOGFILE" || true

    log "device node state:"
    ls -la /dev/tap0 2>&1 | tee -a "$LOGFILE" || true

    log "recent system log:"
    tail -n 20 /var/log/system.log 2>&1 | tee -a "$LOGFILE" || true

    log "---- END DIAGNOSTICS (iteration $iter) ----"
}

cleanup() {
    close_fd3
}
trap cleanup EXIT INT TERM

: > "$LOGFILE"

log "TAP reopen hardening test"
log "Iterations: $ITERATIONS"
log "Logfile: $LOGFILE"

i=1
while [ "$i" -le "$ITERATIONS" ]; do
    log "Iteration $i/$ITERATIONS"

    if ! exec 3<> /dev/tap0; then
        log "ERROR: Cannot open /dev/tap0"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
        i=$((i + 1))
        continue
    fi

    if ! wait_for_iface_present tap0; then
        log "ERROR: tap0 did not appear after open"
        dump_diag "$i"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
        close_fd3
        i=$((i + 1))
        continue
    fi

    if ! ifconfig tap0 inet 10.24.0.1 netmask 255.255.255.0 up >/dev/null 2>&1; then
        log "ERROR: Could not configure tap0"
        dump_diag "$i"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
        close_fd3
        i=$((i + 1))
        continue
    fi

    state="$(classify_up_transition tap0)"

    case "$state" in
        immediate)
            log "STATUS: tap0 is immediately UP"
            IMMEDIATE_UP=$((IMMEDIATE_UP + 1))
            ;;
        short)
            log "STATUS: tap0 became UP after short delay"
            SHORT_DELAY_UP=$((SHORT_DELAY_UP + 1))
            ;;
        late)
            log "STATUS: tap0 became UP after late delay"
            LATE_DELAY_UP=$((LATE_DELAY_UP + 1))
            ;;
        timeout)
            log "ERROR: tap0 never reached UP state within 3 seconds"
            dump_diag "$i"
            FAILURES=$((FAILURES + 1))
            HARD_FAIL=$((HARD_FAIL + 1))
            ;;
        *)
            log "ERROR: Unknown UP-state classification: $state"
            dump_diag "$i"
            FAILURES=$((FAILURES + 1))
            HARD_FAIL=$((HARD_FAIL + 1))
            ;;
    esac

    close_fd3

    if ! wait_for_iface_absent tap0; then
        log "ERROR: tap0 did not disappear after close"
        dump_diag "$i"
        FAILURES=$((FAILURES + 1))
        HARD_FAIL=$((HARD_FAIL + 1))
    fi

    i=$((i + 1))
done

log "TAP reopen test completed"
log "Failures: $FAILURES"
log "Immediate UP: $IMMEDIATE_UP"
log "Short delay UP: $SHORT_DELAY_UP"
log "Late delay UP: $LATE_DELAY_UP"
log "Hard failures: $HARD_FAIL"

if [ "$FAILURES" -ne 0 ]; then
    exit 1
fi

exit 0
