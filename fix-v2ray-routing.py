import re
with open("/root/my-ssh-manager/ssh-manager", "r") as f:
    lines = f.readlines()

out = []
in_ssh = False
skip = False

for line in lines:
    # Track if we are inside the SSH submenu so we don't overwrite its 8 and 9
    if "SSH & USER MANAGEMENT MENU" in line or "Create SSH" in line:
        in_ssh = True
    elif in_ssh and re.search(r'^\s*esac', line):
        in_ssh = False
        
    if not in_ssh:
        # Check if the line is a menu option like "8|08)"
        is_new_option = re.search(r'^\s*([a-zA-Z0-9_]+\|[a-zA-Z0-9_]+|[0-9]+|\*)\)', line)
        
        if is_new_option:
            skip = False
            
            if re.search(r'^\s*(8\|08|8|08)\)', line):
                out.append('        8|08) clear; menu-vmess 2>/dev/null || m-vmess 2>/dev/null || { echo -e "\\n[!] Error: Vmess menu script missing from server."; read -n 1 -s -r; } ;;\n')
                if ";;" not in line: skip = True
                continue
                
            if re.search(r'^\s*(9\|09|9|09)\)', line):
                out.append('        9|09) clear; menu-vless 2>/dev/null || m-vless 2>/dev/null || { echo -e "\\n[!] Error: Vless menu script missing from server."; read -n 1 -s -r; } ;;\n')
                if ";;" not in line: skip = True
                continue
                
    if skip:
        if ";;" in line: skip = False
        continue
        
    out.append(line)

with open("/root/my-ssh-manager/ssh-manager", "w") as f:
    f.writelines(out)
