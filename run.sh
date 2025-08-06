#!/bin/bash

echo "[+] Starting dbus and xrdp services..."
service dbus start
service xrdp start

echo "[+] Sleeping 3 seconds to ensure services are up..."
sleep 3

echo "[+] Launching Cloudflared Tunnel on RDP port 3389..."
cloudflared tunnel --url rdp://localhost:3389
