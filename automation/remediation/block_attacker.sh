#!/bin/bash

# Configuration
VICTIM_CONTAINER="victim-dvwa"
ATTACKER_IP="attacker-kali"
LOG_DIR="../../reports/remediation_logs"
LOG_FILE="$LOG_DIR/block_log.txt"

# Navigate to script directory
cd "$(dirname "$0")"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

echo "========================================"
echo "Initiating Remediation at $(date)"
echo "Target: $VICTIM_CONTAINER"
echo "Blocking IP: $ATTACKER_IP"
echo "========================================"

# Check for iptables and install if missing
echo "Checking for iptables..."
if ! docker exec "$VICTIM_CONTAINER" which iptables > /dev/null; then
    echo "iptables not found. Fixing repos and installing..."
    # Fix for legacy Debian Stretch repositories
    docker exec "$VICTIM_CONTAINER" bash -c "echo 'deb http://archive.debian.org/debian stretch main' > /etc/apt/sources.list"
    docker exec "$VICTIM_CONTAINER" bash -c "echo 'deb http://archive.debian.org/debian-security stretch/updates main' >> /etc/apt/sources.list"
    docker exec "$VICTIM_CONTAINER" bash -c "apt-get update -o Acquire::Check-Valid-Until=false && apt-get install -y iptables --allow-unauthenticated"
else
    echo "iptables is installed."
fi

# Add blocking rule
echo "Blocking attacker..."
docker exec "$VICTIM_CONTAINER" iptables -A INPUT -s "$ATTACKER_IP" -j DROP

# Log action
echo "$(date) | ACTION: Blocked IP $ATTACKER_IP | CONTAINER: $VICTIM_CONTAINER" >> "$LOG_FILE"
echo "Block rule added."

# Verify rule
echo "--- Current iptables rules ---"
docker exec "$VICTIM_CONTAINER" iptables -L INPUT -n

echo "========================================"
echo "Remediation completed."
