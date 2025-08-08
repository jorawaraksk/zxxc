#!/bin/bash
set -e

echo "[+] Starting virtual display..."
Xvfb :0 -screen 0 1024x768x24 &
export DISPLAY=:0

echo "[+] Starting XFCE4 desktop..."
startxfce4 &

echo "[+] Starting XRDP server..."
service xrdp start

echo "[+] Starting Cloudflared tunnel..."
cloudflared tunnel --url rdp://localhost:3389 --no-autoupdate > /tmp/cloudflared.log 2>&1 &

# Wait for cloudflared to give us an address
echo "[*] Waiting for Cloudflared RDP address..."
for i in {1..60}; do
    ADDR=$(grep -oE "https://[a-zA-Z0-9.-]+trycloudflare.com" /tmp/cloudflared.log | head -n 1)
    if [[ -n "$ADDR" ]]; then
        echo ""
        echo "============================================="
        echo "[✅] RDP Tunnel is ready!"
        echo "    Host: ${ADDR/https:\/\//}"
        echo "    Port: 3389"
        echo "Use any RDP client to connect."
        echo "============================================="
        break
    fi
    sleep 2
done

if [[ -z "$ADDR" ]]; then
    echo "[❌] Failed to get RDP address from Cloudflared."
fi

# Keep logs visible
tail -f /var/log/xrdp-sesman.log /var/log/xrdp.log /tmp/cloudflared.log
