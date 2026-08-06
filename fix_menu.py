import subprocess
import re

path = "/usr/local/sbin/menu"
repo_file = "/root/my-ssh-manager/ssh-manager"

# Reset file from git
subprocess.run(["git", "checkout", "--", "ssh-manager"], cwd="/root/my-ssh-manager")
subprocess.run(["cp", repo_file, path])

with open(path, "r") as f:
    content = f.read()

option_11_block = "        11|11)\n            clear\n            trojan-go-menu\n            ;;"

inserted = False
for target in ["12|12)", "13|13)", "15|015|15)", "15)"]:
    if target in content:
        content = content.replace(target, option_11_block + "\n" + "        " + target, 1)
        inserted = True
        break

if not inserted:
    content = content.replace("*)", option_11_block + "\n" + "        *)", 1)

with open(path, "w") as f:
    f.write(content)

# Test syntax safely using standard pipes (compatible with all Python versions)
res = subprocess.run(["bash", "-n", path], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
if res.returncode != 0:
    print("SYNTAX ERROR DETECTED:")
    print(res.stderr)
    subprocess.run(["cp", repo_file, path])
else:
    print("SUCCESS: Option 11 wired cleanly and verified syntax-free!")
