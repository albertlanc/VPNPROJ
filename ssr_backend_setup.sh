#!/bin/bash
GREEN='\e[32m'
NC='\e[0m'

echo -e "${GREEN}[*] Installing ShadowsocksR (SSR) Dependencies...${NC}"
apt-get update -y &>/dev/null
apt-get install -y git python3 python3-pip &>/dev/null

echo -e "${GREEN}[*] Cloning SSR Repository...${NC}"
rm -rf /usr/local/shadowsocksr
git clone -b akkariiin/master https://github.com/shadowsocksrr/shadowsocksr.git /usr/local/shadowsocksr &>/dev/null

echo -e "${GREEN}[*] Configuring SSR Base Settings...${NC}"
cat << EOT > /usr/local/shadowsocksr/user-config.json
{
    "server": "0.0.0.0",
    "server_ipv6": "::",
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "port_password": {},
    "timeout": 300,
    "method": "aes-256-cfb",
    "protocol": "origin",
    "protocol_param": "",
    "obfs": "plain",
    "obfs_param": "",
    "redirect": "",
    "dns_ipv6": false,
    "fast_open": false,
    "workers": 1
}
EOT

echo -e "${GREEN}[*] Creating SSR Systemd Service...${NC}"
cat << EOT > /etc/systemd/system/ssr-server.service
[Unit]
Description=ShadowsocksR Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/shadowsocksr/server.py -c /usr/local/shadowsocksr/user-config.json
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable ssr-server &>/dev/null
systemctl start ssr-server

echo -e "${GREEN}[+] ShadowsocksR Backend is LIVE!${NC}"
