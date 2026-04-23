#!/bin/bash
set -u

STATE_FILE="/var/tmp/tntpsx_boot_cycle.state"
LOGFILE="$(pwd)/tools/test_boot_cycle.log"
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

fail() {
    log "ERROR: $*"
    FAILURES=$((FAILURES + 1))
}

usage() {
    cat <<'EOF'
Usage:
  ./tools/test_boot_cycle.sh prep
  ./tools/test_boot_cycle.sh prep-reboot
  ./tools/test_boot_cycle.sh verify
  ./tools/test_boot_cycle.sh clean

Modes:
  prep         Prepare the boot regression test and stop.
  prep-reboot  Prepare the boot regression test and reboot immediately.
  verify       Verify post-boot state and run smoke checks.
  clean        Remove boot-cycle state file.
EOF
}

require_repo_root() {
    if [ ! -x "./tools/test_tun.sh" ] || [ ! -x "./tools/test_tap.sh" ]; then
        echo "Run this script from the tntpsx repository root." >&2
        exit 1
    fi
}

prepare_state() {
    : > "$LOGFILE"

    log "Preparing tntpsx boot regression test"

    cat > "$STATE_FILE" <<EOF
prepared_at=$(timestamp)
repo_root=$(pwd)
expected_tun=org.tntpsx.tun
expected_tap=org.tntpsx.tap
EOF

    log "State file written: $STATE_FILE"
    log "Repo root recorded: $(pwd)"
    log "Expected bundle IDs:"
    log "  - org.tntpsx.tun"
    log "  - org.tntpsx.tap"
    log "Preparation complete"
    log "Next step: reboot, then run:"
    log "  sudo ./tools/test_boot_cycle.sh verify"
}

verify_kext_loaded() {
    bundle="$1"
    if kextstat | grep -q "$bundle"; then
        log "PASS: kext loaded: $bundle"
    else
        fail "kext not loaded after boot: $bundle"
    fi
}

verify_device_exists() {
    dev="$1"
    if [ -e "$dev" ]; then
        log "PASS: device exists: $dev"
    else
        fail "device missing after boot: $dev"
    fi
}

verify_startup_item_exists() {
    path="$1"
    if [ -d "$path" ]; then
        log "PASS: startup item present: $path"
    else
        fail "startup item missing: $path"
    fi
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

verify_phase() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "No boot-cycle state file found: $STATE_FILE" >&2
        echo "Run './tools/test_boot_cycle.sh prep' before rebooting." >&2
        exit 1
    fi

    log "Starting post-boot verification"
    log "Using state file: $STATE_FILE"

    verify_startup_item_exists "/Library/StartupItems/tap"
    verify_startup_item_exists "/Library/StartupItems/tun"

    verify_kext_loaded "org.tntpsx.tun"
    verify_kext_loaded "org.tntpsx.tap"

    verify_device_exists "/dev/tun0"
    verify_device_exists "/dev/tap0"

    log "Current kext state:"
    kextstat | grep -i 'org.tntpsx' 2>&1 | tee -a "$LOGFILE" || true

    log "Current device state:"
    ls -la /dev/tun* /dev/tap* 2>&1 | tee -a "$LOGFILE" || true

    run_step "tun datapath smoke after boot" ./tools/test_tun.sh
    run_step "tap datapath smoke after boot" ./tools/test_tap.sh
    run_step "tun reopen x20 after boot" ./tools/test_reopen_tun.sh 20
    run_step "tap reopen x20 after boot" ./tools/test_reopen_tap.sh 20

    log "Boot-cycle verification completed"
    log "Failures: $FAILURES"

    if [ "$FAILURES" -eq 0 ]; then
        log "Boot regression result: PASS"
        rm -f "$STATE_FILE"
        log "State file removed"
        exit 0
    else
        log "Boot regression result: FAIL"
        exit 1
    fi
}

clean_state() {
    rm -f "$STATE_FILE"
    echo "Removed $STATE_FILE"
}

main() {
    require_repo_root

    mode="${1:-}"

    case "$mode" in
        prep)
            prepare_state
            ;;
        prep-reboot)
            prepare_state
            log "Rebooting now..."
            shutdown -r now
            ;;
        verify)
            verify_phase
            ;;
        clean)
            clean_state
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"

