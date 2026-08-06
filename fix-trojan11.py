import re

# 1. Update trojan-go-menu with standard, crash-proof prompt handling
trojan_menu_content = """#!/bin/bash
while true; do
    clear
    echo "                      TROJAN GO                       "
    echo "------------------------------------------------------"
    echo "1. Create Account Trojan Go"
    echo "2. Delete Account Trojan Go"
    echo "3. Extending Account Trojan Go Active Life"
    echo "4. Check User Login Trojan Go"
    echo "5. Menu"
    echo "6. Exit"
    echo "------------------------------------------------------"
    echo -n "Select From Options [ 1 - 6 ] : "
    read opt
    case $opt in
        1) clear; add-trojan-go ;;
        2) clear; del-trojan-go ;;
        3) clear; renew-trojan-go ;;
        4) clear; cek-trojan-go ;;
        5) break ;;
        6) exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done
"""

with open("/usr/local/sbin/trojan-go-menu", "w") as f:
    f.write(trojan_menu_content)

# 2. Update the main menu file to ensure option 11 matches properly
menu_path = "/usr/local/sbin/menu"
with open(menu_path, "r") as f:
    menu_lines = f.readlines()

new_menu_lines = []
found_11 = False
for line in menu_lines:
    # Look for the line handling option 11 in the case statement
    if re.search(r"^\s*11\s*\|", line) or (("11" in line) and ("trojan" in line.lower() or "trojan-go" in line)):
        new_menu_lines.append("        11|11) clear; /usr/local/sbin/trojan-go-menu ;;\n")
        found_11 = True
    else:
        new_menu_lines.append(line)

# If option 11 was not found in the case block via loose matching, insert it right before exit/default
if not found_11:
    updated_lines = []
    for line in new_menu_lines:
        if "*)" in line or "exit 0" in line:
            updated_lines.append("        11|11) clear; /usr/local/sbin/trojan-go-menu ;;\n")
        updated_lines.append(line)
    new_menu_lines = updated_lines

with open(menu_path, "w") as f:
    f.writelines(new_menu_lines)

print("Trojan Go menu routing successfully patched!")
