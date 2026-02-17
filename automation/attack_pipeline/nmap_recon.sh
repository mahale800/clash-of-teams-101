#!/bin/bash

# Configuration
ATTACKER_CONTAINER="attacker-kali"
TARGET="victim"
# Navigate to script directory
cd "$(dirname "$0")"

LOG_DIR="../../reports/attack_logs"
LOG_FILE="$LOG_DIR/nmap_scan.txt"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Timestamp
echo "========================================" >> "$LOG_FILE"
echo "Starting Nmap Recon at $(date)" >> "$LOG_FILE"
echo "Target: $TARGET" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# Run Nmap from inside the attacker container
# -sV: Service version detection
# -p-: Scan all ports
# -Pn: Treat all hosts as online (skip host discovery)
echo "Running Nmap from $ATTACKER_CONTAINER..."
docker exec "$ATTACKER_CONTAINER" nmap -sV -p- -Pn "$TARGET" | tee -a "$LOG_FILE"

echo "========================================" >> "$LOG_FILE"
echo "Scan completed at $(date)" >> "$LOG_FILE"
echo "Results saved to $LOG_FILE"
