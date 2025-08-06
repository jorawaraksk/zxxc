#!/bin/bash

# Start a dummy HTTP server on port 8080 to satisfy Render's port binding requirement
echo "[+] Starting dummy HTTP server on port 8080 to satisfy Render..."
nohup busybox httpd -f -p 8080 &

# Start dbus and xrdp services
echo "[+] Starting dbus and xrdp services..."
service dbus start
service xrdp start

# Give xrdp some time to fully start up
echo "[+] Waiting for xrdp to be ready..."
for i in {1..10}; do
    if netstat -tulnp | grep -q ":3389"; then
        echo "[✓] xrdp is listening on port 3389"
        break
    else
        echo "[-] Waiting... ($i)"
        sleep 1
    fi
done

# Launch Cloudflared TCP tunnel for RDP
echo "[+] Launching Cloudflared TCP tunnel on port 3389..."
cloudflared tunnel --url tcp://localhost:3389
