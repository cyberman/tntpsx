#!/bin/bash
set -u

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

echo "Opening /dev/tun0 reader in background..."
perl tools/read_dev.pl /dev/tun0 1 10 &
READER_PID=$!

sleep 1

echo "Configuring tun0..."
ifconfig tun0 10.23.0.1 10.23.0.2 up

echo "Sending one test packet toward 10.23.0.2..."
ping -c 1 10.23.0.2 >/dev/null 2>&1 || true

wait "$READER_PID"
echo "TUN smoke test finished."
