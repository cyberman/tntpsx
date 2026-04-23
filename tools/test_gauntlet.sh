#!/bin/bash
set -u

LOGFILE="${1:-tools/test_gauntlet.log}"
FAILURES=0

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    echo "[$(timestamp)] $*" | tee -a "$LOGFILE"
}

run_step() {
    name="$1"
    shift

    log "==> START: $name"
    if "$@" 2>&1 | tee -a "$LOGFILE"; then
        log "==> PASS: $name"
    else
        log "==> FAIL: $name"
        FAILURES=$((FAILURES + 1))
    fi
}

ensure_loaded() {
    if ! kextstat | grep -q 'org.tntpsx.tun'; then
        log "Loading /Library/Extensions/tun.kext"
        kextload /Library/Extensions/tun.kext || return 1
    fi

    if ! kextstat | grep -q 'org.tntpsx.tap'; then
        log "Loading /Library/Extensions/tap.kext"
        kextload /Library/Extensions/tap.kext || return 1
    fi

    return 0
}

: > "$LOGFILE"

log "tntpsx gauntlet started"
log "Logfile: $LOGFILE"

if ! ensure_loaded; then
    log "ERROR: Could not ensure kexts are loaded"
    exit 1
fi

run_step "tun reopen x100" ./tools/test_reopen_tun.sh 100
run_step "tap reopen x100" ./tools/test_reopen_tap.sh 100
run_step "unload while open" ./tools/test_unload_while_open.sh

# Repeat data-path smoke a few times to catch flaky behavior.
i=1
while [ "$i" -le 10 ]; do
    run_step "tun datapath smoke #$i" ./tools/test_tun.sh
    run_step "tap datapath smoke #$i" ./tools/test_tap.sh
    i=$((i + 1))
done

log "Final kext state:"
kextstat | grep -i 'org.tntpsx' 2>&1 | tee -a "$LOGFILE" || true

log "Final device state:"
ls -la /dev/tun* /dev/tap* 2>&1 | tee -a "$LOGFILE" || true

log "Gauntlet completed"
log "Failures: $FAILURES"

if [ "$FAILURES" -ne 0 ]; then
    exit 1
fi

exit 0

