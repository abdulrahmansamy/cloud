# 🔐 Connecting to Bastion Hosts in Google Cloud Platform (GCP)

Bastion hosts provide secure entry points into private networks. This guide explains how DevOps engineers can connect to **Linux** and **Windows** bastion hosts using Google Cloud SDK and Identity‑Aware Proxy (IAP).

---

## 1. Prerequisites
- A workstation (Windows, macOS, or Linux) with internet access.
- Installed **Google Cloud SDK** ([installation guide](https://cloud.google.com/sdk/docs/install)).
- IAM role: `roles/iap.tunnelResourceAccessor` or equivalent.
- Firewall rules allowing IAP proxy range (`35.235.240.0/20`) to bastion host ports (22 for SSH, 3389 for RDP).

---

## 2. Connect to Linux Bastion Host

### Windows Workstation
1. **Install Google Cloud SDK**  
   Run PowerShell as Administrator:
   ```powershell
   (New-Object Net.WebClient).DownloadFile(
     "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe",
     "$env:Temp\GoogleCloudSDKInstaller.exe"
   )
   & $env:Temp\GoogleCloudSDKInstaller.exe
   ```

2. **Initialize and verify SDK**  
   ```cmd
   gcloud init
   gcloud --version
   gcloud components update
   ```

3. **Authenticate and set project**  
   ```cmd
   gcloud auth login
   gcloud config set project <PROJECT_ID>
   ```

4. **SSH into bastion host**  
   ```cmd
   gcloud compute ssh <LINUX_BASTION_NAME> --zone=<ZONE>
   ```

---

### macOS / Linux Workstation
1. **Install Google Cloud SDK**  
   Follow [official instructions](https://cloud.google.com/sdk/docs/install).

2. **Initialize and verify SDK**  
   ```bash
   gcloud init
   gcloud --version
   gcloud components update
   ```

3. **Authenticate and set project**  
   ```bash
   gcloud auth login
   gcloud config set project <PROJECT_ID>
   ```

4. **SSH into bastion host**  
   ```bash
   gcloud compute ssh <LINUX_BASTION_NAME> --zone=<ZONE>
   ```

---

## 3. Connect to Windows Bastion Host (RDP)

### Step 1: Install RDP Client
- **Windows**: Use built‑in Remote Desktop Connection (`mstsc.exe`).  
- **macOS**:  
  ```bash
  brew install --cask microsoft-remote-desktop
  ```
- **Linux (Ubuntu/Debian)**:  
  ```bash
  sudo apt update && sudo apt install freerdp2-x11 -y
  ```
  Alternative:  
  ```bash
  sudo apt install remmina -y
  ```

### Step 2: Start IAP Tunnel
From your workstation:
```bash
gcloud compute start-iap-tunnel <WINDOWS_BASTION_NAME> 3389 \
  --zone=<ZONE> \
  --local-host-port=localhost:3389
```
Keep this terminal session open while connected.

### Step 3: Connect via RDP
- **Windows**: Run `mstsc.exe`, connect to `localhost:3389`.  
- **macOS**: Open Microsoft Remote Desktop → Add PC → `localhost:3389`.  
- **Linux (FreeRDP)**:  
  ```bash
  xfreerdp /v:localhost:3389 /u:<USERNAME> /p:<PASSWORD>
  ```
- **Linux (Remmina)**: Create new RDP connection → `localhost:3389`.

### Step 4: Manage Credentials
Reset or generate Windows credentials if needed:
```bash
gcloud compute reset-windows-password <WINDOWS_BASTION_NAME> --zone=<ZONE>
```

---

## 4. Security Best Practices
- Always use **IAP tunnels**; never expose bastion hosts directly to the internet.  
- Restrict firewall rules to IAP proxy range (`35.235.240.0/20`).  
- Rotate Windows passwords regularly.  
- Audit IAM bindings to ensure least privilege.  

---

## 📘 Quick Reference Matrix

| Bastion Type | Protocol | Port | Client Tool | Connection Command |
|--------------|----------|------|-------------|--------------------|
| Linux        | SSH      | 22   | gcloud SDK  | `gcloud compute ssh <LINUX_BASTION_NAME> --zone=<ZONE>` |
| Windows      | RDP      | 3389 | RDP client  | `gcloud compute start-iap-tunnel <WINDOWS_BASTION_NAME> 3389 --zone=<ZONE> --local-host-port=localhost:3389` |

---
Replace `<PROJECT_ID>`, `<ZONE>`, `<LINUX_BASTION_NAME>`, and `<WINDOWS_BASTION_NAME>` with your actual values.  

This document prepared by **Abdul Rahman Samy**.

