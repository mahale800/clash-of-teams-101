#!/bin/bash

# Configuration
ATTACKER_CONTAINER="attacker-kali"
RESOURCE_SCRIPT="/root/attacks/automation/attack_pipeline/resources/basic_scan.rc"
HOST_RESOURCE_PATH="../automation/attack_pipeline/resources/basic_scan.rc"
LOG_DIR="../../reports/attack_logs"
LOG_FILE="$LOG_DIR/metasploit_scan.txt"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Timestamp
echo "========================================" >> "$LOG_FILE"
echo "Starting Metasploit Automation at $(date)" >> "$LOG_FILE"
echo "Resource Script: $HOST_RESOURCE_PATH" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# We need to make sure the resource script is available inside the container.
# docker-compose maps `../attacks` to `/root/attacks`.
# Since this script is running from `automation/attack_pipeline`, 
# the relative path `resources/basic_scan.rc` map to `/root/attacks/automation/attack_pipeline/resources/basic_scan.rc`
# IF the `attacks` volume mapping encompasses this folder.
# CHECK: docker-compose volumes: - ../attacks:/root/attacks
# `attacks` folder is at root/clash-of-teams-101/attacks.
# `automation` folder is at root/clash-of-teams-101/automation.
# THEY ARE DIFFERENT FOLDERS. Separation of concerns.

# PROBLEM: The automation folder is NOT mounted in the Kali container by default.
# FIX: checking docker-compose.yml...
# `volumes: - ../attacks:/root/attacks`
# The `automation` folder is NOT in `attacks`.

# Navigate to script directory to ensure relative paths work
cd "$(dirname "$0")"

# TEMPORARY FIX: Copy the resource script into the container before running.
echo "Copying resource script to container..."
docker cp ./resources/basic_scan.rc "$ATTACKER_CONTAINER":/root/basic_scan.rc

# Check if msfconsole is installed
if ! docker exec "$ATTACKER_CONTAINER" which msfconsole > /dev/null; then
  echo "ERROR: msfconsole not found in $ATTACKER_CONTAINER."
  echo "Please run: docker exec $ATTACKER_CONTAINER apt update && apt install -y metasploit-framework"
  exit 1
fi

echo "Running Metasploit..."
docker exec "$ATTACKER_CONTAINER" msfconsole -r /root/basic_scan.rc | tee -a "$LOG_FILE"

echo "========================================" >> "$LOG_FILE"
echo "Metasploit completed at $(date)" >> "$LOG_FILE"
echo "Results saved to $LOG_FILE"
