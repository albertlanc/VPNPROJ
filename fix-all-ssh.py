import re

with open("/root/my-ssh-manager/ssh-manager", "r") as f:
    content = f.read()

# 1. Find the SSH Submenu section
ssh_idx = content.find("SSH & USER MANAGEMENT MENU")
if ssh_idx == -1:
    print("Error: Could not find SSH menu.")
    exit(1)

# 2. Find the broken routing block inside it
case_idx = content.find("case ", ssh_idx)
esac_idx = content.find("esac", case_idx)

if case_idx != -1 and esac_idx != -1:
    # Preserve whatever variable the menu uses (e.g., $opt, $x, $option)
    case_line = content[case_idx:content.find("\n", case_idx)]
    
    # 3. Inject the correct 1-13 routing for SSH tools
    correct_routing = f"""{case_line}
        1|01) clear; usernew 2>/dev/null || echo -e "\\n[!] Command 'usernew' missing."; read -n 1 -s -r ;;
        2|02) clear; trial ;;
        3|03) clear; usernew 2>/dev/null || add-ssh 2>/dev/null || echo -e "\\n[!] Command missing."; read -n 1 -s -r ;;
        4|04) clear; renew 2>/dev/null || echo -e "\\n[!] Command 'renew' missing."; read -n 1 -s -r ;;
        5|05) clear; hapus 2>/dev/null || deluser 2>/dev/null || echo -e "\\n[!] Command 'hapus' missing."; read -n 1 -s -r ;;
        6|06) clear; cek 2>/dev/null || echo -e "\\n[!] Command 'cek' missing."; read -n 1 -s -r ;;
        7|07) clear; member 2>/dev/null || echo -e "\\n[!] Command 'member' missing."; read -n 1 -s -r ;;
        8|08) clear; autokill 2>/dev/null || echo -e "\\n[!] Command 'autokill' missing."; read -n 1 -s -r ;;
        9|09) clear; autodel 2>/dev/null || tendang 2>/dev/null || echo -e "\\n[!] Command 'autodel' missing."; read -n 1 -s -r ;;
        10) clear; backup 2>/dev/null || echo -e "\\n[!] Command 'backup' missing."; read -n 1 -s -r ;;
        11) clear; restore 2>/dev/null || echo -e "\\n[!] Command 'restore' missing."; read -n 1 -s -r ;;
        12) clear; menu-ovpn 2>/dev/null || ovpn 2>/dev/null || echo -e "\\n[!] Command 'ovpn' missing."; read -n 1 -s -r ;;
        13) clear; limit 2>/dev/null || limit-ssh 2>/dev/null || echo -e "\\n[!] Command 'limit' missing."; read -n 1 -s -r ;;
        0|00) clear; menu ;;
        *) clear; echo -e "\\n[!] Invalid option."; sleep 1; menu ;;
    esac"""

    new_content = content[:case_idx] + correct_routing + content[esac_idx+4:]

    with open("/root/my-ssh-manager/ssh-manager", "w") as f:
        f.write(new_content)
    print("SUCCESS: All 13 SSH Submenu routes fixed!")
else:
    print("Error: Could not parse case block.")
