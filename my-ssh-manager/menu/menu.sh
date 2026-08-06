#!/bin/bash
# menu/menu.sh

# Define Color Codes
G='\033[1;32m'
R='\033[1;31m'
NC='\033[0m'

# Fetch System Info
IP=$(curl -s ifconfig.me)
OS_NAME=$(grep -w "PRETTY_NAME" /etc/os-release | cut -d "=" -f 2 | tr -d '"')

clear
echo -e "${G}==================================================${NC}"
echo -e "${G}              LIGHTWEIGHT VPN MANAGER             ${NC}"
echo -e "${G}==================================================${NC}"
echo -e "${G} Server IP : ${IP}${NC}"
echo -e "${G} OS        : ${OS_NAME}${NC}"
echo -e "${G}==================================================${NC}"
echo -e "${G}  [1] Add SSH / SlowDNS User${NC}"
echo -e "${G}  [2] Add Xray User (VMess / VLESS)${NC}"
echo -e "${G}  [3] Delete VPN User${NC}"
echo -e "${G}  [4] Renew VPN User${NC}"
echo -e "${G}  [5] Restart All Services${NC}"
echo -e "${G}  [6] Check Service Status${NC}"
echo -e "${G}  [0] Exit Menu${NC}"
echo -e "${G}==================================================${NC}"
echo -n -e "${G} Select an option [0-6]: ${NC}"
read -r option

case $option in
    1)
        add-ssh
        ;;
    2)
        add-xray
        ;;
    3)
        delete-user
        ;;
    4)
        renew-user
        ;;
    5)
        echo -e "\n${G}Restarting All Services...${NC}"
        systemctl restart xray 2>/dev/null
        systemctl restart slowdns 2>/dev/null
        systemctl restart nginx 2>/dev/null
        systemctl restart ssh-ws 2>/dev/null || systemctl restart ws-ssh 2>/dev/null
        echo "Done!"
        sleep 1
        menu
        ;;
    6)
        clear
        echo -e "${G}==================================================${NC}"
        echo -e "${G}                SERVICE STATUS                    ${NC}"
        echo -e "${G}==================================================${NC}"
        
        if systemctl is-active --quiet xray; then
            echo -e " Xray Service    : ${G}Active [ON]${NC}"
        else
            echo -e " Xray Service    : ${R}Inactive [OFF]${NC}"
        fi

        if systemctl is-active --quiet slowdns; then
            echo -e " SlowDNS Service : ${G}Active [ON]${NC}"
        else
            echo -e " SlowDNS Service : ${R}Inactive [OFF]${NC}"
        fi

        if systemctl is-active --quiet nginx; then
            echo -e " Nginx Service   : ${G}Active [ON]${NC}"
        else
            echo -e " Nginx Service   : ${R}Inactive [OFF]${NC}"
        fi

        if systemctl is-active --quiet ssh-ws || systemctl is-active --quiet ws-ssh; then
            echo -e " SSH-WS Service  : ${G}Active [ON]${NC}"
        else
            echo -e " SSH-WS Service  : ${R}Inactive [OFF]${NC}"
        fi

        echo -e "${G}==================================================${NC}"
        read -n 1 -s -r -p "Press any key to return to menu..."
        menu
        ;;
    0)
        clear
        exit 0
        ;;
    *)
        echo -e "\nInvalid option. Please try again."
        sleep 2
        menu
        ;;
esac

