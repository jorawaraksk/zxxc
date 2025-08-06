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
cloudflared tunnel --url tcp://localhost:3389 2>&1 | tee /tmp/cloudflared.log &

# Wait for the tunnel to initialize
sleep 5

# Extract and display the RDP tunnel address
RDP_ADDR=$(grep -oE "tcp://[^ ]+" /tmp/cloudflared.log | head -n 1)

if [ -n "$RDP_ADDR" ]; then
    echo "[✓] 🔗 Your RDP address is: $RDP_ADDR"
    echo "[✓] Use it in your RDP client like this: ${RDP_ADDR#tcp://}"
else
    echo "[⚠️] Could not detect RDP address automatically. Check full logs for 'trycloudflare.com'."
fi

# Keep the container alive to maintain tunnel
wait
