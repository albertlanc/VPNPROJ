#!/bin/bash
# install.sh - Master VPN Installer (GitHub Public Direct)

if [ "${EUID}" -ne 0 ]; then
    echo "[!] This script must be run as root."
    exit 1
fi

REPO_URL="https://raw.githubusercontent.com/albertlanc/VPNPROJ/main"

# ==========================================
# GATHER USER DOMAIN INPUT FIRST
# ==========================================
clear
echo "=================================================="
echo "       VPN DOMAIN & NETWORK SETUP                 "
echo "=================================================="
read -p "Enter your Subdomain (e.g., vpn.yourdomain.com): " DOMAIN
read -p "Enter your SlowDNS Nameserver (e.g., ns.yourdomain.com): " NS_DOMAIN
echo "=================================================="

# Helper function to download and verify files exist (not 404)
download_file() {
    local url="$1"
    local dest="$2"
    if ! curl --output /dev/null --silent --head --fail "$url"; then
        echo -e "\e[31m[!] ERROR: File not found at $url\e[0m"
        exit 1
    fi
    wget -q -O "$dest" "$url"
}

clear
echo "=================================================="
echo "       STARTING MODULAR VPN INSTALLATION          "
echo "=================================================="

# 1. Update System & Install Dependencies
echo "[1/6] Installing Core Dependencies..."
apt update -y
apt install -y wget curl unzip jq nginx iptables python3

# 2. Setup SSH-WebSocket Proxy
echo "[2/6] Configuring SSH-WS Bridge..."
download_file "$REPO_URL/core/ssh-ws.py" "/usr/local/bin/ssh-ws.py"
chmod +x /usr/local/bin/ssh-ws.py

cat <<EOF > /etc/systemd/system/ssh-ws.service
[Unit]
Description=SSH WebSocket Proxy Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/ssh-ws.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
