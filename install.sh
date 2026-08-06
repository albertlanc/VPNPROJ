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

cat << 'EOF_SERVICE' > /etc/systemd/system/ssh-ws.service
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
EOF_SERVICE

systemctl daemon-reload
systemctl enable ssh-ws
systemctl restart ssh-ws

# 3. Install Xray Core
echo "[3/6] Installing Xray Core (VMess/VLESS)..."
mkdir -p /tmp/vpn
download_file "$REPO_URL/core/xray-install.sh" "/tmp/vpn/xray-install.sh"
bash /tmp/vpn/xray-install.sh

# 4. Install SlowDNS
echo "[4/6] Installing SlowDNS (DNSTT)..."
download_file "$REPO_URL/core/slowdns-install.sh" "/tmp/vpn/slowdns-install.sh"
bash /tmp/vpn/slowdns-install.sh

# Inject the Nameserver variable you typed into the service file
sed -i "s/dns.yourdomain.com/$NS_DOMAIN/g" /etc/systemd/system/slowdns.service
systemctl daemon-reload
systemctl restart slowdns

# 5. Configure Nginx Reverse Proxy
echo "[5/6] Routing Web Traffic (Nginx)..."
download_file "$REPO_URL/Templates/nginx.conf" "/etc/nginx/nginx.conf"

# Inject the Subdomain variable you typed into Nginx
sed -i "s/server_name _;/server_name $DOMAIN;/g" /etc/nginx/nginx.conf
systemctl restart nginx

# 6. Install CLI Menu & User Scripts
echo "[6/6] Installing User Management Interface..."
download_file "$REPO_URL/menu/menu.sh" "/usr/local/sbin/menu"
download_file "$REPO_URL/menu/add-user.sh" "/usr/local/sbin/add-user"
download_file "$REPO_URL/menu/del-user.sh" "/usr/local/sbin/del-user"

chmod +x /usr/local/sbin/menu
chmod +x /usr/local/sbin/add-user
chmod +x /usr/local/sbin/del-user

# Cleanup temporary files
rm -rf /tmp/vpn

clear
echo "=================================================="
echo "          INSTALLATION COMPLETE!                  "
echo "=================================================="
echo " Subdomain  : $DOMAIN"
echo " Nameserver : $NS_DOMAIN"
echo "=================================================="
echo " All services are configured and running."
echo " Type 'menu' in your terminal to start."
echo "=================================================="
