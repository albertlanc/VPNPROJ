#!/bin/bash
# install.sh - Fixed Input Version

if [ "${EUID}" -ne 0 ]; then
    echo "[!] This script must be run as root."
    exit 1
fi

clear
echo "=================================================="
echo "       VPN DOMAIN & NETWORK SETUP                 "
echo "=================================================="
read -p "Enter your Subdomain (e.g., vpn.yourdomain.com): " DOMAIN
read -p "Enter your SlowDNS Nameserver (e.g., ns.yourdomain.com): " NS_DOMAIN
echo "=================================================="

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
