cat << 'EOF' > /usr/local/sbin/add-ssh
#!/bin/bash
# menu/add-ssh.sh

# Green Color Formatting
G='\033[1;32m'
NC='\033[0m'

clear
echo -e "${G}==================================================${NC}"
echo -e "${G}            CREATE SSH & SLOWDNS ACCOUNT          ${NC}"
echo -e "${G}==================================================${NC}"
read -p "Username : " USER
read -p "Password : " PASS
read -p "Expiry (Days) : " DAYS

# Verify user doesn't already exist
if id "$USER" &>/dev/null; then
    echo -e "\nError: User '$USER' already exists!"
    sleep 2
    menu
    exit 1
fi

# Format Expiration Dates
EXP_DATE_SYS=$(date -d "+${DAYS} days" +"%Y-%m-%d")
EXP_DATE_DISP=$(date -d "+${DAYS} days" +"%b %d, %Y")

# Create System User
useradd -e "$EXP_DATE_SYS" -M -s /bin/false "$USER" &> /dev/null
echo "$USER:$PASS" | chpasswd

# Fetch Server Information
IP=$(curl -s ifconfig.me)
PUB_KEY=$(cat /etc/slowdns/server.pub 2>/dev/null || echo "Key not found")

# Safely extract the Nameserver without printing blank lines
NS_DOMAIN=$(grep "ExecStart" /etc/systemd/system/slowdns.service 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="/etc/slowdns/server.key") print $(i+1)}')
if [ -z "$NS_DOMAIN" ]; then
    NS_DOMAIN="Not Configured"
fi

# Clear screen to display final output page
clear
echo -e "${G}==================================================${NC}"
echo -e "${G}          ACCOUNT SSH WS & SLOWDNS                ${NC}"
echo -e "${G}==================================================${NC}"
echo -e "${G}Username        : ${USER}${NC}"
echo -e "${G}Password        : ${PASS}${NC}"
echo -e "${G}Expired On      : ${EXP_DATE_DISP}${NC}"
echo -e "${G}==================================================${NC}"
echo -e "${G}          SERVER INFORMATION                      ${NC}"
echo -e "${G}==================================================${NC}"
echo -e "${G}IP              : ${IP}${NC}"
echo -e "${G}Nameserver      : ${NS_DOMAIN}${NC}"
echo -e "${G}PubKey          : ${PUB_KEY}${NC}"
echo -e "${G}SSH-WS Port     : 80${NC}"
echo -e "${G}SSH-WS Path     : /ssh${NC}"
echo -e "${G}Dropbear Port   : 2222${NC}"
echo -e "${G}SlowDNS Port    : 53${NC}"
echo -e "${G}==================================================${NC}"
echo -e "${G}SSH-WS Client Config:${NC}"
echo -e "${G}${IP}:80@${USER}:${PASS}${NC}"
echo -e "${G}==================================================${NC}"
echo -e "${G}(Payload WS - Port 80)${NC}"
echo -e "${G}GET /ssh HTTP/1.1[crlf]Host: ${IP}[crlf]Upgrade: websocket[crlf][crlf]${NC}"
echo -e "${G}==================================================${NC}"
echo ""
read -n 1 -s -r -p "Press any key to return to main menu..."
menu
EOF

chmod +x /usr/local/sbin/add-ssh

