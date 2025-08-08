#!/bin/bash
set -e

echo "[+] Starting virtual display..."
Xvfb :0 -screen 0 1280x800x24 &

# Wait for Xvfb to start
sleep 2

echo "[+] Starting XFCE4 desktop..."
startxfce4 &

echo "[+] Starting XRDP server..."
/usr/sbin/xrdp-sesman &
/usr/sbin/xrdp -nodaemon &

# Wait until RDP is actually listening
echo "[+] Waiting for RDP to be ready..."
for i in {1..60}; do
    if nc -z 127.0.0.1 3389; then
        echo "[✓] RDP is live on port 3389"
        break
    fi
    echo "[-] Not ready yet... ($i)"
    sleep 2
done

echo "[+] Starting Cloudflared tunnel..."
cloudflared tunnel --url tcp://localhost:3389 --no-autoupdate &
wait
