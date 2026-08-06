import re, subprocess, sys

path = "/root/my-ssh-manager/ssh-manager"
subprocess.run(["git", "reset", "--hard", "7090ba3"], cwd="/root/my-ssh-manager", check=True)

with open(path, "r") as f:
    lines = f.readlines()

out = []
in_ssh_menu = False
in_case = False
skip = False

for line in lines:
    if "SSH & USER MANAGEMENT MENU" in line or "Create SSH" in line:
        in_ssh_menu = True
    
    if in_ssh_menu and re.search(r'^\s*case\s+.*in', line):
        in_case = True
        
    if in_case and not skip and re.search(r'^\s*2\|02\)', line):
        out.append("        2|02) clear; trial 2>/dev/null || trial-ssh 2>/dev/null || usernew 2>/dev/null ;;\n")
        skip = True
        # If the line somehow already has the closing semicolons, stop skipping
        if ";;" in line.split(")")[-1]:
            skip = False
        continue
        
    if skip:
        if ";;" in line:
            skip = False
        # Stop skipping if we hit the next menu option or the end of the case block
        elif re.search(r'^\s*([3-9]|0[3-9]|[1-9][0-9]|\*)\)', line) or re.search(r'^\s*esac', line):
            skip = False
            out.append(line)
            if "esac" in line:
                in_ssh_menu = False
                in_case = False
        continue
        
    out.append(line)

with open(path, "w") as f:
    f.writelines(out)
