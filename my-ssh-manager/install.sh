#!/bin/bash

# Clear screen and show banner
clear
echo "=================================================="
echo "         Installing VPNPROJ SSH Manager           "
echo "=================================================="

# Check if user is root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run this installer as root."
  exit 1
fi

echo "[+] Downloading secure components..."

# Replace with your actual private server URL or storage link where your compiled binary is hosted
BINARY_URL="http://YOUR_PRIVATE_SERVER_IP_OR_DOMAIN/ssh-manager-bin"

# Download the compiled binary directly into system bin
curl -s -o /usr/local/sbin/ssh-manager "$BINARY_URL"

# Verify download succeeded
if [ ! -f /usr/local/sbin/ssh-manager ]; then
  echo "[-] Installation failed: Could not download package."
  exit 1
fi

# Set proper executable permissions
chmod +x /usr/local/sbin/ssh-manager

echo "[+] Installation completed successfully!"
echo "[+] Type 'ssh-manager' to begin."
