#!/bin/bash

for script in /usr/local/sbin/add-vmess /usr/local/sbin/add-vless /usr/local/sbin/trial-vmess /usr/local/sbin/trial-vless /usr/local/sbin/timed-vmess /usr/local/sbin/timed-vless; do
    if [ -f "$script" ]; then
        # Use python to cleanly remove the top banner lines containing telegram or reboot status
        python3 -c '
with open("'"$script"'", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "THETECHSAVAGETELEGRAM" in line or "Time Reboot VPS" in line or "Use Core" in line or "IP-VPS" in line:
        continue
    # Skip separator lines that were part of the removed header block
    new_lines.append(line)

with open("'"$script"'", "w") as f:
    f.writelines(new_lines)
'
    fi
done

echo "All Telegram branding and extra headers successfully removed!"
