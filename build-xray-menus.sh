#!/bin/bash
NC='\e[0m'; GREEN='\e[0;32m'; CYAN='\e[0;36m'; YELLOW='\e[0;33m'; BLUE='\e[0;34m'; RED='\e[0;31m'

# Ensure databases and logs exist
mkdir -p /etc/xray
touch /etc/xray/vmess-users.db /etc/xray/vless-users.db
touch /var/log/xray/access.log

IP=$(curl -sS ipv4.icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "$IP")

# ==========================================
# 1. TRIAL ACCOUNT SCRIPTS
# ==========================================
for proto in vmess vless; do
cat << _EOF_ > /usr/local/sbin/trial-${proto}
#!/bin/bash
NC='\e[0m'; GREEN='\e[0;32m'; CYAN='\e[0;36m'; YELLOW='\e[0;33m'; BLUE='\e[0;34m'
user="TRIAL-\$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)"
uuid=\$(cat /proc/sys/kernel/random/uuid)
exp_sys=\$(date -d "tomorrow" +"%Y-%m-%d")

echo -e "\${user} \${uuid} \${exp_sys}" >> /etc/xray/${proto}-users.db

clear
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -e "       \${YELLOW}TRIAL ACCOUNT CREATED\${NC}"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "Remarks" "\$user"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "Domain" "$DOMAIN"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "User ID" "\$uuid"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "Expired On" "24 Hours (Trial)"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
_EOF_

if [ "$proto" == "vmess" ]; then
cat << '_EOF_' >> /usr/local/sbin/trial-vmess
echo '{"v":"2","ps":"'$user'","add":"'$DOMAIN'","port":"443","id":"'$uuid'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'$DOMAIN'","tls":"tls"}' > /tmp/vt.json
echo '{"v":"2","ps":"'$user'","add":"'$DOMAIN'","port":"443","id":"'$uuid'","aid":"0","net":"ws","path":"/vmess-upgrade","type":"none","host":"[ISP_BUG_HOST]","tls":"tls"}' > /tmp/vh.json
echo '{"v":"2","ps":"'$user'","add":"'$DOMAIN'","port":"80","id":"'$uuid'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'$DOMAIN'","tls":"none"}' > /tmp/vn.json
echo -e "${YELLOW}LINK TLS :${NC}\n${GREEN}vmess://$(base64 -w 0 /tmp/vt.json)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK HTTP-UPGRADE (CloudFront Bypass) :${NC}\n${GREEN}vmess://$(base64 -w 0 /tmp/vh.json)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK NO-TLS :${NC}\n${GREEN}vmess://$(base64 -w 0 /tmp/vn.json)${NC}"
rm -f /tmp/vt.json /tmp/vh.json /tmp/vn.json
_EOF_
else
cat << '_EOF_' >> /usr/local/sbin/trial-vless
echo -e "${YELLOW}LINK TLS :${NC}\n${GREEN}vless://${uuid}@${DOMAIN}:443?path=/vless&security=tls&encryption=none&type=ws#${user}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK HTTP-UPGRADE (CloudFront Bypass) :${NC}\n${GREEN}vless://${uuid}@${DOMAIN}:443?path=/vless-upgrade&security=tls&encryption=none&type=ws&sni=[ISP_BUG_HOST]#${user}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK NO-TLS :${NC}\n${GREEN}vless://${uuid}@${DOMAIN}:80?path=/vless&security=none&encryption=none&type=ws#${user}${NC}"
_EOF_
fi
echo -e 'echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"\necho -ne "${CYAN}Press any key to back on menu ${NC}"; read -n 1 -s -r' >> /usr/local/sbin/trial-${proto}
done

# ==========================================
# 2. TIMED ACCOUNT SCRIPTS
# ==========================================
for proto in vmess vless; do
cat << _EOF_ > /usr/local/sbin/timed-${proto}
#!/bin/bash
NC='\e[0m'; GREEN='\e[0;32m'; CYAN='\e[0;36m'; YELLOW='\e[0;33m'; BLUE='\e[0;34m'
clear
echo -ne "\${CYAN}Username : \${GREEN}"; read user
echo -ne "\${CYAN}Minutes  : \${GREEN}"; read mins
uuid=\$(cat /proc/sys/kernel/random/uuid)
exp_sys=\$(date -d "tomorrow" +"%Y-%m-%d")
exp_time=\$(date -u -d "+\$mins minutes" +"%H:%M UTC")

echo -e "\${user} \${uuid} \${exp_sys}" >> /etc/xray/${proto}-users.db

clear
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -e "       \${YELLOW}PREMIUM TIMED ${proto^^} ACCOUNT\${NC}"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "Remarks" "\$user"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "Domain" "$DOMAIN"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "User ID" "\$uuid"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "Valid For" "\$mins Minutes"
printf "\${CYAN}%-14s\${NC} : \${GREEN}%s\${NC}\n" "Expires At" "\$exp_time"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
_EOF_

if [ "$proto" == "vmess" ]; then
cat << '_EOF_' >> /usr/local/sbin/timed-vmess
echo '{"v":"2","ps":"'$user'","add":"'$DOMAIN'","port":"443","id":"'$uuid'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'$DOMAIN'","tls":"tls"}' > /tmp/vt.json
echo '{"v":"2","ps":"'$user'","add":"'$DOMAIN'","port":"443","id":"'$uuid'","aid":"0","net":"ws","path":"/vmess-upgrade","type":"none","host":"[ISP_BUG_HOST]","tls":"tls"}' > /tmp/vh.json
echo '{"v":"2","ps":"'$user'","add":"'$DOMAIN'","port":"80","id":"'$uuid'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'$DOMAIN'","tls":"none"}' > /tmp/vn.json
echo -e "${YELLOW}LINK TLS (Cloudflare/Standard) :${NC}\n${GREEN}vmess://$(base64 -w 0 /tmp/vt.json)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK HTTP-UPGRADE (CloudFront Bypass) :${NC}\n${GREEN}vmess://$(base64 -w 0 /tmp/vh.json)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK NO-TLS (Port 80) :${NC}\n${GREEN}vmess://$(base64 -w 0 /tmp/vn.json)${NC}"
rm -f /tmp/vt.json /tmp/vh.json /tmp/vn.json
_EOF_
else
cat << '_EOF_' >> /usr/local/sbin/timed-vless
echo -e "${YELLOW}LINK TLS (Cloudflare/Standard) :${NC}\n${GREEN}vless://${uuid}@${DOMAIN}:443?path=/vless&security=tls&encryption=none&type=ws#${user}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK HTTP-UPGRADE (CloudFront Bypass) :${NC}\n${GREEN}vless://${uuid}@${DOMAIN}:443?path=/vless-upgrade&security=tls&encryption=none&type=ws&sni=[ISP_BUG_HOST]#${user}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}LINK NO-TLS (Port 80) :${NC}\n${GREEN}vless://${uuid}@${DOMAIN}:80?path=/vless&security=none&encryption=none&type=ws#${user}${NC}"
_EOF_
fi
echo -e 'echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"' >> /usr/local/sbin/timed-${proto}
echo -e 'echo -e "⚠️  \${YELLOW}ACCOUNT WILL SELF-DESTRUCT IN \$mins MINUTES.\${NC}"' >> /usr/local/sbin/timed-${proto}
echo -e 'echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"\necho -ne "${CYAN}Press any key to back on menu ${NC}"; read -n 1 -s -r' >> /usr/local/sbin/timed-${proto}
done

# ==========================================
# 3. MEMBER LIST SCRIPTS
# ==========================================
for proto in vmess vless; do
cat << _EOF_ > /usr/local/sbin/member-${proto}
#!/bin/bash
NC='\e[0m'; GREEN='\e[0;32m'; CYAN='\e[0;36m'; YELLOW='\e[0;33m'; BLUE='\e[0;34m'; RED='\e[0;31m'
clear
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -e "          \${YELLOW}${proto^^} USER LIST\${NC}"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
printf "\${CYAN}%-15s %-15s %s\${NC}\n" "USERNAME" "EXP DATE" "STATUS"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
if [ -f /etc/xray/${proto}-users.db ]; then
    while read -r u uuid exp; do
        exp_sec=\$(date -d "\$exp" +%s 2>/dev/null || echo 0)
        now_sec=\$(date +%s)
        if [[ \$now_sec -ge \$exp_sec ]]; then
            status="\${RED}Expired\${NC}"
        else
            status="\${GREEN}Active\${NC}"
        fi
        printf "\${GREEN}%-15s %-15s %b\n" "\$u" "\$exp" "\$status"
    done < /etc/xray/${proto}-users.db
fi
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -ne "\${CYAN}Press any key to return...\${NC}"; read -n 1 -s -r
_EOF_
done

# ==========================================
# 4. USER ACTIVITY (CEK) SCRIPTS
# ==========================================
for proto in vmess vless; do
cat << _EOF_ > /usr/local/sbin/cek-${proto}
#!/bin/bash
NC='\e[0m'; GREEN='\e[0;32m'; CYAN='\e[0;36m'; YELLOW='\e[0;33m'; BLUE='\e[0;34m'
clear
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -e "        \${YELLOW}${proto^^} USER ACTIVITY\${NC}"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
printf "\${CYAN}%-12s %-17s %s\${NC}\n" "TIME" "IP ADDRESS" "USER"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"

# Safely extract last 10 connections from Xray log matching the protocol
grep "accepted" /var/log/xray/access.log | grep "email: " | tail -n 10 | while read -r line; do
    time=\$(echo "\$line" | awk '{print \$2}')
    ip=\$(echo "\$line" | awk '{print \$3}' | cut -d: -f1)
    user=\$(echo "\$line" | awk -F"email: " '{print \$2}')
    
    # Simple check to map user if it exists in DB
    if grep -q " \$user " /etc/xray/${proto}-users.db 2>/dev/null || [[ "\$line" == *"${proto}"* ]]; then
        printf "\${GREEN}%-12s %-17s %s\${NC}\n" "\$time" "\$ip" "\$user"
    fi
done

echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -e "\${CYAN}* Showing last 10 connections\${NC}"
echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -ne "\${CYAN}Press any key to back on menu \${NC}"; read -n 1 -s -r
_EOF_
done

# Make all generated scripts executable
chmod +x /usr/local/sbin/trial-vmess /usr/local/sbin/trial-vless /usr/local/sbin/timed-vmess /usr/local/sbin/timed-vless /usr/local/sbin/member-vmess /usr/local/sbin/member-vless /usr/local/sbin/cek-vmess /usr/local/sbin/cek-vless
