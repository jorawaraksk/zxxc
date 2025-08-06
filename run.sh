#!/bin/bash

echo "[+] Starting dummy HTTP server on port 8080 to satisfy Render..."
busybox httpd -f -p 8080 &

echo "[+] Starting dbus and xrdp services..."
service dbus start
service xrdp start

echo "[+] Waiting for xrdp to listen on port 3389..."
for i in {1..15}; do
    if netstat -tulnp | grep ":3389"; then
        echo "[✓] xrdp is listening on port 3389"
        break
    fi
    echo "[-] Waiting... ($i)"
    sleep 1
done

echo "[+] Launching Cloudflared tunnel (TCP mode)..."
/usr/local/bin/cloudflared tunnel --url tcp://localhost:3389 --logfile /tmp/cloudflared.log &

sleep 10

# Try to extract the TCP RDP address
RDP_ADDRESS=$(grep -oP "trycloudflare\.com:[0-9]+" /tmp/cloudflared.log | tail -n 1)

if [ -n "$RDP_ADDRESS" ]; then
    echo "[✓] 🔗 RDP Address: $RDP_ADDRESS"
    echo "[✓] ✅ Use this in RDP client → $RDP_ADDRESS"
else
    echo "[⚠️] RDP address not found. Cloudflare may still be initializing. Try again shortly."
fi

# Keep container alive
tail -f /dev/null
