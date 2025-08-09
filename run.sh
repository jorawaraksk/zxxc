#!/bin/bash
set -e

echo "[+] Starting XRDP service..."
service xrdp start

echo "[+] Waiting for XRDP to be ready..."
while ! nc -z localhost 3389; do
    sleep 1
done

echo "[+] Starting Cloudflared tunnel..."
cloudflared tunnel --url tcp://localhost:3389 --no-autoupdate &

echo "[+] Starting minimal HTTP server for Render health check..."
python3 -m http.server 8080 --directory /tmp &

echo "[+] All services started. Press Ctrl+C to stop."
wait -n
