import json, os

path = "/usr/local/etc/xray/config.json"
with open(path, "r") as f:
    data = json.load(f)

# Grab your working TLS certificates from existing configs
cert_path, key_path = "/etc/xray/xray.crt", "/etc/xray/xray.key"
for ib in data.get("inbounds", []):
    try:
        c = ib["streamSettings"]["tlsSettings"]["certificates"][0]
        cert_path, key_path = c.get("certificateFile", cert_path), c.get("keyFile", key_path)
        break
    except KeyError: pass

inbounds = data.get("inbounds", [])

# Inject Port 2443 (TLS)
if not any(ib.get("port") == 2443 for ib in inbounds):
    inbounds.append({
        "port": 2443, "protocol": "shadowsocks",
        "settings": {"clients": [], "network": "tcp,udp"},
        "streamSettings": {
            "network": "tcp", "security": "tls", 
            "tlsSettings": {"certificates": [{"certificateFile": cert_path, "keyFile": key_path}]}
        },
        "tag": "ss-tls"
    })

# Inject Port 3443 (No TLS)
if not any(ib.get("port") == 3443 for ib in inbounds):
    inbounds.append({
        "port": 3443, "protocol": "shadowsocks",
        "settings": {"clients": [], "network": "tcp,udp"},
        "streamSettings": {"network": "tcp", "security": "none"},
        "tag": "ss-notls"
    })

data["inbounds"] = inbounds
with open(path, "w") as f: 
    json.dump(data, f, indent=2)

print("[+] Xray core injected with modern Shadowsocks on Ports 2443 & 3443!")
