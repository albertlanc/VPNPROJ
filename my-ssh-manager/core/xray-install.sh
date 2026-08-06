#!/bin/bash
# core/xray-install.sh

echo "Starting Xray Core Installation..."

# 1. Run the official XTLS Xray installation script
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 2. Fetch the custom xray.json template
# (Ensure your REPO_URL matches where you host these files)
REPO_URL="https://raw.githubusercontent.com/HisRepo"
echo "Downloading Xray configuration template..."
wget -q -O /usr/local/etc/xray/config.json "$REPO_URL/templates/xray.json"

# 3. Generate a fresh Admin UUID
UUID=$(xray uuid)
echo "Generated Default Admin UUID: $UUID"

# 4. Inject the new UUID into both VLESS and VMess inbounds using jq
jq ".inbounds[0].settings.clients[0].id = \"$UUID\" | \
    .inbounds[1].settings.clients[0].id = \"$UUID\"" \
    /usr/local/etc/xray/config.json > /tmp/xray_tmp.json

mv /tmp/xray_tmp.json /usr/local/etc/xray/config.json

# 5. Restart and enable the service
systemctl daemon-reload
systemctl enable xray
systemctl restart xray

echo "Xray Core installed and configured successfully!"
echo "------------------------------------------------"
echo "Default Admin UUID: $UUID"
echo "------------------------------------------------"
