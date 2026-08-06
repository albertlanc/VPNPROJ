with open("/root/my-ssh-manager/ssh-manager", "r") as f:
    lines = f.readlines()

# Read backwards to find the absolute end of the menu engine
for i in range(len(lines)-1, -1, -1):
    if lines[i].strip() == "esac":
        # Inject options 8 and 9 right before the engine closes
        lines.insert(i, "        8|08) clear; menu-vmess ;;\n")
        lines.insert(i+1, "        9|09) clear; menu-vless ;;\n")
        break

with open("/root/my-ssh-manager/ssh-manager", "w") as f:
    f.writelines(lines)
