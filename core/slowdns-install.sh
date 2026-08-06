#!/bin/bash
# core/slowdns-install.sh - Auto-Compiling Version

echo "Setting up SlowDNS (DNSTT)..."

# 1. Create directory structure
mkdir -p /etc/slowdns
mkdir -p /etc/iptables

# 2. Compile DNSTT Server directly from source (Bulletproof)
echo "Compiling DNSTT Server from source..."
apt-get install -y golang git
cd /tmp
git clone https://www.bamsoftware.com/git/dnstt.git
cd dnstt/dnstt-server
go build
mv dnstt-server /usr/local/bin/
chmod +x /usr/local/bin/dnstt-server
rm -rf /tmp/dnstt

# 3. Generate Cryptographic Keys natively
echo "Generating new DNSTT keys..."
/usr/local/bin/dnstt-server -gen-key -privkey-file /etc/slowdns/server.key -pubkey-file /etc/slowdns/server.pub

# 4. Create Clean Systemd Service
cat <<EOF > /etc/systemd/system/slowdns.service
[Unit]
Description=DNSTT (SlowDNS) Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/dnstt-server -udp :5335 -privkey-file /etc/slowdns/server.key dns.yourdomain.com 127.0.0.1:22
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 5. Handle Port 53 Conflicts
iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5335
iptables-save > /etc/iptables/rules.v4

# 6. Start the Service
systemctl daemon-reload
systemctl enable slowdns
systemctl restart slowdns

echo "SlowDNS Setup Complete!"

