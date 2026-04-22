#!/bin/bash
set -u

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

echo "Opening /dev/tap0 reader in background..."
perl tools/read_dev.pl /dev/tap0 1 10 &
READER_PID=$!

sleep 1

echo "Configuring tap0..."
ifconfig tap0 inet 10.24.0.1 netmask 255.255.255.0 up

echo "Triggering ARP/traffic toward 10.24.0.2..."
ping -c 1 10.24.0.2 >/dev/null 2>&1 || true

wait "$READER_PID"
echo "TAP smoke test finished."
