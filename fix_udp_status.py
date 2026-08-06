path = "/usr/local/sbin/menu"
with open(path, "r") as f:
    content = f.read()

new_block = """case $udp_choice in
        0|00) break ;;
        2|02) 
            clear
            echo -e "\\n[*] Starting UDP Custom..."
            systemctl start udp-custom
            sleep 2
            ;;
        3|03) 
            clear
            echo -e "\\n[*] Stopping UDP Custom..."
            systemctl stop udp-custom
            sleep 2
            ;;
        4|04) 
            clear
            echo -e "====================================="
            echo -e "      UDP CUSTOM SERVICE STATUS      "
            echo -e "====================================="
            if systemctl is-active --quiet udp-custom; then
                echo -e "Status: \\e[32m[ ONLINE / ACTIVE ]\\e[0m"
            else
                echo -e "Status: \\e[31m[ OFFLINE / INACTIVE ]\\e[0m"
            fi
            echo -e "====================================="
            echo -e "Recent Logs:"
            journalctl -u udp-custom -n 5 --no-pager
            echo -e "====================================="
            echo -ne "Press any key to return..."; read -n 1 -s -r
            ;;"""

start_marker = "case $udp_choice in"
end_marker = "1|01)"

if start_marker in content:
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker, start_idx)
    
    if end_idx != -1:
        # Reconstruct the file with the new block injected perfectly between the markers
        content = content[:start_idx] + new_block + "\n        " + content[end_idx:]
        with open(path, "w") as f:
            f.write(content)
        print("SUCCESS: UDP Custom menu options have been cleanly wired!")
    else:
        print("Error: Could not find the end marker.")
else:
    print("Error: Could not find the UDP choice block.")
