#!/bin/bash

# Remove the line from add-vmess and add-vless
for script in /usr/local/sbin/add-vmess /usr/local/sbin/add-vless /usr/local/sbin/trial-vmess /usr/local/sbin/trial-vless /usr/local/sbin/timed-vmess /usr/local/sbin/timed-vless; do
    if [ -f "$script" ]; then
        sed -i '/THANKS FOR USING/d' "$script"
    fi
done

echo "Banner line successfully removed!"
