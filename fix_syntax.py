path = "/usr/local/sbin/menu"
with open(path, "r") as f:
    lines = f.readlines()

for i in range(len(lines)):
    if "=== RESTARTING ALL SERVICES ===" in lines[i]:
        # Inject 6|06) right above the 'clear' command
        lines.insert(i-1, "            6|06)\n")
        break

with open(path, "w") as f:
    f.writelines(lines)
