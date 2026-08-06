#!/bin/bash
# menu/del-user.sh

echo "========================================"
echo "         DELETE VPN USER"
echo "========================================"
read -p "Username to delete : " USER

# 1. Delete SSH User
# -f forces deletion even if the user is somehow connected
if id "$USER" &>/dev/null; then
    userdel -f "$USER" &> /dev/null
    echo "[-] SSH & SlowDNS access removed for: $USER"
else
    echo "[!] Linux user $USER not found. Skipping SSH deletion."
fi

# 2. Delete Xray User (VLESS & VMess)
CONFIG="/usr/local/etc/xray/config.json"

# Use jq to map over the clients array and keep only the ones that DO NOT match the username
jq --arg user "$USER" '
   .inbounds[0].settings.clients |= map(select(.email != $user)) |
   .inbounds[1].settings.clients |= map(select(.email != $user))
' $CONFIG > /tmp/xray_tmp.json && mv /tmp/xray_tmp.json $CONFIG

# Restart Xray to drop any active connections for this user
systemctl restart xray

echo "[-] Xray access removed for: $USER"
echo "========================================"
echo " User $USER has been completely deleted."
echo "========================================"
