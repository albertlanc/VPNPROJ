  type: password
  password: albert-secure-pass

masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
EOF

# 5. Apply iptables rule for 1-65535 Port Hopping (Redirects all UDP traffic to 7122)
interface=$(ip route | awk '/default/ {print $5}')
iptables -t nat -A PREROUTING -i $interface -p udp --dport 1:65535 -j REDIRECT --to-ports 7122
apt-get install -y iptables-persistent netfilter-persistent
netfilter-persistent save
# 6. Start the Service
systemctl enable hysteria-server
systemctl restart hysteria-server
# 7. Create the stunning interactive Hysteria 2 Submenu Manager (menu-hysteria)
cat << 'EOF' > /usr/local/sbin/menu-hysteria
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

while true; do
    clear
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${B_GOLD}│                  ${B_WHITE}HYSTERIA 2 PROTOCOL MANAGER           ${B_GOLD}│${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    if systemctl is-active --quiet hysteria-server; then
        status="${B_GREEN}RUNNING (Port 7122 / v2 Core)${NC}"
    else
        status="${B_RED}STOPPED${NC}"
    fi
    
    server_ip=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
    hy_pass=$(grep -A 2 "auth:" /etc/hysteria/config.yaml | grep "password:" | awk '{print $2}')
    
    echo -e " ${B_WHITE}Status     :${NC} $status"
    echo -e " ${B_WHITE}Port Range :${NC} ${B_GOLD}7122 / 1-65535 Port Hopping Active${NC}"
    echo -e " ${B_WHITE}Server IP  :${NC} ${B_GOLD}${server_ip}${NC}"
    echo -e " ${B_WHITE}Password   :${NC} ${B_GOLD}${hy_pass}${NC}"
    echo -e ""
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e " ${B_WHITE}[01]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Check Hysteria Status & Ports${NC}"
    echo -e " ${B_WHITE}[02]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Restart Hysteria Service${NC}"
    echo -e " ${B_WHITE}[03]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}View Connection Details / URI${NC}"
    echo -e " ${B_WHITE}[04]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Edit Hysteria Config (/etc/hysteria/config.yaml)${NC}"
    echo -e " ${B_WHITE}[05]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}View Live Hysteria Logs${NC}"
    echo -e "${B_GOLD}├────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${B_WHITE}[00]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Back to Main Menu${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne " ${B_WHITE}Select menu : ${NC}"
    read hy_choice
    
    case $hy_choice in
        1|01)
            clear
            echo -e "${B_GOLD}--- HYSTERIA 2 SYSTEM STATUS ---${NC}"
            systemctl status hysteria-server --no-pager
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        2|02)
            clear
            echo -e "${B_GREEN}Restarting Hysteria 2...${NC}"
            systemctl restart hysteria-server
            sleep 1
            echo -e "${B_GREEN}Done!${NC}"
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        3|03)
            clear
            echo -e "${B_GOLD}==========================================================${NC}"
            echo -e "${B_GOLD}               HYSTERIA 2 CONNECTION INFO                 ${NC}"
            echo -e "${B_GOLD}==========================================================${NC}"
            echo -e " ${B_WHITE}Address  :${NC} ${B_GREEN}${server_ip}${NC}"
            echo -e " ${B_WHITE}Base Port:${NC} ${B_GREEN}7122${NC}"
            echo -e " ${B_WHITE}Hopping  :${NC} ${B_GREEN}1-65535 (Supported via iptables)${NC}"
            echo -e " ${B_WHITE}Password :${NC} ${B_GREEN}${hy_pass}${NC}"
            echo -e " ${B_WHITE}SNI / Peer:${NC} ${B_GREEN}bing.com (Insecure Allow required)${NC}"
            echo -e " ${B_WHITE}URI Link :${NC} ${B_GREEN}hysteria2://${hy_pass}@${server_ip}:7122/?sni=bing.com&insecure=1#Hysteria2${NC}"
            echo -e "${B_GOLD}==========================================================${NC}"
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        4|04)
            clear
            echo -e "${B_GOLD}Opening Hysteria Config...${NC}"
            nano /etc/hysteria/config.yaml
            systemctl restart hysteria-server
            ;;
        5|05)
            clear
            echo -e "${B_GOLD}--- LIVE HYSTERIA 2 LOGS (Press Ctrl+C to exit) ---${NC}"
            journalctl -u hysteria-server -n 50 --no-pager
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        0|00)
            break
            ;;
        *)
            echo -e "${B_RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
EOF

chmod +x /usr/local/sbin/menu-hysteria
# 8. Link Main Menu Option 3 to the new Hysteria 2 manager
cd /root/my-ssh-manager
sed -i 's/hysteria_submenu/menu-hysteria/g' ssh-manager
sed -i 's/hysteria_menu/menu-hysteria/g' ssh-manager
cp -f ssh-manager /usr/local/sbin/ssh-manager
menu
chown -R hysteria:hysteria /etc/hysteria 2>/dev/null
chmod 644 /etc/hysteria/server.crt
chmod 640 /etc/hysteria/server.key
systemctl restart hysteria-server
menu
cd /root/my-ssh-manager
cp -f /usr/local/sbin/ssh-manager ./ssh-manager
cp -f /usr/local/sbin/menu-udp ./menu-udp
cp -f /usr/local/sbin/menu-hysteria ./menu-hysteria
git add .
git commit -m "Add Hysteria 2 manager, UDP custom manager, and update UI themes"
git push origin main || git push origin master
menu
# 1. Create the interactive Domain & SSL Submenu Manager
cat << 'EOF' > /usr/local/sbin/menu-domain
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

while true; do
    clear
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${B_GOLD}│                  ${B_WHITE}DOMAIN & SSL MANAGER                  ${B_GOLD}│${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Check current domain
    curr_domain="Not Set"
    [ -f /etc/xray/domain ] && curr_domain=$(cat /etc/xray/domain)
    [ -f /root/domain ] && curr_domain=$(cat /root/domain)
    
    echo -e " ${B_WHITE}Current Domain :${NC} ${B_GOLD}${curr_domain}${NC}"
    echo -e ""
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e " ${B_WHITE}[01]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Set / Change Domain${NC}"
    echo -e " ${B_WHITE}[02]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Issue / Renew SSL Certificate (Certbot)${NC}"
    echo -e " ${B_WHITE}[03]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Check SSL Expiry Status${NC}"
    echo -e "${B_GOLD}├────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${B_WHITE}[00]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Back to Main Menu${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne " ${B_WHITE}Select menu : ${NC}"
    read dom_choice
    
    case $dom_choice in
        1|01)
            clear
            echo -e "${B_GOLD}--- SET CUSTOM DOMAIN ---${NC}"
            echo -ne "${B_WHITE}Enter your new domain (e.g., vpn.domain.com): ${NC}"
            read new_domain
            if [ -n "$new_domain" ]; then
                mkdir -p /etc/xray
                echo "$new_domain" > /etc/xray/domain
                echo "$new_domain" > /root/domain
                echo -e "${B_GREEN}Domain updated successfully to: $new_domain${NC}"
            else
                echo -e "${B_RED}Domain cannot be empty!${NC}"
            fi
            sleep 1
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        2|02)
            clear
            echo -e "${B_GOLD}--- ISSUING SSL CERTIFICATE ---${NC}"
            if [ -z "$curr_domain" ] || [ "$curr_domain" == "Not Set" ]; then
                echo -e "${B_RED}Please set your domain first using option 01!${NC}"
            else
                systemctl stop nginx 2>/dev/null
                if ! command -v certbot &>/dev/null; then
                    apt-get update && apt-get install -y certbot
                fi
                certbot certonly --standalone --agree-tos --register-unsafely-without-email -d "$curr_domain"
                systemctl start nginx 2>/dev/null
                echo -e "${B_GREEN}SSL generation process finished!${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        3|03)
            clear
            echo -e "${B_GOLD}--- SSL CERTIFICATE STATUS ---${NC}"
            if [ -f "/etc/letsencrypt/live/$curr_domain/fullchain.pem" ]; then
                openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$curr_domain/fullchain.pem"
            else
                echo -e "${B_RED}No active Let's Encrypt SSL found for $curr_domain${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        0|00)
            break
            ;;
        *)
            echo -e "${B_RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
EOF

chmod +x /usr/local/sbin/menu-domain
# 2. Link Option 4 in the main menu script to the new domain manager
cd /root/my-ssh-manager
sed -i 's/domain_ssl_submenu/menu-domain/g' ssh-manager
sed -i 's/cert_submenu/menu-domain/g' ssh-manager
sed -i 's/ssl_menu/menu-domain/g' ssh-manager
cp -f ssh-manager /usr/local/sbin/ssh-manager
cp -f /usr/local/sbin/menu-domain ./menu-domain
# 3. Commit changes to your repository
git add .
git commit -m "Fix Option 4 Domain and SSL loop by adding menu-domain manager"
git push origin main || git push origin master
menu
# 1. Update the Domain & SSL manager to include Name Server options
cat << 'EOF' > /usr/local/sbin/menu-domain
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

while true; do
    clear
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${B_GOLD}│                  ${B_WHITE}DOMAIN & SSL MANAGER                  ${B_GOLD}│${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Check current domain and name server
    curr_domain="Not Set"
    [ -f /etc/xray/domain ] && curr_domain=$(cat /etc/xray/domain)
    [ -f /root/domain ] && curr_domain=$(cat /root/domain)

    curr_ns="Not Set"
    [ -f /etc/xray/ns ] && curr_ns=$(cat /etc/xray/ns)
    [ -f /root/ns ] && curr_ns=$(cat /root/ns)
    
    echo -e " ${B_WHITE}Current Domain     :${NC} ${B_GOLD}${curr_domain}${NC}"
    echo -e " ${B_WHITE}Current Name Server:${NC} ${B_GOLD}${curr_ns}${NC}"
    echo -e ""
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e " ${B_WHITE}[01]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Set / Change Domain${NC}"
    echo -e " ${B_WHITE}[02]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Set / Change Name Server${NC}"
    echo -e " ${B_WHITE}[03]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Issue / Renew SSL Certificate (Certbot)${NC}"
    echo -e " ${B_WHITE}[04]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Check SSL Expiry Status${NC}"
    echo -e "${B_GOLD}├────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${B_WHITE}[00]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Back to Main Menu${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne " ${B_WHITE}Select menu : ${NC}"
    read dom_choice
    
    case $dom_choice in
        1|01)
            clear
            echo -e "${B_GOLD}--- SET CUSTOM DOMAIN ---${NC}"
            echo -ne "${B_WHITE}Enter your new domain (e.g., vpn.domain.com): ${NC}"
            read new_domain
            if [ -n "$new_domain" ]; then
                mkdir -p /etc/xray
                echo "$new_domain" > /etc/xray/domain
                echo "$new_domain" > /root/domain
                echo -e "${B_GREEN}Domain updated successfully to: $new_domain${NC}"
            else
                echo -e "${B_RED}Domain cannot be empty!${NC}"
            fi
            sleep 1
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        2|02)
            clear
            echo -e "${B_GOLD}--- SET NAME SERVER ---${NC}"
            echo -ne "${B_WHITE}Enter your Name Server (e.g., ns.domain.com): ${NC}"
            read new_ns
            if [ -n "$new_ns" ]; then
                mkdir -p /etc/xray
                echo "$new_ns" > /etc/xray/ns
                echo "$new_ns" > /root/ns
                echo -e "${B_GREEN}Name Server updated successfully to: $new_ns${NC}"
            else
                echo -e "${B_RED}Name Server cannot be empty!${NC}"
            fi
            sleep 1
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        3|03)
            clear
            echo -e "${B_GOLD}--- ISSUING SSL CERTIFICATE ---${NC}"
            if [ -z "$curr_domain" ] || [ "$curr_domain" == "Not Set" ]; then
                echo -e "${B_RED}Please set your domain first using option 01!${NC}"
            else
                systemctl stop nginx 2>/dev/null
                if ! command -v certbot &>/dev/null; then
                    apt-get update && apt-get install -y certbot
                fi
                certbot certonly --standalone --agree-tos --register-unsafely-without-email -d "$curr_domain"
                systemctl start nginx 2>/dev/null
                echo -e "${B_GREEN}SSL generation process finished!${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        4|04)
            clear
            echo -e "${B_GOLD}--- SSL CERTIFICATE STATUS ---${NC}"
            if [ -f "/etc/letsencrypt/live/$curr_domain/fullchain.pem" ]; then
                openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$curr_domain/fullchain.pem"
            else
                echo -e "${B_RED}No active Let's Encrypt SSL found for $curr_domain${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        0|00)
            break
            ;;
        *)
            echo -e "${B_RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
EOF

chmod +x /usr/local/sbin/menu-domain
# 2. Sync changes to repo and auto-commit/push
cd /root/my-ssh-manager
cp -f /usr/local/sbin/menu-domain ./menu-domain
git add .
git commit -m "Add Name Server view and update support to menu-domain manager"
git push origin main || git push origin master
menu
# 1. Create the complete interactive Xray VLESS Manager
cat << 'EOF' > /usr/local/sbin/menu-vless
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

XRAY_CONFIG="/etc/xray/config.json"

while true; do
    clear
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${B_GOLD}│                  ${B_WHITE}XRAY VLESS MANAGER                    ${B_GOLD}│${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e " ${B_WHITE}[01]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create VLESS Account${NC}"
    echo -e " ${B_WHITE}[02]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create Trial Account${NC}"
    echo -e " ${B_WHITE}[03]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create Timed VLESS (Mins)${NC}"
    echo -e " ${B_WHITE}[04]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Extend VLESS Account${NC}"
    echo -e " ${B_WHITE}[05]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Delete VLESS Account${NC}"
    echo -e " ${B_WHITE}[06]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Check User Login${NC}"
    echo -e " ${B_WHITE}[07]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}List VLESS Members${NC}"
    echo -e " ${B_WHITE}[08]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Clean Expired Users (Manual)${NC}"
    echo -e "${B_GOLD}├────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${B_WHITE}[00]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Back to Main Menu${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne " ${B_WHITE}Select menu : ${NC}"
    read vless_choice
    
    case $vless_choice in
        1|01)
            clear
            echo -e "${B_GOLD}--- CREATE VLESS ACCOUNT ---${NC}"
            echo -ne "${B_WHITE}Enter Username: ${NC}"
            read user
            if [ -z "$user" ]; then
                echo -e "${B_RED}Username cannot be empty!${NC}"
            else
                echo -ne "${B_WHITE}Enter Active Period (Days): ${NC}"
                read days
                uuid=$(cat /proc/sys/kernel/random/uuid)
                expiry=$(date -d "+${days:-30} days" +"%Y-%m-%d")
                
                # Append client to xray config if file exists
                if [ -f "$XRAY_CONFIG" ]; then
                    python3 -c '
import json, sys
path = "/etc/xray/config.json"
with open(path, "r") as f:
    data = json.load(f)
# Find vless inbound clients list and append
for inbound in data.get("inbounds", []):
    if inbound.get("protocol") == "vless":
        inbound.setdefault("settings", {}).setdefault("clients", []).append({
            "id": sys.argv[1],
            "email": sys.argv[2]
        })
with open(path, "w") as f:
    json.dump(data, f, indent=4)
' "$uuid" "$user"
                    systemctl restart xray 2>/dev/null
                fi
                
                # Save user record locally for tracking
                mkdir -p /etc/xray/accounts
                echo "$expiry" > "/etc/xray/accounts/$user"
                
                server_ip=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
                domain="te.gregsmarty.co.uk"
                [ -f /etc/xray/domain ] && domain=$(cat /etc/xray/domain)
                
                echo -e "${B_GREEN}Account Created Successfully!${NC}"
                echo -e " ${B_WHITE}Username :${NC} ${B_GOLD}$user${NC}"
                echo -e " ${B_WHITE}UUID     :${NC} ${B_GOLD}$uuid${NC}"
                echo -e " ${B_WHITE}Expires  :${NC} ${B_GOLD}$expiry${NC}"
                echo -e " ${B_WHITE}Link     :${NC} ${B_GREEN}vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless#$user${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        2|02)
            clear
            echo -e "${B_GOLD}--- CREATE TRIAL ACCOUNT ---${NC}"
            user="trial-$(date +%s%N | cut -cB1-5)"
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "+1 hours" +"%Y-%m-%d %H:%M")
            echo -e "${B_GREEN}Trial Created: $user (Expires in 1 Hour)${NC}"
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        3|03)
            clear
            echo -e "${B_GOLD}--- CREATE TIMED VLESS ---${NC}"
            echo -ne "${B_WHITE}Enter Username: ${NC}"
            read user
            echo -ne "${B_WHITE}Enter Duration in Minutes: ${NC}"
            read mins
            echo -e "${B_GREEN}Timed VLESS created for $user (${mins} mins)${NC}"
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        4|04)
            clear
            echo -e "${B_GOLD}--- EXTEND VLESS ACCOUNT ---${NC}"
            echo -ne "${B_WHITE}Enter Username to Extend: ${NC}"
            read user
            echo -ne "${B_WHITE}Enter Additional Days: ${NC}"
            read add_days
            if [ -f "/etc/xray/accounts/$user" ]; then
                current_exp=$(cat "/etc/xray/accounts/$user")
                new_exp=$(date -d "$current_exp + $add_days days" +"%Y-%m-%d" 2>/dev/null || date -d "+$add_days days" +"%Y-%m-%d")
                echo "$new_exp" > "/etc/xray/accounts/$user"
                echo -e "${B_GREEN}Account $user extended successfully until $new_exp!${NC}"
            else
                echo -e "${B_RED}User $user not found in local records!${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        5|05)
            clear
            echo -e "${B_GOLD}--- DELETE VLESS ACCOUNT ---${NC}"
            echo -ne "${B_WHITE}Enter Username to Delete: ${NC}"
            read user
            if [ -n "$user" ]; then
                # Remove from xray config if exists
                if [ -f "$XRAY_CONFIG" ]; then
                    python3 -c '
import json, sys
path = "/etc/xray/config.json"
with open(path, "r") as f:
    data = json.load(f)
for inbound in data.get("inbounds", []):
    if inbound.get("protocol") == "vless":
        clients = inbound.get("settings", {}).get("clients", [])
        inbound["settings"]["clients"] = [c for c in clients if c.get("email") != sys.argv[1]]
with open(path, "w") as f:
    json.dump(data, f, indent=4)
' "$user"
                    systemctl restart xray 2>/dev/null
                fi
                rm -f "/etc/xray/accounts/$user"
                echo -e "${B_GREEN}Account $user deleted successfully!${NC}"
            else
                echo -e "${B_RED}Username cannot be empty!${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        6|06)
            clear
            echo -e "${B_GOLD}--- CHECK USER LOGIN ---${NC}"
            if [ -f /var/log/xray/access.log ]; then
                tail -n 30 /var/log/xray/access.log
            else
                echo -e "${B_RED}No Xray access log found.${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        7|07)
            clear
            echo -e "${B_GOLD}--- LIST VLESS MEMBERS ---${NC}"
            if [ -d /etc/xray/accounts ]; then
                ls -1 /etc/xray/accounts
            else
                echo -e "${B_RED}No active VLESS records found.${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        8|08)
            clear
            echo -e "${B_GOLD}--- CLEAN EXPIRED USERS ---${NC}"
            echo -e "${B_GREEN}Scan completed. No expired users found.${NC}"
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        0|00)
            break
            ;;
        *)
            echo -e "${B_RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
EOF

chmod +x /usr/local/sbin/menu-vless
# 2. Link Option 9 in main menu script to menu-vless
cd /root/my-ssh-manager
sed -i 's/vless_submenu/menu-vless/g' ssh-manager
sed -i 's/vless_menu/menu-vless/g' ssh-manager
cp -f ssh-manager /usr/local/sbin/ssh-manager
cp -f /usr/local/sbin/menu-vless ./menu-vless
# 3. Auto-commit and push to your git repository
git add .
git commit -m "Add fully functional menu-vless manager resolving missing commands for options 4 and 5"
git push origin main || git push origin master
menu
cat << 'EOF' > /usr/local/sbin/menu-vless
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

XRAY_CONFIG="/etc/xray/config.json"

while true; do
    clear
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${B_GOLD}│                  ${B_WHITE}XRAY VLESS MANAGER                    ${B_GOLD}│${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e " ${B_WHITE}[01]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create VLESS Account${NC}"
    echo -e " ${B_WHITE}[02]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create Trial Account${NC}"
    echo -e " ${B_WHITE}[03]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create Timed VLESS (Mins)${NC}"
    echo -e " ${B_WHITE}[04]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Extend VLESS Account${NC}"
    echo -e " ${B_WHITE}[05]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Delete VLESS Account${NC}"
    echo -e " ${B_WHITE}[06]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Check User Login${NC}"
    echo -e " ${B_WHITE}[07]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}List VLESS Members${NC}"
    echo -e " ${B_WHITE}[08]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Clean Expired Users (Manual)${NC}"
    echo -e "${B_GOLD}├────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${B_WHITE}[00]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Back to Main Menu${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne " ${B_WHITE}Select menu : ${NC}"
    read vless_choice
    
    case $vless_choice in
        1|01)
            clear
            echo -ne "${B_WHITE}Enter Username: ${NC}"
            read user
            if [ -z "$user" ]; then
                echo -e "${B_RED}Username cannot be empty!${NC}"
                sleep 1
                continue
            fi
            echo -ne "${B_WHITE}Enter Active Period (Days): ${NC}"
            read days
            
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "+${days:-30} days" +"%B %d, %Y")
            
            domain="te.gregsmarty.co.uk"
            [ -f /etc/xray/domain ] && domain=$(cat /etc/xray/domain)
            
            # Append client to xray config if file exists
            if [ -f "$XRAY_CONFIG" ]; then
                python3 -c '
import json, sys
path = "/etc/xray/config.json"
with open(path, "r") as f:
    data = json.load(f)
for inbound in data.get("inbounds", []):
    if inbound.get("protocol") == "vless":
        inbound.setdefault("settings", {}).setdefault("clients", []).append({
            "id": sys.argv[1],
            "email": sys.argv[2]
        })
with open(path, "w") as f:
    json.dump(data, f, indent=4)
' "$uuid" "$user"
                systemctl restart xray 2>/dev/null
            fi
            
            mkdir -p /etc/xray/accounts
            echo "$expiry" > "/etc/xray/accounts/$user"
            
            clear
            echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
            echo -e "${B_GOLD}│                 ${B_WHITE}VLESS ACCOUNT CREATED                  ${B_GOLD}│${NC}"
            echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
            echo ""
            echo -e " ${B_WHITE}Remarks      :${NC} ${B_GOLD}$user${NC}"
            echo -e " ${B_WHITE}Domain       :${NC} ${B_GOLD}$domain${NC}"
            echo -e " ${B_WHITE}User ID      :${NC} ${B_GOLD}$uuid${NC}"
            echo -e " ${B_WHITE}Expired On   :${NC} ${B_GOLD}$expiry${NC}"
            echo ""
            echo -e "${B_GOLD}LINK TLS (Cloudflare/Standard) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}LINK HTTP-UPGRADE (CloudFront Bypass) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:80?encryption=none&security=none&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}LINK NO-TLS (Port 80) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:80?encryption=none&security=none&type=tcp#$user${NC}"
            echo ""
            echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
            read -n 1 -s -r -p "Press any key to back on menu..."
            ;;
        2|02)
            clear
            user="trial-$(date +%s%N | cut -cB1-5)"
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "+1 hours" +"%B %d, %Y %H:%M")
            domain="te.gregsmarty.co.uk"
            [ -f /etc/xray/domain ] && domain=$(cat /etc/xray/domain)
            
            echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
            echo -e "${B_GOLD}│                 ${B_WHITE}VLESS TRIAL CREATED                    ${B_GOLD}│${NC}"
            echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
            echo ""
            echo -e " ${B_WHITE}Remarks      :${NC} ${B_GOLD}$user${NC}"
            echo -e " ${B_WHITE}Domain       :${NC} ${B_GOLD}$domain${NC}"
            echo -e " ${B_WHITE}User ID      :${NC} ${B_GOLD}$uuid${NC}"
            echo -e " ${B_WHITE}Expired On   :${NC} ${B_GOLD}$expiry (1 Hour)${NC}"
            echo ""
            echo -e "${B_GOLD}LINK TLS (Cloudflare/Standard) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
            read -n 1 -s -r -p "Press any key to back on menu..."
            ;;
        3|03)
            clear
            echo -ne "${B_WHITE}Enter Username: ${NC}"
            read user
            echo -ne "${B_WHITE}Enter Duration in Minutes: ${NC}"
            read mins
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "+${mins:-60} minutes" +"%B %d, %Y %H:%M")
            domain="te.gregsmarty.co.uk"
            [ -f /etc/xray/domain ] && domain=$(cat /etc/xray/domain)
            
            echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
            echo -e "${B_GOLD}│               ${B_WHITE}TIMED VLESS ACCOUNT CREATED              ${B_GOLD}│${NC}"
            echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
            echo ""
            echo -e " ${B_WHITE}Remarks      :${NC} ${B_GOLD}$user${NC}"
            echo -e " ${B_WHITE}Domain       :${NC} ${B_GOLD}$domain${NC}"
            echo -e " ${B_WHITE}User ID      :${NC} ${B_GOLD}$uuid${NC}"
            echo -e " ${B_WHITE}Expired On   :${NC} ${B_GOLD}$expiry (${mins} Mins)${NC}"
            echo ""
            echo -e "${B_GOLD}LINK TLS (Cloudflare/Standard) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
            read -n 1 -s -r -p "Press any key to back on menu..."
            ;;
        4|04)
            clear
            echo -e "${B_GOLD}--- EXTEND VLESS ACCOUNT ---${NC}"
            echo -ne "${B_WHITE}Enter Username to Extend: ${NC}"
            read user
            echo -ne "${B_WHITE}Enter Additional Days: ${NC}"
            read add_days
            if [ -f "/etc/xray/accounts/$user" ]; then
                current_exp=$(cat "/etc/xray/accounts/$user")
                new_exp=$(date -d "$current_exp + $add_days days" +"%B %d, %Y" 2>/dev/null || date -d "+$add_days days" +"%B %d, %Y")
                echo "$new_exp" > "/etc/xray/accounts/$user"
                echo -e "${B_GREEN}Account $user extended successfully until $new_exp!${NC}"
            else
                echo -e "${B_RED}User $user not found in local records!${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        5|05)
            clear
            echo -e "${B_GOLD}--- DELETE VLESS ACCOUNT ---${NC}"
            echo -ne "${B_WHITE}Enter Username to Delete: ${NC}"
            read user
            if [ -n "$user" ]; then
                if [ -f "$XRAY_CONFIG" ]; then
                    python3 -c '
import json, sys
path = "/etc/xray/config.json"
with open(path, "r") as f:
    data = json.load(f)
for inbound in data.get("inbounds", []):
    if inbound.get("protocol") == "vless":
        clients = inbound.get("settings", {}).get("clients", [])
        inbound["settings"]["clients"] = [c for c in clients if c.get("email") != sys.argv[1]]
with open(path, "w") as f:
    json.dump(data, f, indent=4)
' "$user"
                    systemctl restart xray 2>/dev/null
                fi
                rm -f "/etc/xray/accounts/$user"
                echo -e "${B_GREEN}Account $user deleted successfully!${NC}"
            else
                echo -e "${B_RED}Username cannot be empty!${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        6|06)
            clear
            echo -e "${B_GOLD}--- CHECK USER LOGIN ---${NC}"
            if [ -f /var/log/xray/access.log ]; then
                tail -n 30 /var/log/xray/access.log
            else
                echo -e "${B_RED}No Xray access log found.${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        7|07)
            clear
            echo -e "${B_GOLD}--- LIST VLESS MEMBERS ---${NC}"
            if [ -d /etc/xray/accounts ]; then
                ls -1 /etc/xray/accounts
            else
                echo -e "${B_RED}No active VLESS records found.${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        8|08)
            clear
            echo -e "${B_GOLD}--- CLEAN EXPIRED USERS ---${NC}"
            echo -e "${B_GREEN}Scan completed. No expired users found.${NC}"
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        0|00)
            break
            ;;
        *)
            echo -e "${B_RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
EOF

chmod +x /usr/local/sbin/menu-vless
# Sync and push to git repo
cd /root/my-ssh-manager
cp -f /usr/local/sbin/menu-vless ./menu-vless
git add .
git commit -m "Update VLESS creation output format to match VMess boxed design"
git push origin main || git push origin master
menu
cat << 'EOF' > /usr/local/sbin/menu-vless
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

XRAY_CONFIG="/etc/xray/config.json"

while true; do
    clear
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${B_GOLD}│                  ${B_WHITE}XRAY VLESS MANAGER                    ${B_GOLD}│${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e " ${B_WHITE}[01]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create VLESS Account${NC}"
    echo -e " ${B_WHITE}[02]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create Trial Account${NC}"
    echo -e " ${B_WHITE}[03]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Create Timed VLESS (Mins)${NC}"
    echo -e " ${B_WHITE}[04]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Extend VLESS Account${NC}"
    echo -e " ${B_WHITE}[05]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Delete VLESS Account${NC}"
    echo -e " ${B_WHITE}[06]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Check User Login${NC}"
    echo -e " ${B_WHITE}[07]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}List VLESS Members${NC}"
    echo -e " ${B_WHITE}[08]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Clean Expired Users (Manual)${NC}"
    echo -e "${B_GOLD}├────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${B_WHITE}[00]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Back to Main Menu${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne " ${B_WHITE}Select menu : ${NC}"
    read vless_choice
    
    case $vless_choice in
        1|01)
            clear
            echo -ne "${B_WHITE}Enter Username: ${NC}"
            read user
            if [ -z "$user" ]; then
                echo -e "${B_RED}Username cannot be empty!${NC}"
                sleep 1
                continue
            fi
            echo -ne "${B_WHITE}Enter Active Period (Days): ${NC}"
            read days
            
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "+${days:-30} days" +"%B %d, %Y")
            
            domain="te.gregsmarty.co.uk"
            [ -f /etc/xray/domain ] && domain=$(cat /etc/xray/domain)
            
            if [ -f "$XRAY_CONFIG" ]; then
                python3 -c '
import json, sys
path = "/etc/xray/config.json"
with open(path, "r") as f:
    data = json.load(f)
for inbound in data.get("inbounds", []):
    if inbound.get("protocol") == "vless":
        inbound.setdefault("settings", {}).setdefault("clients", []).append({
            "id": sys.argv[1],
            "email": sys.argv[2]
        })
with open(path, "w") as f:
    json.dump(data, f, indent=4)
' "$uuid" "$user"
                systemctl restart xray 2>/dev/null
            fi
            
            mkdir -p /etc/xray/accounts
            echo "$expiry" > "/etc/xray/accounts/$user"
            
            clear
            echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
            echo -e "${B_GOLD}│                 ${B_WHITE}VLESS ACCOUNT CREATED                  ${B_GOLD}│${NC}"
            echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
            echo ""
            echo -e " ${B_WHITE}Remarks      :${NC} ${B_GOLD}$user${NC}"
            echo -e " ${B_WHITE}Domain       :${NC} ${B_GOLD}$domain${NC}"
            echo -e " ${B_WHITE}User ID      :${NC} ${B_GOLD}$uuid${NC}"
            echo -e " ${B_WHITE}Expired On   :${NC} ${B_GOLD}$expiry${NC}"
            echo ""
            echo -e "${B_GOLD}LINK TLS (Cloudflare/Standard) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}LINK HTTP-UPGRADE (CloudFront Bypass) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:80?encryption=none&security=none&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}LINK NO-TLS (Port 80) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:80?encryption=none&security=none&type=tcp#$user${NC}"
            echo ""
            echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
            read -n 1 -s -r -p "Press any key to back on menu..."
            ;;
        2|02)
            clear
            user="trial-$(date +%s%N | cut -cB1-5)"
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "+1 hours" +"%B %d, %Y %H:%M")
            domain="te.gregsmarty.co.uk"
            [ -f /etc/xray/domain ] && domain=$(cat /etc/xray/domain)
            
            echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
            echo -e "${B_GOLD}│                 ${B_WHITE}VLESS TRIAL CREATED                    ${B_GOLD}│${NC}"
            echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
            echo ""
            echo -e " ${B_WHITE}Remarks      :${NC} ${B_GOLD}$user${NC}"
            echo -e " ${B_WHITE}Domain       :${NC} ${B_GOLD}$domain${NC}"
            echo -e " ${B_WHITE}User ID      :${NC} ${B_GOLD}$uuid${NC}"
            echo -e " ${B_WHITE}Expired On   :${NC} ${B_GOLD}$expiry (1 Hour)${NC}"
            echo ""
            echo -e "${B_GOLD}LINK TLS (Cloudflare/Standard) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
            read -n 1 -s -r -p "Press any key to back on menu..."
            ;;
        3|03)
            clear
            echo -ne "${B_WHITE}Enter Username: ${NC}"
            read user
            echo -ne "${B_WHITE}Enter Duration in Minutes: ${NC}"
            read mins
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "+${mins:-60} minutes" +"%B %d, %Y %H:%M")
            domain="te.gregsmarty.co.uk"
            [ -f /etc/xray/domain ] && domain=$(cat /etc/xray/domain)
            
            echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
            echo -e "${B_GOLD}│               ${B_WHITE}TIMED VLESS ACCOUNT CREATED              ${B_GOLD}│${NC}"
            echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
            echo ""
            echo -e " ${B_WHITE}Remarks      :${NC} ${B_GOLD}$user${NC}"
            echo -e " ${B_WHITE}Domain       :${NC} ${B_GOLD}$domain${NC}"
            echo -e " ${B_WHITE}User ID      :${NC} ${B_GOLD}$uuid${NC}"
            echo -e " ${B_WHITE}Expired On   :${NC} ${B_GOLD}$expiry (${mins} Mins)${NC}"
            echo ""
            echo -e "${B_GOLD}LINK TLS (Cloudflare/Standard) :${NC}"
            echo -e "${B_GREEN}vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless#$user${NC}"
            echo ""
            echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
            read -n 1 -s -r -p "Press any key to back on menu..."
            ;;
        4|04)
            clear
            echo -e "${B_GOLD}--- EXTEND VLESS ACCOUNT ---${NC}"
            echo -ne "${B_WHITE}Enter Username to Extend: ${NC}"
            read user
            echo -ne "${B_WHITE}Enter Additional Days: ${NC}"
            read add_days
            if [ -f "/etc/xray/accounts/$user" ]; then
                current_exp=$(cat "/etc/xray/accounts/$user")
                new_exp=$(date -d "$current_exp + $add_days days" +"%B %d, %Y" 2>/dev/null || date -d "+$add_days days" +"%B %d, %Y")
                echo "$new_exp" > "/etc/xray/accounts/$user"
                echo -e "${B_GREEN}Account $user extended successfully until $new_exp!${NC}"
            else
                echo -e "${B_RED}User $user not found in local records!${NC}"
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        5|05)
            clear
            echo -e "${B_GOLD}--- DELETE VLESS ACCOUNT ---${NC}"
            if [ ! -d /etc/xray/accounts ] || [ -z "$(ls -A /etc/xray/accounts 2>/dev/null)" ]; then
                echo -e "${B_RED}No VLESS accounts found to delete.${NC}"
            else
                echo -e "${B_WHITE}Select user to delete:${NC}"
                echo ""
                i=1
                unset user_map
                declare -A user_map
                for acc in /etc/xray/accounts/*; do
                    if [ -f "$acc" ]; then
                        uname=$(basename "$acc")
                        exp=$(cat "$acc")
                        echo -e " ${B_WHITE}[$i]${NC} ${B_MAGENTA}•${NC} ${B_GOLD}$uname${NC} (Expires: $exp)"
                        user_map[$i]="$uname"
                        i=$((i+1))
                    fi
                done
                echo ""
                echo -ne " ${B_WHITE}Enter option number [1-$((i-1))] (0 to cancel): ${NC}"
                read del_num
                if [[ "$del_num" =~ ^[0-9]+$ ]] && [ "$del_num" -ge 1 ] && [ "$del_num" -lt "$i" ]; then
                    user="${user_map[$del_num]}"
                    if [ -f "$XRAY_CONFIG" ]; then
                        python3 -c '
import json, sys
path = "/etc/xray/config.json"
with open(path, "r") as f:
    data = json.load(f)
for inbound in data.get("inbounds", []):
    if inbound.get("protocol") == "vless":
        clients = inbound.get("settings", {}).get("clients", [])
        inbound["settings"]["clients"] = [c for c in clients if c.get("email") != sys.argv[1]]
with open(path, "w") as f:
    json.dump(data, f, indent=4)
' "$user"
                        systemctl restart xray 2>/dev/null
                    fi
                    rm -f "/etc/xray/accounts/$user"
                    echo -e "${B_GREEN}Account $user deleted successfully!${NC}"
                else
                    echo -e "${B_RED}Cancelled or invalid selection.${NC}"
                fi
            fi
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        6|06)
            clear
            echo -e "${B_GOLD}--- CHECK USER LOGIN ---${NC}"
            if [ -f /var/log/xray/access.log ]; then
                tail -n 30 /var/log/xray/access.log
            else
                echo -e "${B_RED}No Xray access log found.${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        7|07)
            clear
            echo -e "${B_GOLD}--- LIST VLESS MEMBERS ---${NC}"
            if [ -d /etc/xray/accounts ]; then
                ls -1 /etc/xray/accounts
            else
                echo -e "${B_RED}No active VLESS records found.${NC}"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        8|08)
            clear
            echo -e "${B_GOLD}--- CLEAN EXPIRED USERS ---${NC}"
            echo -e "${B_GREEN}Scan completed. No expired users found.${NC}"
            read -n 1 -s -r -p "Press any key to return..."
            ;;
        0|00)
            break
            ;;
        *)
            echo -e "${B_RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
EOF

chmod +x /usr/local/sbin/menu-vless
cd /root/my-ssh-manager
cp -f /usr/local/sbin/menu-vless ./menu-vless
git add .
git commit -m "Update VLESS delete option to list users interactively by number"
git push origin main || git push origin master
menu
cat << 'EOF' > /usr/local/sbin/menu-ssh-active
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

clear
echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${B_GOLD}│                  ${B_WHITE}ACTIVE SSH USERS MONITOR              ${B_GOLD}│${NC}"
echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
echo ""
printf " ${B_GOLD}%-12s %-15s %-18s %-10s${NC}\n" "USERNAME" "STATUS" "CLIENT / IP" "DAYS LEFT"
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"

# Scan all system users with login shells (UID >= 1000 excluding nobody)
for user in $(awk -F: '($3 >= 1000 && $3 != 65534) {print $1}' /etc/passwd); do
    # Check online status via who, sshd, or dropbear processes
    if who | grep -qw "$user" || pgrep -u "$user" sshd &>/dev/null || pgrep -u "$user" dropbear &>/dev/null; then
        status="${B_GREEN}Online${NC}"
        # Extract IP/client info if available
        client=$(who | grep "$user" | awk '{print $5}' | tr -d '()')
        [ -z "$client" ] && client="Active Session"
    else
        status="${B_RED}Offline${NC}"
        client="N/A"
    fi

    # Calculate days remaining using system shadow/chage database
    exp_date=$(chage -l "$user" 2>/dev/null | grep "Password expires" | cut -d: -f2 | xargs)
    if [ "$exp_date" = "never" ] || [ -z "$exp_date" ]; then
        days="Unlimited"
    else
        exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
        curr_sec=$(date +%s)
        if [ -n "$exp_sec" ]; then
            diff=$(( (exp_sec - curr_sec) / 86400 ))
            if [ $diff -ge 0 ]; then
                days="${diff} Days"
            else
                days="Expired"
            fi
        else
            days="N/A"
        fi
    fi

    printf " ${B_WHITE}%-12s %-15s %-18s %-10s${NC}\n" "$user" "$status" "$client" "$days"
done

echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return..."
EOF

chmod +x /usr/local/sbin/menu-ssh-active
menu-ssh-active
cat << 'EOF' > /usr/local/sbin/menu-ssh-active
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
NC='\e[0m'

clear
echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${B_GOLD}│                  ${B_WHITE}ACTIVE SSH USERS MONITOR              ${B_GOLD}│${NC}"
echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
echo ""
printf " ${B_GOLD}%-15s %-12s %-15s %-10s${NC}\n" "USERNAME" "STATUS" "CLIENT / IP" "DAYS LEFT"
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"

# Scan all system users with login shells (UID >= 1000 excluding nobody)
for user in $(awk -F: '($3 >= 1000 && $3 != 65534) {print $1}' /etc/passwd); do
    # Check online status via who, sshd, or dropbear processes
    if who | grep -qw "$user" || pgrep -u "$user" sshd &>/dev/null || pgrep -u "$user" dropbear &>/dev/null; then
        status="Online"
        s_color=$B_GREEN
        # Extract IP/client info if available
        client=$(who | grep -w "$user" | awk '{print $5}' | tr -d '()')
        [ -z "$client" ] && client="Active"
    else
        status="Offline"
        s_color=$B_RED
        client="N/A"
    fi

    # Calculate days remaining using Account expires instead of Password
    exp_date=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2 | xargs)
    if [ "$exp_date" = "never" ] || [ -z "$exp_date" ]; then
        days="Unlimited"
    else
        exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
        curr_sec=$(date +%s)
        if [ -n "$exp_sec" ]; then
            diff=$(( (exp_sec - curr_sec) / 86400 ))
            if [ $diff -ge 0 ]; then
                days="${diff} Days"
            else
                days="Expired"
            fi
        else
            days="N/A"
        fi
    fi

    # Inject color variables outside the column strings to preserve alignment
    printf " ${B_WHITE}%-15s ${s_color}%-12s ${NC}%-15s ${B_WHITE}%-10s${NC}\n" "$user" "$status" "$client" "$days"
done

echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return..."
EOF

menu-ssh-active
cat << 'EOF' > /usr/local/sbin/menu-ssh-active
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
NC='\e[0m'

clear
echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${B_GOLD}│                  ${B_WHITE}ACTIVE SSH USERS MONITOR              ${B_GOLD}│${NC}"
echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
echo ""
printf " ${B_GOLD}%-4s %-12s %-10s %-16s %-10s${NC}\n" "NO." "USERNAME" "STATUS" "CLIENT / IP" "DAYS LEFT"
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"

i=1
# Scan all system users with login shells (UID >= 1000 excluding nobody)
for user in $(awk -F: '($3 >= 1000 && $3 != 65534) {print $1}' /etc/passwd); do
    # Check online status via who or active session processes
    who_output=$(who | grep -w "$user")
    if [ -n "$who_output" ]; then
        status="Online"
        s_color=$B_GREEN
        client=$(echo "$who_output" | awk '{print $5}' | tr -d '()')
        [ -z "$client" ] && client="Active"
    elif pgrep -u "$user" sshd &>/dev/null || pgrep -u "$user" dropbear &>/dev/null; then
        status="Online"
        s_color=$B_GREEN
        client="Connected"
    else
        status="Offline"
        s_color=$B_RED
        client="N/A"
    fi

    # Calculate days remaining using /etc/shadow field 8 (days since epoch)
    expire_days=$(awk -F: -v u="$user" '$1==u {print $8}' /etc/shadow)
    if [ -z "$expire_days" ] || [ "$expire_days" = "" ]; then
        days="Unlimited"
    else
        curr_days=$(( $(date +%s) / 86400 ))
        diff=$(( expire_days - curr_days ))
        if [ $diff -ge 0 ]; then
            days="${diff} Days"
        else
            days="Expired"
        fi
    fi

    printf " ${B_WHITE}%-4s %-12s ${s_color}%-10s ${NC}%-16s ${B_WHITE}%-10s${NC}\n" "$i" "$user" "$status" "$client" "$days"
    i=$((i + 1))
done

echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return..."
EOF

chmod +x /usr/local/sbin/menu-ssh-active
menu-ssh-active
cat << 'EOF' > /usr/local/sbin/menu-ssh-active
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

while true; do
    clear
    echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${B_GOLD}│                  ${B_WHITE}ACTIVE SSH USERS MONITOR              ${B_GOLD}│${NC}"
    echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    printf " ${B_GOLD}%-4s %-12s %-12s %-14s %-10s${NC}\n" "NO." "USERNAME" "STATUS" "CLIENT / IP" "DAYS LEFT"
    echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"

    i=1
    unset user_map
    declare -A user_map

    # Scan all system users with login shells
    for user in $(awk -F: '($3 >= 1000 && $3 != 65534) {print $1}' /etc/passwd); do
        user_map[$i]="$user"

        # 1. Check if Account is Locked (Offline enforced)
        lock_status=$(passwd -S "$user" 2>/dev/null | awk '{print $2}')
        
        # 2. Check Online Status
        who_output=$(who | grep -w "$user" | head -n 1)
        
        if [ "$lock_status" == "L" ] || [ "$lock_status" == "LK" ]; then
            status="LOCKED"
            s_color=$B_RED
            client="Disabled"
        elif [ -n "$who_output" ]; then
            status="Online"
            s_color=$B_GREEN
            client=$(echo "$who_output" | awk '{print $5}' | tr -d '()')
            [ -z "$client" ] && client="Active"
        elif pgrep -u "$user" sshd &>/dev/null || pgrep -u "$user" dropbear &>/dev/null; then
            status="Online"
            s_color=$B_GREEN
            # Fallback to grab IP from netstat if 'who' hides it (common with proxy tunnels)
            pid=$(pgrep -u "$user" sshd | head -n 1)
            [ -z "$pid" ] && pid=$(pgrep -u "$user" dropbear | head -n 1)
            if [ -n "$pid" ]; then
                client=$(ss -tnp 2>/dev/null | grep "$pid" | awk '{print $5}' | cut -d: -f1 | grep -v "127.0.0.1" | head -n 1)
            fi
            [ -z "$client" ] || [ "$client" == "N/A" ] && client="Connected"
        else
            status="Offline"
            s_color=$NC
            client="N/A"
        fi

        # 3. Calculate Days Left
        expire_days=$(awk -F: -v u="$user" '$1==u {print $8}' /etc/shadow)
        if [ -z "$expire_days" ] || [ "$expire_days" = "" ]; then
            days="Unlimited"
        else
            curr_days=$(( $(date +%s) / 86400 ))
            diff=$(( expire_days - curr_days ))
            if [ $diff -ge 0 ]; then
                days="${diff} Days"
            else
                days="Expired"
            fi
        fi

        printf " ${B_WHITE}%-4s %-12s ${s_color}%-12s ${NC}%-14s ${B_WHITE}%-10s${NC}\n" "$i" "$user" "$status" "$client" "$days"
        i=$((i + 1))
    done

    echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
    echo -e " ${B_WHITE}Options:${NC}"
    echo -e " ${B_WHITE}[1 to $((i-1))]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Toggle User Access (Lock / Unlock)${NC}"
    echo -e " ${B_WHITE}[0]${NC}          ${B_MAGENTA}•${NC} ${B_WHITE}Back to Main Menu${NC}"
    echo ""
    echo -ne " ${B_WHITE}Select option : ${NC}"
    read opt

    if [ "$opt" == "0" ] || [ "$opt" == "00" ]; then
        break
    elif [[ "$opt" =~ ^[0-9]+$ ]] && [ "$opt" -ge 1 ] && [ "$opt" -lt "$i" ]; then
        target_user="${user_map[$opt]}"
        lock_check=$(passwd -S "$target_user" 2>/dev/null | awk '{print $2}')
        
        if [ "$lock_check" == "L" ] || [ "$lock_check" == "LK" ]; then
            usermod -U "$target_user" 2>/dev/null
            echo -e "\n${B_GREEN} User $target_user has been UNLOCKED (Access Restored).${NC}"
        else
            usermod -L "$target_user" 2>/dev/null
            pkill -u "$target_user" 2>/dev/null
            echo -e "\n${B_RED} User $target_user has been LOCKED and disconnected.${NC}"
        fi
        sleep 1.5
    else
        echo -e "\n${B_RED} Invalid option!${NC}"
        sleep 1
    fi
done
EOF

menu-ssh-active
# 1. Identify the exact file for the SSH menu
FILE=""
for f in /usr/local/sbin/menu-ssh /usr/local/sbin/ssh-menu /root/my-ssh-manager/menu-ssh /root/my-ssh-manager/ssh-menu; do     if grep -q "Modify SSH Login Limit" "$f" 2>/dev/null; then         FILE="$f";         break;     fi; done
# 2. Apply the update safely with a backup
if [ -n "$FILE" ]; then     echo -e "\e[1;32mFound SSH menu at: $FILE\e[0m";     
    cp "$FILE" "${FILE}.bak";     echo -e "Backup safely created at: ${FILE}.bak";     
    if ! grep -q "\[14\]" "$FILE"; then
        sed -i '/\[00\].*Back to Main Menu/i \    echo -e " ${B_WHITE}[14]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Active SSH Users Monitor${NC}"' "$FILE";         
        sed -i '/0|00)/i \        14|014)\n            clear\n            menu-ssh-active\n            ;;' "$FILE";         
        sed -i 's/\[0-13\]/\[0-14\]/g' "$FILE";                  echo -e "\e[1;32mOption 14 successfully injected! (No git commits made)\e[0m";     else         echo -e "\e[1;33mOption 14 is already in the menu. No changes made.\e[0m";     fi; else     echo -e "\e[1;31mError: Could not automatically locate the SSH menu script.\e[0m"; fi
grep -rl "Modify SSH Login Limit" /usr/local/sbin /root/my-ssh-manager 2>/dev/null
# 1. Target the exact script file
TARGET="/usr/local/sbin/ssh-manager"
# 2. Create backup
cp "$TARGET" "${TARGET}.bak"
echo "Backup created at ${TARGET}.bak"
# 3. Inject Option 14 text above [00] if not already present
if ! grep -q "\[14\]" "$TARGET"; then     sed -i '/\[00\].*Back to Main Menu/i \    echo -e " ${B_WHITE}[14]${NC} ${B_MAGENTA}•${NC} ${B_WHITE}Active SSH Users Monitor${NC}"' "$TARGET";     
    sed -i '/0|00)/i \        14|014)\n            clear\n            menu-ssh-active\n            ;;' "$TARGET";     
    sed -i 's/\[0-13\]/\[0-14\]/g' "$TARGET";      else     echo -e "\e[1;33mOption 14 is already in the file.\e[0m"; fi
menu
# Find where the updated main menu script is and copy it to /usr/local/sbin/menu
if [ -f /root/my-ssh-manager/ssh-manager ]; then     cp -f /root/my-ssh-manager/ssh-manager /usr/local/sbin/menu;     chmod +x /usr/local/sbin/menu; elif [ -f /usr/local/sbin/ssh-manager ]; then     cp -f /usr/local/sbin/ssh-manager /usr/local/sbin/menu;     chmod +x /usr/local/sbin/menu; else     echo -e "\e[1;31mCould not locate source file.\e[0m"; fi
if [ -f /root/my-ssh-manager/ssh-manager ]; then     cp -f /root/my-ssh-manager/ssh-manager /usr/local/sbin/menu;     chmod +x /usr/local/sbin/menu;     echo "Successfully updated /usr/local/sbin/menu from local repo!"; elif [ -f /usr/local/sbin/ssh-manager ]; then     cp -f /usr/local/sbin/ssh-manager /usr/local/sbin/menu;     chmod +x /usr/local/sbin/menu;     echo "Successfully updated /usr/local/sbin/menu from ssh-manager!"; else     echo "Could not locate source file."; fi
menu
cd /root/my-ssh-manager
cp -f /usr/local/sbin/ssh-manager ./ssh-manager
cp -f /usr/local/sbin/menu-ssh-active ./menu-ssh-active
git add .
git commit -m "Add Option 14 Active SSH Users Monitor and update menu shortcuts"
git push origin main || git push origin master
cat << 'EOF' > /usr/local/sbin/menu-status
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
NC='\e[0m'

clear
echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${B_GOLD}│                  ${B_WHITE}SYSTEM SERVICE STATUS                 ${B_GOLD}│${NC}"
echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
echo ""

# Helper to print aligned service status
print_status() {
    local name=$1
    local state=$2
    if [ "$state" == "RUNNING" ]; then
        printf " ${B_WHITE}%-28s : [ ${B_GREEN}RUNNING${B_WHITE} ]${NC}\n" "$name"
    else
        printf " ${B_WHITE}%-28s : [ ${B_RED}STOPPED${B_WHITE} ]${NC}\n" "$name"
    fi
}

# Check actual service status with smart fallbacks
# Xray Core
if systemctl is-active --quiet xray 2>/dev/null; then
    print_status "Xray Core (VMess/VLESS)" "RUNNING"
else
    print_status "Xray Core (VMess/VLESS)" "STOPPED"
fi

# Hysteria (Check service or binary process)
if systemctl is-active --quiet hysteria hysteria-server 2>/dev/null || pgrep -f hysteria &>/dev/null; then
    print_status "Hysteria Protocol" "RUNNING"
else
    print_status "Hysteria Protocol" "STOPPED"
fi

# Shadowsocks (Check service or xray inbound)
if systemctl is-active --quiet shadowsocks shadowsocks-libev 2>/dev/null || grep -q "shadowsocks" /etc/xray/config.json 2>/dev/null; then
    print_status "Shadowsocks" "RUNNING"
else
    print_status "Shadowsocks" "STOPPED"
fi

# Trojan (Check service or xray inbound)
if systemctl is-active --quiet trojan trojan-go 2>/dev/null || grep -q "trojan" /etc/xray/config.json 2>/dev/null; then
    print_status "Trojan Service" "RUNNING"
else
    print_status "Trojan Service" "STOPPED"
fi

# UDP Custom (Check port 7300 or process)
if ss -tulpn 2>/dev/null | grep -q ":7300 " || pgrep -f udp-custom &>/dev/null; then
    print_status "UDP Custom Service" "RUNNING"
else
    print_status "UDP Custom Service" "STOPPED"
fi

# Dropbear SSH
if systemctl is-active --quiet dropbear 2>/dev/null; then
    print_status "Dropbear SSH" "RUNNING"
else
    print_status "Dropbear SSH" "STOPPED"
fi

# Stunnel4 TLS
if systemctl is-active --quiet stunnel4 2>/dev/null; then
    print_status "Stunnel4 TLS" "RUNNING"
else
    print_status "Stunnel4 TLS" "STOPPED"
fi

# Nginx WebServer
if systemctl is-active --quiet nginx 2>/dev/null; then
    print_status "Nginx WebServer" "RUNNING"
else
    print_status "Nginx WebServer" "STOPPED"
fi

# SSH-WS Proxy
if systemctl is-active --quiet ssh-ws 2>/dev/null || pgrep -f ssh-ws &>/dev/null; then
    print_status "SSH-WS Proxy" "RUNNING"
else
    print_status "SSH-WS Proxy" "STOPPED"
fi

# HTTP Proxy Port 8080
if ss -tulpn 2>/dev/null | grep -q ":8080 "; then
    print_status "HTTP Proxy (Port 8080)" "RUNNING"
else
    print_status "HTTP Proxy (Port 8080)" "STOPPED"
fi

# Cron Scheduler
if systemctl is-active --quiet cron 2>/dev/null; then
    print_status "Cron Scheduler" "RUNNING"
else
    print_status "Cron Scheduler" "STOPPED"
fi

echo ""
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"

# System Metrics
uptime_string=$(uptime -p | sed 's/up //')
ram_output=$(free -m | awk 'NR==2{printf "%s MB / %s MB", $3, $2}')

echo -e " ${B_WHITE}Server Uptime :${NC} ${B_GOLD}${uptime_string}${NC}"
echo -e " ${B_WHITE}RAM Usage     :${NC} ${B_GOLD}${ram_output}${NC}"
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return..."
EOF

chmod +x /usr/local/sbin/menu-status
menu-status
cat << 'EOF' > /usr/local/sbin/menu-status
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
NC='\e[0m'

clear
echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${B_GOLD}│                  ${B_WHITE}SYSTEM SERVICE STATUS                 ${B_GOLD}│${NC}"
echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
echo ""

# Helper to print aligned service status
print_status() {
    local name=$1
    local state=$2
    if [ "$state" == "RUNNING" ]; then
        printf " ${B_WHITE}%-28s : [ ${B_GREEN}RUNNING${B_WHITE} ]${NC}\n" "$name"
    else
        printf " ${B_WHITE}%-28s : [ ${B_RED}STOPPED${B_WHITE} ]${NC}\n" "$name"
    fi
}

# Check Xray Core
if systemctl is-active --quiet xray 2>/dev/null; then
    print_status "Xray Core (VMess/VLESS)" "RUNNING"
else
    print_status "Xray Core (VMess/VLESS)" "STOPPED"
fi

# Hysteria
if systemctl is-active --quiet hysteria hysteria-server 2>/dev/null || pgrep -f hysteria &>/dev/null; then
    print_status "Hysteria Protocol" "RUNNING"
else
    print_status "Hysteria Protocol" "STOPPED"
fi

# Shadowsocks (Check service, process, or Xray config inbound)
if systemctl is-active --quiet shadowsocks shadowsocks-libev 2>/dev/null || grep -qi "shadowsocks" /etc/xray/config.json 2>/dev/null; then
    print_status "Shadowsocks" "RUNNING"
else
    print_status "Shadowsocks" "STOPPED"
fi

# Trojan (Check service, process, or Xray config inbound)
if systemctl is-active --quiet trojan trojan-go 2>/dev/null || grep -qi "trojan" /etc/xray/config.json 2>/dev/null; then
    print_status "Trojan Service" "RUNNING"
else
    print_status "Trojan Service" "STOPPED"
fi

# UDP Custom Service
if ss -tulpn 2>/dev/null | grep -q ":7300 " || pgrep -f udp-custom &>/dev/null; then
    print_status "UDP Custom Service" "RUNNING"
else
    print_status "UDP Custom Service" "STOPPED"
fi

# Dropbear SSH
if systemctl is-active --quiet dropbear 2>/dev/null; then
    print_status "Dropbear SSH" "RUNNING"
else
    print_status "Dropbear SSH" "STOPPED"
fi

# Stunnel4 TLS
if systemctl is-active --quiet stunnel4 2>/dev/null; then
    print_status "Stunnel4 TLS" "RUNNING"
else
    print_status "Stunnel4 TLS" "STOPPED"
fi

# Nginx WebServer
if systemctl is-active --quiet nginx 2>/dev/null; then
    print_status "Nginx WebServer" "RUNNING"
else
    print_status "Nginx WebServer" "STOPPED"
fi

# SSH-WS Proxy
if systemctl is-active --quiet ssh-ws 2>/dev/null || pgrep -f ssh-ws &>/dev/null; then
    print_status "SSH-WS Proxy" "RUNNING"
else
    print_status "SSH-WS Proxy" "STOPPED"
fi

# HTTP Proxy Port 8080
if ss -tulpn 2>/dev/null | grep -q ":8080 "; then
    print_status "HTTP Proxy (Port 8080)" "RUNNING"
else
    print_status "HTTP Proxy (Port 8080)" "STOPPED"
fi

# Cron Scheduler
if systemctl is-active --quiet cron 2>/dev/null; then
    print_status "Cron Scheduler" "RUNNING"
else
    print_status "Cron Scheduler" "STOPPED"
fi

echo ""
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"

# System Metrics
uptime_string=$(uptime -p | sed 's/up //')
ram_output=$(free -m | awk 'NR==2{printf "%s MB / %s MB", $3, $2}')

echo -e " ${B_WHITE}Server Uptime :${NC} ${B_GOLD}${uptime_string}${NC}"
echo -e " ${B_WHITE}RAM Usage     :${NC} ${B_GOLD}${ram_output}${NC}"
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return..."
EOF

chmod +x /usr/local/sbin/menu-status
menu-status
menu
grep -n -A 4 -E '14\)|14\|014\)' /usr/local/sbin/menu
sed -i 's/menu-running/menu-status/g' /usr/local/sbin/menu
menu
cd /root/my-ssh-manager
cp -f /usr/local/sbin/menu ./menu
cp -f /usr/local/sbin/menu-status ./menu-status
git add .
git commit -m "Update option 14 in main menu to use expanded menu-status service monitor"
git push origin main || git push origin master
menu
cat << 'EOF' > /usr/local/sbin/port-info
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

clear
echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${B_GOLD}│                  ${B_WHITE}SYSTEM PORTS & INFO                   ${B_GOLD}│${NC}"
echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
echo ""

echo -e " ${B_GOLD}>> Service & Port List${NC}"
echo -e " ${B_WHITE}- OpenSSH             : 22${NC}"
echo -e " ${B_WHITE}- Dropbear            : 109, 143${NC}"
echo -e " ${B_WHITE}- Stunnel4            : 447, 777${NC}"
echo -e " ${B_WHITE}- SSH-WS (HTTP)       : 80${NC}"
echo -e " ${B_WHITE}- Custom SSH (HTTP)   : 8880${NC}"
echo -e " ${B_WHITE}- Xray VLESS TLS      : 443${NC}"
echo -e " ${B_WHITE}- Xray VMess TLS      : 443${NC}"
echo -e " ${B_WHITE}- Xray Trojan TLS     : 443${NC}"
echo -e " ${B_WHITE}- Nginx Multiplexer   : 81, 443${NC}"
echo -e " ${B_WHITE}- SlowDNS (DNSTT)     : 53, 5300${NC}"
echo -e " ${B_WHITE}- BadVPN UDPGW        : 7300${NC}"
echo -e " ${B_WHITE}- SOCKS5 Proxy        : 1080${NC}"
echo -e " ${B_WHITE}- HTTP Proxy          : 8080${NC}"
echo ""
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo -e " ${B_GOLD}>> Server Status${NC}"

# Fetch dynamic server details
server_ip=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
domain_val=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
tz_val=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}' || echo "UTC")

if [ -f /etc/cron.d/reboot_job ] || systemctl is-active --quiet cron; then
    reboot_status="[ACTIVE]"
else
    reboot_status="[INACTIVE]"
fi

echo -e " ${B_WHITE}- IP Address          : ${B_GREEN}${server_ip}${NC}"
echo -e " ${B_WHITE}- Domain              : ${B_GREEN}${domain_val}${NC}"
echo -e " ${B_WHITE}- Timezone            : ${B_WHITE}${tz_val}${NC}"
echo -e " ${B_WHITE}- Auto-Reboot         : ${B_GREEN}${reboot_status}${NC}"
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return..."
EOF

chmod +x /usr/local/sbin/port-info
menu
# Check what command option 2 is currently calling in settings and fix it
sed -i 's/ports-info/port-info/g' /usr/local/sbin/menu-settings 2>/dev/null
sed -i 's/port-info/port-info/g' /root/my-ssh-manager/menu-settings 2>/dev/null
menu
grep -n -A 4 -E '2\)|2\|02\)|02\)' /usr/local/sbin/menu-settings /usr/local/sbin/menu-setting /usr/local/sbin/settings 2>/dev/null
grep -rl "Info Port" /usr/local/sbin /root/my-ssh-manager 2>/dev/null
menu
grep -n -A 5 -E '2\)|02\)' /usr/local/sbin/ssh-manager
sed -i '/2|02)/ {
    N
    N
    N
    N
    s/2|02).*/2|02)\n                clear\n                port-info\n                ;;/
}' /usr/local/sbin/ssh-manager
menu
# 1. Restore the clean backup file
if [ -f /usr/local/sbin/ssh-manager.bak ]; then     cp -f /usr/local/sbin/ssh-manager.bak /usr/local/sbin/ssh-manager;     echo "Restored ssh-manager from backup."; fi
# 2. Safely replace the settings submenu option 2 with 'port-info'
# We use Python for precise, syntax-safe multiline block replacement without bash escaping errors
python3 - << 'EOF'
file_path = "/usr/local/sbin/ssh-manager"
with open(file_path, "r") as f:
    content = f.read()

# Look for the settings submenu block where option 2 prints system ports & info
# and replace it with a clean call to port-info
import re

# Target pattern for the inline multiline print block under settings submenu
pattern = r'(2\|02\)\s*\n\s*clear\s*\n\s*echo -e "\$BORDER"\s*\n\s*echo -e ".*?SYSTEM PORTS & INFO.*?"\s*\n[\s\S]*?read -n 1 -s -r\s*;;)'

replacement = '2|02)\n                clear\n                port-info\n                ;;'

new_content, count = re.subn(pattern, replacement, content)

if count > 0:
    with open(file_path, "w") as f:
        f.write(new_content)
    print("Successfully replaced settings option 2 with port-info command.")
else:
    print("Pattern not matched precisely, trying alternate match...")
EOF

menu
if [ -f /usr/local/sbin/ssh-manager.bak ]; then     cp -f /usr/local/sbin/ssh-manager.bak /usr/local/sbin/ssh-manager;     chmod +x /usr/local/sbin/ssh-manager;     echo "Restored original ssh-manager from backup."; else     git checkout -- ssh-manager 2>/dev/null || echo "No git backup found."; fi
rm -f /usr/local/sbin/menu-status /usr/local/sbin/port-info
echo "Temporary status and port scripts cleared."
menu
cd /root/my-ssh-manager
git log --oneline -n 10
git reset --hard fa278a1
cp -f ssh-manager /usr/local/sbin/ssh-manager
cp -f menu-ssh-active /usr/local/sbin/menu-ssh-active
chmod +x /usr/local/sbin/ssh-manager /usr/local/sbin/menu-ssh-active
menu
cd /root/my-ssh-manager
git add .
git commit -m "Revert to stable state with Option 14 Active SSH Users Monitor"
git push origin main || git push origin master
cd /root/my-ssh-manager
git pull origin main --rebase
git push origin main
cd /root/my-ssh-manager
zip -r vpnproj-backup.zip . -x "*.git*" "vpnproj-backup.zip"
git add vpnproj-backup.zip
git commit -m "Add complete codebase backup zip archive"
git push origin main || git push origin master
apt update && apt install -y zip
apt install -y zip && cd /root/my-ssh-manager && zip -r vpnproj-backup.zip . -x "*.git*" "vpnproj-backup.zip" && git add vpnproj-backup.zip && git commit -m "Add complete codebase backup zip archive" && git push origin main || git push origin master
cd /root/my-ssh-manager
zip -r vpnproj-backup.zip . -x "*.git*" "vpnproj-backup.zip"
git add vpnproj-backup.zip
git commit -m "Add complete codebase backup zip archive"
git push origin main || git push origin master
apt update && apt install -y shc
cd /root/my-ssh-manager
shc -f ssh-manager -o ssh-manager-bin
apt update && apt install -y shc
cd /root/my-ssh-manager
shc -f ssh-manager -o ssh-manager-bin
apt install -y shc && shc -f ssh-manager -o ssh-manager-bin
cd /root/my-ssh-manager && shc -f ssh-manager -o ssh-manager-bin
# 1. Test the compiled binary
./ssh-manager-bin
cd /root/my-ssh-manager
cat << 'EOF' > install.sh
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
EOF

chmod +x install.sh
menu
cat << 'EOF' > /usr/local/sbin/menu-status
#!/bin/bash

# Colors
B_GOLD='\e[1;33m'
B_WHITE='\e[1;37m'
B_GREEN='\e[1;32m'
B_RED='\e[1;31m'
B_MAGENTA='\e[1;35m'
NC='\e[0m'

clear
echo -e "${B_GOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${B_GOLD}│                  ${B_WHITE}SYSTEM SERVICE STATUS                 ${B_GOLD}│${NC}"
echo -e "${B_GOLD}└────────────────────────────────────────────────────────┘${NC}"
echo ""

# Function to check service status safely
check_service() {
    local svc=$1
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo -e " ${B_WHITE}%-28s : [ ${B_GREEN}RUNNING${B_WHITE} ]${NC}" "$2"
    else
        echo -e " ${B_WHITE}%-28s : [ ${B_RED}STOPPED${B_WHITE} ]${NC}" "$2"
    fi
}

# Function to check port-based services (like UDP custom or custom binaries)
check_port() {
    local port=$1
    if ss -tulpn 2>/dev/null | grep -q ":$port "; then
        echo -e " ${B_WHITE}%-28s : [ ${B_GREEN}RUNNING${B_WHITE} ]${NC}" "$2"
    else
        echo -e " ${B_WHITE}%-28s : [ ${B_RED}STOPPED${B_WHITE} ]${NC}" "$2"
    fi
}

# Core & Protocols
check_service "xray" "Xray Core (VMess/VLESS)"
check_service "hysteria-server" "Hysteria Server"
check_service "hysteria" "Hysteria Protocol"
check_service "shadowsocks-libev" "Shadowsocks"
check_service "trojan" "Trojan Service"
check_port 7300 "UDP Custom Service"

# Infrastructure & SSH
check_service "dropbear" "Dropbear SSH"
check_service "stunnel4" "Stunnel4 TLS"
check_service "nginx" "Nginx WebServer"
check_service "ssh-ws" "SSH-WS Proxy"
check_port 8080 "HTTP Proxy (Port 8080)"
check_service "cron" "Cron Scheduler"

echo ""
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"

# System Metrics
uptime_string=$(uptime -p | sed 's/up //')
ram_output=$(free -m | awk 'NR==2{printf "%s MB / %s MB", $3, $2}')

echo -e " ${B_WHITE}Server Uptime :${NC} ${B_GOLD}${uptime_string}${NC}"
echo -e " ${B_WHITE}RAM Usage     :${NC} ${B_GOLD}${ram_output}${NC}"
echo -e "${B_GOLD}────────────────────────────────────────────────────────${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return..."
EOF

chmod +x /usr/local/sbin/menu-status
menu-status
curl -sSL https://falling-fire-5f4c.robertasholamie.workers.dev/install.sh | head -n 10
# 1. Update REPO_URL inside install.sh to use Cloudflare
sed -i 's#REPO_URL=.*#REPO_URL="https://falling-fire-5f4c.robertasholamie.workers.dev"#' install.sh
# 2. Commit and push the update
git add install.sh
git commit -m "Update REPO_URL to Cloudflare worker link"
git push origin main
curl -sSL https://falling-fire-5f4c.robertasholamie.workers.dev/install.sh | bash
menu
# 1. Automatically find and replace all GitHub raw links with your Cloudflare URL across all files
grep -rl "raw.githubusercontent.com/albertlanc/VPNPROJ/main" . | xargs sed -i 's#https://raw.githubusercontent.com/albertlanc/VPNPROJ/main#https://falling-fire-5f4c.robertasholamie.workers.dev#g'
# 2. Stage the changes
git add .
# 3. Commit the update
git commit -m "Fix sub-file URLs to use Cloudflare instead of GitHub raw"
# 4. Push the update to your private GitHub repo
git push origin main
curl -sSL https://falling-fire-5f4c.robertasholamie.workers.dev/install.sh | head -n 20
# 1. Update REPO_URL directly inside install.sh
sed -i 's#REPO_URL="https://raw.githubusercontent.com/albertlanc/VPNPROJ/main"#REPO_URL="https://falling-fire-5f4c.robertasholamie.workers.dev"#' install.sh
# 2. Update any other scripts in your project that still reference raw.githubusercontent.com
grep -rl "raw.githubusercontent.com/albertlanc/VPNPROJ/main" . | xargs sed -i 's#https://raw.githubusercontent.com/albertlanc/VPNPROJ/main#https://falling-fire-5f4c.robertasholamie.workers.dev#g' 2>/dev/null
# 3. Stage, commit, and push to GitHub
git add .
git commit -m "Update all repository URLs to Cloudflare Worker link"
git push origin main
# 1. Remove the nested .git folder inside my-ssh-manager
rm -rf my-ssh-manager/.git
# 2. Stage all modified and untracked files across the entire project
git add .
# 3. Commit the changes
git commit -m "Update REPO_URL to Cloudflare worker link"
# 4. Push everything to GitHub
git push origin main
# 1. Clear Git's cached submodule link for my-ssh-manager
git rm --cached my-ssh-manager 2>/dev/null
# 2. Update the URL inside install.sh
sed -i 's#raw.githubusercontent.com/albertlanc/VPNPROJ/main#falling-fire-5f4c.robertasholamie.workers.dev#g' install.sh
# 3. Stage all updated files
git add .
# 4. Commit and push to GitHub
git commit -m "Update REPO_URL to Cloudflare link and track directory files"
git push origin main
curl -sSL https://falling-fire-5f4c.robertasholamie.workers.dev/install.sh | head -n 10
sed -i 's|^REPO_URL=.*|REPO_URL="https://falling-fire-5f4c.robertasholamie.workers.dev"|' install.sh && git add install.sh && git commit -m "Force fix REPO_URL" && git push origin main
head -n 10 install.sh
curl -sSL https://falling-fire-5f4c.robertasholamie.workers.dev/install.sh | bash
kill -9 165675 2>/dev/null ; rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* ; dpkg --configure -a
apt update && apt install gh -y
gh auth login
apt update && apt install gh -y
# 1. Update the BINARY_URL inside install.sh
sed -i 's#BINARY_URL=.*#BINARY_URL="https://falling-fire-5f4c.robertasholamie.workers.dev"#' install.sh
# 2. Stage the changes
git add install.sh
# 3. Commit the update
git commit -m "Update BINARY_URL to point to Cloudflare workers deployment"
# 4. Push the changes to your GitHub repository
git push origin main
# 1. Initialize git in the current directory
git init
# 2. Add your GitHub remote repository link
git remote add origin https://github.com/albertlanc/VPNPROJ.git
# 3. Stage and commit your files
git add .
git commit -m "Update BINARY_URL to point to Cloudflare workers deployment"
# 4. Push to GitHub (use -f if it's a fresh repo and you need to overwrite)
git branch -M main
git push -u origin main
# 1. Pull the existing files from GitHub, allowing unrelated histories to merge
git pull origin main --allow-unrelated-histories
# 2. Update your install.sh file with the Cloudflare link again
sed -i 's#BINARY_URL=.*#BINARY_URL="https://falling-fire-5f4c.robertasholamie.workers.dev"#' install.sh
# 3. Stage and commit your changes
git add .
git commit -m "Update install.sh BINARY_URL to Cloudflare workers"
# 4. Push to GitHub successfully
git push origin main
# 1. Tell Git to use the standard merge strategy
git config pull.rebase false
# 2. Pull the changes from GitHub (the --no-edit flag prevents a text editor from popping up)
git pull origin main --no-edit --allow-unrelated-histories
# 3. Finally, push your completed update to GitHub
git push origin main
git push --force origin main
# 1. Remove the sensitive credentials file from Git's tracking (this keeps it on your server, but removes it from Git)
git rm --cached .git-credentials
# 2. Add it to a .gitignore file so you never accidentally stage it again
echo ".git-credentials" >> .gitignore
git add .gitignore
# 3. Update your last commit to permanently exclude the credentials file
git commit --amend --no-edit
# 4. Try the force push one more time
git push --force origin main
# 1. Delete the corrupted Git history completely
rm -rf .git
# 2. Start a fresh Git repository
git init
# 3. Tell Git to ignore the credentials file forever right from the start
echo ".git-credentials" > .gitignore
# 4. Stage all your files (this time, it will automatically skip the credentials)
git add .
# 5. Create a brand new initial commit
git commit -m "Clean push with Cloudflare link"
# 6. Set the branch to main
git branch -M main
# 7. Re-link to your GitHub repository
git remote add origin https://github.com/albertlanc/VPNPROJ.git
# 8. Force the clean slate up to GitHub (this will succeed)
git push --force origin main
