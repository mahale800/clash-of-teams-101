# Final Report: Clash of Teams 101 – Breach & Defend

**Student Name**: [Your Name]
**Course**: Cybersecurity 101
**Date**: February 16, 2026

---

## 1. Executive Summary

"Clash of Teams 101" is a comprehensive cybersecurity simulation designed to demonstrate the complete lifecycle of a cyber attack and the corresponding defense mechanisms. The project establishes a "Lab in a Box" environment using Docker, where a Red Team (Attacker) targets a vulnerable application, and a Blue Team (Defender) monitors, analyzes, and blocks the attack.

This project successfully demonstrates:
-   **Automated Reconnaissance & Exploitation** using Nmap and Metasploit.
-   **Network Traffic Analysis** using tcpdump and Wireshark/tshark.
-   **Automated Incident Response** using custom scripts to enforce firewall rules.

The successful completion of this project highlights practical skills in containerization, bash scripting, network protocols, and security tools, simulating a real-world Security Operations Center (SOC) workflow.

---

## 2. Objectives

The primary objectives of this project were to:
1.  **Simulate Real-World Scenarios**: Create a safe, contained environment to practice offensive and defensive techniques.
2.  **Automate workflows**: Move beyond manual tool usage to create reusable, automated scripts for both attack and defense.
3.  **Demonstrate the "Breach & Defend" Cycle**: Show the direct cause-and-effect relationship between an attack and its detection/remediation.

---

## 3. Architecture

The project utilizes a containerized architecture for portability and isolation:

-   **Red Team (Attacker)**: A Kali Linux container equipped with offensive tools (Nmap, Metasploit).
-   **Victim**: A vulnerable web application (DVWA - Damn Vulnerable Web App) hosting a web server on port 80.
-   **Blue Team (Monitor)**: A "sidecar" container attached to the Victim's network stack, allowing it to see all traffic entering and leaving the victim.

**Network**: All containers communicate over an isolated internal Docker bridge network (`clash_net`), ensuring safety from the host system.

---

## 4. Tools & Technologies

| Category | Tool | Purpose |
| :--- | :--- | :--- |
| **Infrastructure** | Docker / Compose | Container orchestration and environment management. |
| **Operating System** | Kali Linux | Offensive security distribution. |
| **Reconnaissance** | Nmap | Network discovery and security auditing. |
| **Exploitation** | Metasploit Framework | Developing and executing exploit code. |
| **Monitoring** | tcpdump | Command-line packet analyzer. |
| **Analysis** | tshark | Network protocol analyzer (Wireshark CLI). |
| **Remediation** | iptables | User-space utility program for configuring the IP packet filter rules. |

---

## 5. Attack Simulation (Red Team)

### Reconnaissance
The Red Team initiated the attack with an automated Nmap scan (`nmap_recon.sh`).
-   **Command**: `nmap -sV -p- -Pn victim`
-   **Result**: Identified open port **80/tcp** running **Apache httpd 2.4.25**.

### Exploitation
Using the Metasploit Framework (`metasploit_attack.sh`), the Red Team executed a formulated attack plan.
-   **Modules Used**: `auxiliary/scanner/http/title`, `auxiliary/scanner/http/http_header`.
-   **Execution**: Automated via a resource script (`basic_scan.rc`) passed to `msfconsole`.
-   **Outcome**: Successfully retrieved server headers and application title, confirming the target's identity.

---

## 6. Detection Phase (Blue Team)

### Traffic Capture
The Blue Team deployed a traffic monitoring script (`capture_traffic.sh`) utilizing `tcpdump`.
-   **Method**: Configuring a sidecar container to share the victim's network namespace (`network_mode: service:victim`).
-   **Capture**: Recorded a 60-second PCAP file during the attack window.

### Analysis & Findings
The captured traffic was analyzed using `tshark` (`analyze_capture.sh`).
-   **Key Findings**:
    -   **Volume**: ~131,000 packets captured during the scan.
    -   **Protocol Hierarchy**: 99% TCP traffic.
    -   **Top Talker**: High volume of connections from Attacker IP (`172.18.0.3`) to Victim IP (`172.18.0.2`), consistent with port scanning behavior.

---

## 7. Remediation (Response)

Upon detection, the Incident Response phase was triggered (`block_attacker.sh`).

### Action Taken
-   **Legacy Support**: The script automatically patched the victim's legacy repositories to allow tool installation.
-   **Firewall Rule**: `iptables -A INPUT -s 172.18.0.3 -j DROP`
-   **Result**: ALL incoming traffic from the attacker was dropping immediately.

### Verification
-   **Ping Test**: `ping victim` failed with 100% packet loss.
-   **Scan Check**: `nmap` reported port 80 as `filtered`, confirming the firewall was active.

---

## 8. Lessons Learned

1.  **Automation is Key**: Scripting repeatable tasks (like scanning and blocking) significantly reduces response time.
2.  **Legacy Systems are Challenging**: The victim container ran an old OS (Debian Stretch), requiring specific workarounds for package management. Real-world environments often have similar legacy constraints.
3.  **Sidecar Monitoring**: Using Docker's `service:victim` networking mode is a powerful, non-intrusive way to monitor container traffic without modifying the application container itself.

---

## 9. Conclusion

The "Clash of Teams 101" project successfully established a functional, automated cyber range. It demonstrated the efficacy of proactive monitoring and automated response in neutralizing threats. The infrastructure is flexible and ready for more advanced scenarios, such as SQL Injection attacks or IDS integration with Snort/Suricata.
