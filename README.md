# Clash of Teams 101 – Breach & Defend

> **A "Lab in a Box" Cybersecurity Simulation** showing the complete lifecycle of a cyber attack: from automated reconnaissance and exploitation to real-time detection and automated incident response.

![GitHub release (latest by date)](https://img.shields.io/github/v/release/yashmahale/clash-of-teams-101?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)

---

## 📖 Project Overview

**Clash of Teams 101** is a fully containerized cybersecurity range designed to demonstrate Red Team (Offense) and Blue Team (Defense) operations in a safe, controlled environment.

This project simulates a real-world scenario where:
1.  **Red Team**: Automatically scans and exploits a vulnerable web server.
2.  **Blue Team**: Captures network traffic and analyzes it for malicious patterns.
3.  **Purple Team (Response)**: Automatically triggers a firewall rule to block the attacker in real-time.

### Key Features
-   ✅ **Dockerized Environment**: Zero-dependency setup (just Docker & Compose).
-   ✅ **Automated Attack Pipeline**: Bash scripts driving Nmap and Metasploit.
-   ✅ **Sidecar Monitoring**: Network traffic capture without modifying the victim container.
-   ✅ **Automated Remediation**: Scripted response that patches the victim and blocks the threat.
-   ✅ **Detailed Reporting**: Generates PCAP files and log analysis reports.

---

## 🏗️ Architecture

The lab consists of three isolated containers running on an internal bridge network (`clash_net`).

```mermaid
graph TD
    subgraph "Internal Network (clash_net)"
        Attacker[Kali Linux<br/>(Red Team)]
        Victim[DVWA Web App<br/>(Target)]
        Monitor[Netshoot<br/>(Blue Team)]
    end

    Attacker -- "1. Scans & Exploits" --> Victim
    Monitor -. "2. Captures Traffic (Sidecar)" .-> Victim
    Monitor -- "3. Analyzes Logs" --> Report[Detection Report]
    Victim -- "4. Blocks IP" --> Firewall[iptables DROP]

    style Attacker fill:#ffcccc,stroke:#ff0000,stroke-width:2px
    style Victim fill:#ffffcc,stroke:#aaaa00,stroke-width:2px
    style Monitor fill:#ccffcc,stroke:#00aa00,stroke-width:2px
```

---

## 🚀 Getting Started

### Prerequisites
-   **Docker** and **Docker Compose** installed.
-   4GB+ RAM recommended.
-   Linux/Mac/WSL2 environment (for running bash scripts).

### 1. Setup
Clone the repository and start the environment:

```bash
cd infrastructure
docker-compose up -d
```

### 2. Run the Full Simulation
We have provided a master script that runs the entire pipeline (Attack -> Detect -> Defend) in one go:

```bash
# From the project root
bash automation/run_full_pipeline.sh
```

**What happens?**
1.  **Environment Check**: Verifies containers are running.
2.  **Traffic Capture**: Starts a background packet capture on the `monitor` container.
3.  **Attack**: Launches Nmap and Metasploit against the `victim`.
4.  **Analysis**: Processes the PCAP file and generates a traffic summary.
5.  **Remediation**: Automatically installs `iptables` on the victim and blocks the attacker.
6.  **Verification**: Confirms the attacker is blocked via a ping test.

---

## 📂 Project Structure

```
clash-of-teams-101/
├── README.md              # Project Documentation
├── LICENSE                # MIT License
├── .gitignore             # Git Configuration
├── automation/
│   ├── attack_pipeline/   # Red Team Scripts (Nmap, Metasploit)
│   ├── remediation/       # Blue Team Response (iptables blocking)
│   └── run_full_pipeline.sh # Master Automation Script
├── defender/
│   └── log_analysis/      # Blue Team Detection (tcpdump, tshark)
├── docs/
│   ├── final_report.md    # Comprehensive Academic Report
│   └── setup.md           # Detailed setup guide
├── infrastructure/
│   └── docker-compose.yml # Lab Environment Definition
└── reports/               # Generated Artifacts (Logs, PCAPs)
```

---

## 📊 Sample Output

### Detection Report (`reports/defense_logs/traffic_summary.txt`)
```text
=== Top Talkers ===
1000 packets: 172.18.0.3 -> 172.18.0.2 (Port Scanning)
...
```

### Blocking Log (`reports/remediation_logs/block_log.txt`)
```text
Mon Feb 16 19:40:00 UTC 2026 | ACTION: Blocked IP 172.18.0.3 | CONTAINER: victim-dvwa
```

---

## 📸 Screenshots

*(Placeholders for your project submission)*

1.  **Metasploit Console Output**
    
    ![Metasploit](img/metasploit_screenshot.png)

2.  **Traffic Analysis Report**
    
    ![Analysis](img/analysis_screenshot.png)

3.  **Blocked Ping Verification**
    
    ![Blocked](img/blocked_screenshot.png)

---

## 👤 Author

**Yash Mahale**
-   Year: 2026
-   License: MIT
