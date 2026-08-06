with open("/root/my-ssh-manager/ssh-manager", "r") as f:
    lines = f.readlines()

out = []
skip = False
in_ssh = False

for line in lines:
    clean_line = line.strip()
    
    if "SSH & USER MANAGEMENT" in clean_line or "Create SSH" in clean_line:
        in_ssh = True
    if clean_line == "esac":
        in_ssh = False
        
    if in_ssh and clean_line.startswith("2|02)"):
        # Insert the correct, safe Trial command that pauses on errors
        out.append("        2|02) clear; trial || trial-ssh || usernew || { echo -e '\\n[!] Error: Trial script missing from server.'; read -n 1 -s -r; };;\n")
        skip = True
    elif skip:
        # Keep deleting dangling lines until we hit option 3 or the end of the menu
        if clean_line.startswith("3|03)") or clean_line == "esac":
            skip = False
            out.append(line)
    else:
        out.append(line)

with open("/root/my-ssh-manager/ssh-manager", "w") as f:
    f.writelines(out)
