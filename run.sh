#!/bin/bash
set -e

echo "[+] Starting XRDP service..."
service xrdp start

# Wait until XRDP is listening on 3389
echo "[+] Waiting for XRDP to be ready..."
for i in {1..20}; do
    if nc -z 127.0.0.1 3389; then
        echo "[+] XRDP is running."
        break
    fi
    sleep 2
done

# Start Cloudflared tunnel for RDP
echo "[+] Starting Cloudflared tunnel..."
cloudflared tunnel --url tcp://localhost:3389 --no-autoupdate
