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
cloudflared tunnel --url rdp://localhost:3389 --no-autoupdate &
sleep 5

echo "[+] Setup complete. Check Render logs for your RDP hostname."
tail -f /var/log/xrdp-sesman.log /var/log/xrdp.log
