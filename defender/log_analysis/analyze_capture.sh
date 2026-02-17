#!/bin/bash

# Configuration
MONITOR_CONTAINER="monitor-sidecar"
PCAP_PATH="/pcap/attack_capture.pcap"
LOG_DIR="../../reports/defense_logs"
REPORT_FILE="$LOG_DIR/traffic_summary.txt"

# Navigate to script directory
cd "$(dirname "$0")"

# Ensure report directory exists
mkdir -p "$LOG_DIR"

echo "========================================" > "$REPORT_FILE"
echo "Traffic Analysis Report" >> "$REPORT_FILE"
echo "Generated at: $(date)" >> "$REPORT_FILE"
echo "Source PCAP: $PCAP_PATH" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"

echo "Analyzing traffic using tshark in $MONITOR_CONTAINER..."

# Use tshark inside the container to analyze the file
# -r: Read file
# -q: Quiet (don't print packet list)
# -z: Statistics

echo "--- Protocol Hierarchy ---" >> "$REPORT_FILE"
docker exec "$MONITOR_CONTAINER" tshark -r "$PCAP_PATH" -q -z io,phs >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "--- Top Talkers (IP) ---" >> "$REPORT_FILE"
# Extract Src IP, Dst IP, Dst Port and verify unique connections
docker exec "$MONITOR_CONTAINER" tshark -r "$PCAP_PATH" -T fields -e ip.src -e ip.dst -e tcp.dstport -e udp.dstport | sort | uniq -c | sort -nr | head -n 20 >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "Analysis completed." >> "$REPORT_FILE"

echo "Report saved to $REPORT_FILE"
cat "$REPORT_FILE"
