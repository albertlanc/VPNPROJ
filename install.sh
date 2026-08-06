#!/bin/bash
# install.sh - Master VPN Installer

if [ "${EUID}" -ne 0 ]; then
    echo "[!] This script must be run as root."
    exit 1
fi

REPO_URL="https://raw.githubusercontent.com/albertlanc/VPNPROJ/main"

clear
echo "=================================================="
echo "       VPN DOMAIN & NETWORK SETUP                 "
echo "=================================================="
read -p "Enter your Subdomain (e.g., vpn.yourdomain.com): " DOMAIN
read -p "Enter your SlowDNS Nameserver (e.g., ns.yourdomain.com): " NS_DOMAIN
echo "=================================================="

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
if curl --output /dev/null --silent --head --fail "$REPO_URL/core/ssh-ws.py"; then
    wget -q -O "/usr/local/bin/ssh-ws.py" "$REPO_URL/core/ssh-ws.py"
    chmod +x /usr/local/bin/ssh-ws.py
fi

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
if curl --output /dev/null --silent --head --fail "$REPO_URL/core/xray-install.sh"; then
    wget -q -O "/tmp/vpn/xray-install.sh" "$REPO_URL/core/xray-install.sh"
    bash /tmp/vpn/xray-install.sh
fi

# 4. Install SlowDNS
echo "[4/6] Installing SlowDNS (DNSTT)..."
if curl --output /dev/null --silent --head --fail "$REPO_URL/core/slowdns-install.sh"; then
    wget -q -O "/tmp/vpn/slowdns-install.sh" "$REPO_URL/core/slowdns-install.sh"
    bash /tmp/vpn/slowdns-install.sh
fi

# Inject the Nameserver variable into the service file if it exists
if [ -f /etc/systemd/system/slowdns.service ]; then
    sed -i "s/dns.yourdomain.com/$NS_DOMAIN/g" /etc/systemd/system/slowdns.service
    systemctl daemon-reload
    systemctl restart slowdns
fi

# 5. Configure Nginx Reverse Proxy
echo "[5/6] Routing Web Traffic (Nginx)..."
if curl --output /dev/null --silent --head --fail "$REPO_URL/Templates/nginx.conf"; then
    wget -q -O "/etc/nginx/nginx.conf" "$REPO_URL/Templates/nginx.conf"
    sed -i "s/server_name _;/server_name $DOMAIN;/g" /etc/nginx/nginx.conf
    systemctl restart nginx
fi

# 6. Install CLI Menu & User Scripts
echo "[6/6] Installing User Management Interface..."
for script in menu.sh add-user.sh del-user.sh; do
    if curl --output /dev/null --silent --head --fail "$REPO_URL/menu/$script"; then
        target_name=$(echo "$script" | cut -d'.' -f1)
        wget -q -O "/usr/local/sbin/$target_name" "$REPO_URL/menu/$script"
        chmod +x "/usr/local/sbin/$target_name"
    fi
done

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
