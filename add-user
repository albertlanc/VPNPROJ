#!/bin/bash
# menu/add-user.sh

# Get Server IP and SlowDNS Public Key
IP=$(curl -s ifconfig.me)
PUB_KEY=$(cat /etc/slowdns/server.pub 2>/dev/null || echo "Key not found. Check SlowDNS service.")

echo "========================================"
echo "          ADD NEW VPN USER"
echo "========================================"
read -p "Username : " USER
read -p "Password (for SSH) : " PASS
read -p "Expiry (Days) : " DAYS

# 1. Create SSH User (For SSH-WS and SlowDNS)
# Calculate expiry date
EXP_DATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
# Add user without shell access (-s /bin/false) for security
useradd -e "$EXP_DATE" -M -s /bin/false "$USER" &> /dev/null
echo "$USER:$PASS" | chpasswd

# 2. Create Xray User (For VMess & VLESS)
UUID=$(xray uuid)
CONFIG="/usr/local/etc/xray/config.json"

# Inject new user into VLESS (inbounds[0])
jq --arg uuid "$UUID" --arg user "$USER" \
   '.inbounds[0].settings.clients += [{"id": $uuid, "level": 0, "email": $user}]' \
   $CONFIG > /tmp/xray_tmp.json && mv /tmp/xray_tmp.json $CONFIG

# Inject new user into VMess (inbounds[1])
jq --arg uuid "$UUID" --arg user "$USER" \
   '.inbounds[1].settings.clients += [{"id": $uuid, "alterId": 0, "email": $user}]' \
   $CONFIG > /tmp/xray_tmp.json && mv /tmp/xray_tmp.json $CONFIG

# Restart Xray to apply changes
systemctl restart xray

# 3. Generate Link Configurations
# VMess requires a base64 encoded JSON config
VMESS_JSON="{\"v\":\"2\",\"ps\":\"$USER\",\"add\":\"$IP\",\"port\":\"80\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"path\":\"/vmess\",\"type\":\"none\",\"host\":\"$IP\",\"tls\":\"\"}"
VMESS_BASE64=$(echo -n "$VMESS_JSON" | base64 -w 0)

echo ""
echo "========================================"
echo "          USER ACCOUNT DETAILS"
echo "========================================"
echo "Username   : $USER"
echo "Password   : $PASS"
echo "Expires On : $EXP_DATE"
echo "Host / IP  : $IP"
echo "========================================"
echo " [ SSH & SlowDNS Details ]"
echo "Port 80 (SSH-WS)  : Path /ssh"
echo "SlowDNS Pub Key   : $PUB_KEY"
echo "========================================"
echo " [ VLESS WS ]"
echo "vless://${UUID}@${IP}:80?path=/vless&security=none&encryption=none&type=ws#${USER}"
echo "========================================"
echo " [ VMESS WS ]"
echo "vmess://${VMESS_BASE64}"
echo "========================================"

