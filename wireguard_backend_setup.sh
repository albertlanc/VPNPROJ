#!/bin/bash
GREEN='\e[32m'
NC='\e[0m'

echo -e "${GREEN}[*] Installing Wireguard & Networking Tools...${NC}"
apt-get update -y &>/dev/null
apt-get install -y wireguard iptables &>/dev/null

echo -e "${GREEN}[*] Generating Server Keys & wg0 Interface (Port 7070)...${NC}"
mkdir -p /etc/wireguard
if [ ! -f "/etc/wireguard/server_private.key" ]; then
    wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
fi
SERVER_PRIV=$(cat /etc/wireguard/server_private.key)
MAIN_IFACE=$(ip -o -4 route show to default | awk '{print $5}')

cat << EOT > /etc/wireguard/wg0.conf
[Interface]
Address = 10.66.66.1/24
ListenPort = 7070
PrivateKey = $SERVER_PRIV
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $MAIN_IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $MAIN_IFACE -j MASQUERADE
EOT

systemctl enable wg-quick@wg0 &>/dev/null
systemctl restart wg-quick@wg0

echo -e "${GREEN}[*] Setting up Nginx on Port 89 to serve .conf files...${NC}"
mkdir -p /var/www/wireguard
chmod 755 /var/www/wireguard
cat << EOT > /etc/nginx/conf.d/wireguard.conf
server {
    listen 89;
    server_name _;
    root /var/www/wireguard;
    autoindex on;
}
EOT
systemctl restart nginx

echo -e "${GREEN}[+] Wireguard Backend is LIVE!${NC}"
