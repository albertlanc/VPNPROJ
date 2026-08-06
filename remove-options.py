import re

for filepath in ["/usr/local/sbin/menu", "/root/my-ssh-manager/ssh-manager"]:
    try:
        with open(filepath, "r") as f:
            content = f.read()

        # Safely strip out the case logic blocks for option 2 and 3
        content = re.sub(r'^\s*(2\|02|2)\s*\).*?;;', '', content, flags=re.MULTILINE | re.DOTALL)
        content = re.sub(r'^\s*(3\|03|3)\s*\).*?;;', '', content, flags=re.MULTILINE | re.DOTALL)
        
        # Also remove any text lines displaying them if present in print statements
        content = re.sub(r'.*UDP CUSTOM MENU.*\n', '', content, flags=re.IGNORECASE)
        content = re.sub(r'.*HYSTERIA MENU.*\n', '', content, flags=re.IGNORECASE)

        with open(filepath, "w") as f:
            f.write(content)
    except FileNotFoundError:
        pass

print("Options 2 and 3 successfully stripped from menu files.")
