import re
path = "/usr/local/sbin/menu"
with open(path, "r") as f:
    content = f.read()

# Target the Option 6 mapping we just made and add Option 7 right below it
target = "6|06) clear; menu-shadowsocks ;;"
insertion = "6|06) clear; menu-shadowsocks ;;\n        7|07) clear; menu-ssr ;;"

if target in content and "menu-ssr ;;" not in content:
    content = content.replace(target, insertion, 1)

with open(path, "w") as f:
    f.write(content)
