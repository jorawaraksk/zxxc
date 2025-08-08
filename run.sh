#!/bin/bash

HTTP_FILE="/var/www/html/index.html"
mkdir -p /var/www/html

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
/usr/local/bin/cloudflared tunnel --url tcp://localhost:3389 --logfile /tmp/cloudflared.log &

sleep 12

# Extract the RDP address from cloudflared log
RDP_ADDRESS=$(grep -oP "trycloudflare\.com:[0-9]+" /tmp/cloudflared.log | tail -n 1)

if [ -n "$RDP_ADDRESS" ]; then
    echo "============================================"
    echo "[✓] 🔗 Your RDP Address is: $RDP_ADDRESS"
    echo "[✓] ✅ Use this in your RDP client exactly as shown"
    echo "============================================"

    # Write to Render site HTML
    echo "<html><body><h1>✅ Your RDP Address:</h1><p style='font-size:20px;'>$RDP_ADDRESS</p></body></html>" > "$HTTP_FILE"
else
    echo "[⚠️] Could not find RDP address in logs."
    echo "<html><body><h1>⚠️ RDP address not ready yet. Refresh in a minute.</h1></body></html>" > "$HTTP_FILE"
fi

# Start minimal HTTP server to keep Render alive
busybox httpd -f -p 8080 -h /var/www/html &
tail -f /dev/null
