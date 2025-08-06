#!/bin/bash

echo "[+] 🚀 run.sh executed at $(date)" >> /log.txt
env >> /log.txt

echo "[+] Starting dbus and xrdp services..."
service dbus start
service xrdp start

sleep 3
netstat -tulnp | grep 3389 >> /log.txt

cloudflared tunnel --url tcp://localhost:3389 >> /log.txt 2>&1
