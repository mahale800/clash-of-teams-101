#!/bin/bash

# Configuration
ATTACKER_CONTAINER="attacker-kali"
VICTIM_CONTAINER="victim-dvwa"
MONITOR_CONTAINER="monitor-sidecar"
REPORT_DIR="reports"

# Helper Function
print_status() {
    echo -e "\n\033[1;34m[+] $1\033[0m"
}

print_error() {
    echo -e "\n\033[1;31m[-] $1\033[0m"
}

# Navigate to project root (assuming script is run from project root or automation/)
# If run from automation/, go up one level
if [[ "$(basename $(pwd))" == "automation" ]]; then
    cd ..
fi

print_status "Starting Clash of Teams 101 Full Pipeline..."

# 1. Start Environment
print_status "Phase 1: Environment Setup"
cd infrastructure
docker compose up -d
# Wait for containers to stabilize
sleep 5
cd ..

# Check if containers are running
if ! docker ps | grep -q "$ATTACKER_CONTAINER"; then
    print_error "Attacker container is not running. Exiting."
    exit 1
fi

print_status "Environment is ready."

# 1.5 Install Tools (if missing)
print_status "Phase 1.5: Verifying/Installing Tools"
print_status "Checking Attacker tools..."
docker exec "$ATTACKER_CONTAINER" bash -c "which nmap >/dev/null && which msfconsole >/dev/null"
if [ $? -ne 0 ]; then
    print_status "Installing Nmap and Metasploit (this may take a while)..."
    docker exec "$ATTACKER_CONTAINER" bash -c "apt update && apt install -y nmap metasploit-framework"
else
    print_status "Attacker tools are already installed."
fi

# 2. Reset Firewall (Ensure clean slate)
print_status "Cleaning up previous firewall rules..."
# We allow this to fail if iptables isn't installed yet
docker exec "$VICTIM_CONTAINER" iptables -F > /dev/null 2>&1

# 3. Start Traffic Capture (Background)
print_status "Phase 2: Starting Traffic Capture (Background)"
# Run the capture script in background. It captures for 60s by default.
bash defender/log_analysis/capture_traffic.sh &
CAPTURE_PID=$!
print_status "Capture started (PID: $CAPTURE_PID). Waiting 5s for initialization..."
sleep 5

# 4. Launch Attacks
print_status "Phase 3: Launching Attacks (Red Team)"

print_status "Running Nmap Recon..."
bash automation/attack_pipeline/nmap_recon.sh

print_status "Running Metasploit Attack..."
bash automation/attack_pipeline/metasploit_attack.sh

# 5. Wait for Capture to Finish
print_status "Waiting for traffic capture to complete..."
wait $CAPTURE_PID
print_status "Traffic capture completed."

# 6. Analyze Traffic
print_status "Phase 4: Analyzing Traffic (Blue Team)"
bash defender/log_analysis/analyze_capture.sh

# 7. Remediate (Block Attacker)
print_status "Phase 5: Automated Remediation"
bash automation/remediation/block_attacker.sh

# 8. Verify Block
print_status "Phase 6: Verifying Block"
print_status "Attempting remediation verification (Ping from Attacker)..."
if docker exec "$ATTACKER_CONTAINER" ping -c 1 -W 1 victim-dvwa > /dev/null 2>&1; then
    print_error "Verification Failed! Attacker can still ping victim."
else
    print_status "Verification Successful! Attacker cannot ping victim."
fi

print_status "=========================================="
print_status "FULL PIPELINE COMPLETED SUCCESSFULLY"
print_status "Reports available in $REPORT_DIR/"
print_status "=========================================="
