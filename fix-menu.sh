cd /root/my-ssh-manager
git reset --hard 7090ba3

# Safely replace the entire option 2 block, removing the dangling code
awk '
BEGIN { replaced = 0 }
/^[ \t]*2\|02\)/ && replaced == 0 {
    print "        2|02) clear; trial 2>/dev/null || trial-ssh 2>/dev/null || usernew 2>/dev/null ;;"
    skip = 1
    replaced = 1
    next
}
skip == 1 {
    if (/;;/) skip = 0
    next
}
{ print }' ssh-manager > temp_file

mv temp_file ssh-manager
chmod +x ssh-manager

# Update the system binary so 'menu' works immediately
cp ssh-manager /usr/local/sbin/menu

# Verify and push to GitHub
bash -n /usr/local/sbin/menu
git add ssh-manager
git commit -m "Safely removed orphaned ports block and fixed option 2"
git push origin main --force
