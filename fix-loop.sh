cd /root/my-ssh-manager

# Scan the server for the correct Trial command
CMD="trial"
for c in trial menu-trial ssh-trial trial-ssh; do
    if command -v "$c" >/dev/null 2>&1; then
        CMD="$c"
        break
    fi
done

# Build a safe line that pauses on errors instead of silently looping
NEW_LINE="        2|02) clear; $CMD || { echo -e '\n[!] ERROR: The trial command failed or is missing from this VPS.'; read -n 1 -s -r -p 'Press any key to return...'; } ;;"

# Safely replace option 2 without risking syntax errors
awk -v repl="$NEW_LINE" '
BEGIN { replaced = 0 }
$1 == "2|02)" && replaced == 0 {
    print repl
    replaced = 1
    next
}
{ print $0 }
' ssh-manager > tmp_menu

# Apply to system and push to GitHub
mv tmp_menu ssh-manager
chmod +x ssh-manager
cp ssh-manager /usr/local/sbin/menu

git add ssh-manager
git commit -m "Fix silent loop on option 2"
git push origin main --force
