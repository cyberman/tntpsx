#!/bin/bash
set -u

ITERATIONS="${1:-100}"
LOGFILE="${2:-tools/test_reopen_tap_isolated.log}"
MDNS_PLIST="/System/Library/LaunchDaemons/com.apple.mDNSResponder.plist"
MDNS_WAS_RUNNING=0

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    echo "[$(timestamp)] $*" | tee -a "$LOGFILE"
}

restore_mdns() {
    if [ "$MDNS_WAS_RUNNING" -eq 1 ]; then
        log "Restoring mDNSResponder"
        launchctl load -w "$MDNS_PLIST" >/dev/null 2>&1 || true
    fi
}

trap restore_mdns EXIT INT TERM

: > "$LOGFILE"

if launchctl list | grep -q "mDNSResponder"; then
    MDNS_WAS_RUNNING=1
    log "Stopping mDNSResponder for isolated tap hardening"
    launchctl unload -w "$MDNS_PLIST" >/dev/null 2>&1 || true
    killall mDNSResponder 2>/dev/null || true
else
    log "mDNSResponder already inactive"
fi

log "Running isolated tap reopen hardening test"
./tools/test_reopen_tap.sh "$ITERATIONS" "$LOGFILE"

log "Isolated tap reopen hardening test finished"

