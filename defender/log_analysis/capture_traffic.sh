#!/bin/bash

# Configuration
MONITOR_CONTAINER="monitor-sidecar"
PCAP_PATH="/pcap/attack_capture.pcap"
DURATION=60

# Navigate to script directory
cd "$(dirname "$0")"

echo "========================================"
echo "Starting Traffic Capture at $(date)"
echo "Duration: $DURATION seconds"
echo "Container: $MONITOR_CONTAINER"
echo "Output: reports/pcap/attack_capture.pcap"
echo "========================================"

# Run tcpdump inside the monitor container with a timeout
# -i eth0: Listen on the default interface (shared with victim)
# -w /pcap/...: Write to the mounted volume
# timeout: Stops the command after DURATION seconds
docker exec "$MONITOR_CONTAINER" timeout "$DURATION" tcpdump -i eth0 -w "$PCAP_PATH"

# Check exit code (124 is timeout, which is expected/success here)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 124 ] || [ $EXIT_CODE -eq 0 ]; then
    echo "Capture completed successfully."
else
    echo "Error during capture. Exit code: $EXIT_CODE"
fi

echo "========================================"
echo "Capture finished at $(date)"
