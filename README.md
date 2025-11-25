<p align="center">
  <img src="diagrams/splunk_logo.png" alt="Splunk SIEM Home Lab Banner" width="900">
</p>

# Splunk Dual-VM SIEM Lab

This project documents a complete **Splunk SIEM Home Lab** built on macOS using two virtual machines running on UTM:

- **Ubuntu VM (Attacker)** – performs RDP brute-force, port scanning, and network recon
- **Windows 11 VM (Victim)** – generates logs (4624/4625/etc.) and forwards them to Splunk via NXLog  
- **Splunk Enterprise on macOS** – ingests logs and detects attacks in real time

This environment simulates realistic SOC/Blue-Team monitoring and detection scenarios.

---

# Architecture

<p align="center">
  <img src="diagrams/lab_diagram.png" alt="SIEM Architecture Diagram" width="800">
</p>

### **macOS Host (Splunk Server)**  
- Runs **Splunk Enterprise**
- Receives logs on **TCP 9997**
- Accessible via browser at: `http://localhost:8000`

---

### **Windows 11 ARM – Victim**
- **NIC 1 — Host-Only Network (`splunk-lab-net`):** `192.168.50.20`  
  Used for attacker ↔ victim communication
- **NIC 2 — Shared NAT:** `192.168.64.5`  
  Used for internet access
- **Log Forwarding:** NXLog → Splunk 
- Generates Security Events such as:
  - 4625 (Failed Logon)
  - 4624 (Successful Logon)
  - 4798 (Local Group Enumeration)
  - 4672 (Special Privileges Assigned)

---

### **Ubuntu 24.04 – Attacker**
- **Host-Only IP:** `192.168.50.10`
- Performs real-world attack simulations:
  - RDP brute force (via `hydra`)
  - Port scanning (`nmap`)

---

# Host-Only Network Setup

A custom **Host-Only** network was created in UTM to allow isolated communication between Ubuntu (attacker) and Windows (victim).

**Why Host-Only?**
- Creates a private lab network  
- Prevents accidents on your real LAN  
- Ensures predictable static IP addressing  
- Allows Splunk/macOS to remain isolated

### ✔ Creating the Host-Only Network  
1. Open **UTM → Settings → Network**  
2. Click **Add → Name:** `splunk-lab-net`  
3. Assign this network to:
   - Ubuntu VM (Network Mode → Host Only → `splunk-lab-net`)
   - Windows VM (Network Mode → Host Only → `splunk-lab-net`)
4. Configure IPs:
   - **Windows:** Manual IPv4 → `192.168.50.20`
   - **Ubuntu:** Netplan static config → `192.168.50.10`



# 🛠 Tools Used

Below are the main tools used across macOS, Windows, and Ubuntu:

- **Splunk Enterprise 10.x** (SIEM)
- **UTM Virtualization on macOS**
- **NXLog + Windows Event Logging**
- **Ubuntu Attack Tools:**
  - `hydra`
  - `nmap`


## Why This Lab Uses NXLog Instead of the Splunk Universal Forwarder

The Windows VM in this lab runs on **Windows 11 ARM64**.  
Splunk’s **Universal Forwarder** currently supports **Windows x64 and x86**, but it does not provide an ARM64 build.

Because of this limitation, the Universal Forwarder cannot be installed on Windows ARM systems.

To ensure reliable Windows Event Log forwarding into Splunk, this project uses:

**➡️ NXLog Community Edition**

NXLog is a lightweight and flexible log collector that **supports Windows ARM**, integrates cleanly with the Windows Event Log API, and can forward logs over **TCP 9997** directly into Splunk.

Official NXLog documentation:  
https://docs.nxlog.co/userguide/index.html