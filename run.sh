#!/bin/bash

echo "[+] Starting dbus and xrdp services..."
service dbus start
service xrdp start

echo "[+] Sleeping 3 seconds to ensure services are up..."
sleep 3

echo "[+] Checking if xrdp is listening on port 3389..."
netstat -tulnp | grep 3389 || echo "⚠️  xrdp might not be ready!"

echo "[+] Starting Cloudflared tunnel (TCP mode)..."
cloudflared tunnel --url tcp://localhost:3389
