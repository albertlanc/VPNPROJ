path = "/usr/local/sbin/menu"
with open(path, "r") as f:
    content = f.read()

# 1. Wire the Hysteria Submenu (0, 2, 3, 4) cleanly without exposing logs
new_block = """case $hyst_choice in
        0|00) break ;;
        2|02) 
            clear
            echo -e "\\n[*] Starting Hysteria..."
            systemctl start hysteria
            sleep 2
            ;;
        3|03) 
            clear
            echo -e "\\n[*] Stopping Hysteria..."
            systemctl stop hysteria
            sleep 2
            ;;
        4|04) 
            clear
            echo -e "====================================="
            echo -e "        HYSTERIA SERVICE STATUS      "
            echo -e "====================================="
            if systemctl is-active --quiet hysteria; then
                echo -e "Status: \\e[32m[ ONLINE / ACTIVE ]\\e[0m"
            else
                echo -e "Status: \\e[31m[ OFFLINE / INACTIVE ]\\e[0m"
            fi
            echo -e "====================================="
            echo -ne "Press any key to return..."; read -n 1 -s -r
            ;;"""

start_marker = "case $hyst_choice in"
end_marker = "1|01)"

if start_marker in content:
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker, start_idx)
    if end_idx != -1:
        content = content[:start_idx] + new_block + "\n        " + content[end_idx:]

# 2. Change Port 5300 to 7122 to avoid conflict with UDP Custom / SlowDNS
content = content.replace("Port 5300", "Port 7122")
content = content.replace('"listen": ":5300"', '"listen": ":7122"')

# 3. Ensure Option 3 is solidly mapped in the main menu's active loop
target = "2|02) clear; udp_custom_submenu ;;"
if target in content and "3|03) clear; hysteria_submenu" not in content:
    content = content.replace(target, target + "\n        3|03) clear; hysteria_submenu ;;")

with open(path, "w") as f:
    f.write(content)
print("SUCCESS: Hysteria menu fixed and port re-routed to 7122!")
