path = "/usr/local/sbin/menu"
with open(path, "r") as f:
    content = f.read()

if "case $choix in" in content:
    parts = content.split("case $choix in")
    pre = parts[0]
    post = parts[1]
    
    # 1. Shift the old System Ports block out of the way to option 999
    post = post.replace("2|02)", "999|0999)", 1)
    
    # 2. Wire option 2 to the actual UDP custom submenu
    target_anchor = "1|01) ssh_submenu ;;"
    insertion = "1|01) ssh_submenu ;;\n        2|02) clear; udp_custom_submenu ;;"
    
    if target_anchor in post:
        post = post.replace(target_anchor, insertion, 1)
        
    content = pre + "case $choix in" + post
    
    with open(path, "w") as f:
        f.write(content)
    print("SUCCESS: Option 2 is now wired to the UDP Custom Menu!")
else:
    print("Error: Could not find main menu block.")
