# Lightweight Lab Setup Guide

This guide explains how to use the simplified Kali-Metasploitable-Monitor environment.

## 1. Start the Environment
Navigate to the infrastructure folder and start the containers:
```bash
cd infrastructure
docker-compose up -d
```

## 2. Access the Attacker (Red Team)
To access the Kali Linux terminal:
```bash
docker exec -it attacker-kali /bin/bash
```
```
*Note: The Kali image is minimal. You must install tools manually:*
```bash
apt update && apt install -y iputils-ping nmap metasploit-framework
```

## 3. Capture Traffic (Blue Team)
The `monitor-sidecar` container is attached to the victim's network interface.
To start a capture:
```bash
docker exec -it monitor-sidecar tcpdump -i eth0 -w /pcap/capture.pcap
```
Press `Ctrl+C` to stop capturing. The file will be saved in `reports/pcap/capture.pcap`.

## 4. Verify Components
- **Attacker IP**: 172.50.0.100
- **Victim IP**: 172.50.0.20

From Attacker:
```bash
ping 172.50.0.20
nmap -p- 172.50.0.20
```

## 5. View Logs (Wireshark)
Open the generated `.pcap` file in Wireshark on your host machine to analyze the traffic.
