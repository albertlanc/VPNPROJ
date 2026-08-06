import re
path = "/usr/local/sbin/menu"
with open(path, "r") as f:
    content = f.read()

# Remove any old broken Option 6 mappings if they exist
content = re.sub(r"^\s*6\|06\).*?$\n", "", content, flags=re.MULTILINE)

target = "case $choix in"
insertion = "case $choix in\n        6|06) clear; menu-shadowsocks ;;"

if target in content and "menu-shadowsocks" not in content:
    content = content.replace(target, insertion, 1)

with open(path, "w") as f:
    f.write(content)
