import re
with open("/usr/local/sbin/menu", "r") as f:
    lines = f.readlines()

out = []
inserted = False
for line in lines:
    # Clear out any corrupted fragments of 8 or 9 if they exist
    if re.search(r'^\s*(8\|08|9\|09)\)', line):
        continue
        
    # Inject the correct routing right before option 14
    if "14|14)" in line and not inserted:
        out.append("        8|08) clear; menu-vmess ;;\n")
        out.append("        9|09) clear; menu-vless ;;\n")
        inserted = True
        
    out.append(line)

# Apply to the live system and the GitHub repo file
with open("/usr/local/sbin/menu", "w") as f:
    f.writelines(out)
    
with open("/root/my-ssh-manager/ssh-manager", "w") as f:
    f.writelines(out)
