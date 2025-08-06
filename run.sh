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
cloudflared tunnel --url tcp://localhost:3389 --logfile /tmp/cloudflared.log &

# Wait for tunnel to initialize
sleep 10

# Try to extract the port from Cloudflared logs
PORT=$(grep -oE "trycloudflare\.com:[0-9]+" /tmp/cloudflared.log | tail -n 1)

if [[ -n "$PORT" ]]; then
    echo "[✓] 🔗 Your RDP address is: $PORT"
    echo "[✓] Use it in your RDP client like this: $PORT"
else
    echo "[⚠️] Could not detect RDP address automatically. Check full logs for 'trycloudflare.com'."
fi

# Keep container alive
tail -f /dev/null
