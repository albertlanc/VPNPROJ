import re

path = "/usr/local/sbin/menu"
with open(path, "r") as f:
    content = f.read()

# Clean up any previous top-level injections to prevent duplicates
content = re.sub(r"\s*11\|011\).*trojan-go-menu.*;;\n", "", content)
content = re.sub(r"\s*12\|012\).*speedtest.*;;\n", "", content)

# Target the actual active main menu block
target = "case $choix in"
insertion = """case $choix in
        11|011) clear; trojan-go-menu ;;
        12|012) clear; echo -e "\\n=== SPEEDTEST ==="; speedtest; echo -ne "\\nPress any key to return..."; read -n 1 -s -r ;;"""

if target in content:
    content = content.replace(target, insertion)

with open(path, "w") as f:
    f.write(content)

print("SUCCESS: Options 11 & 12 wired directly into the Main Menu ($choix) loop!")
