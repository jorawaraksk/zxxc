#!/bin/bash

echo "[+] Starting dummy HTTP server on port 8080 to satisfy Render..."
nohup busybox httpd -f -p 8080 &

echo "[+] Starting dbus and xrdp services..."
service dbus start
service xrdp start

echo "[+] Waiting for xrdp to listen on port 3389..."
for i in {1..10}; do
    if netstat -tulnp | grep -q ":3389"; then
        echo "[✓] xrdp is listening on port 3389"
        break
    else
        echo "[-] Waiting... ($i)"
        sleep 1
    fi
done

echo "[+] Launching Cloudflared tunnel (TCP mode)..."
cloudflared tunnel --url tcp://localhost:3389 --loglevel info 2>&1 | tee /tmp/cloudflared.log &

# Wait for the tunnel to initialize
sleep 2

# Try to extract any trycloudflare.com address (even https one)
for i in {1..20}; do
    RDP_DOMAIN=$(grep -oE "https://[a-z0-9-]+\.trycloudflare\.com" /tmp/cloudflared.log | head -n 1)
    if [ -n "$RDP_DOMAIN" ]; then
        echo "[✓] 🌐 Tunnel created: $RDP_DOMAIN"
        echo "[🔧] Use it in your RDP client like this (add port manually after testing):"
        echo "     trycloudflare.com:<PORT_FROM_LOG>"
        break
    else
        echo "[-] Waiting for tunnel... ($i)"
        sleep 1
    fi
done

if [ -z "$RDP_DOMAIN" ]; then
    echo "[⚠️] Still no tunnel address detected. Please check full logs."
fi

wait
