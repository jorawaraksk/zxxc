#!/bin/bash
set -e

HTTP_FILE="/tmp/index.html"

# Start xvfb & desktop
echo "[+] Starting GUI environment..."
export DISPLAY=:0
Xvfb :0 -screen 0 1024x768x16 &
sleep 2
xfce4-session &

# Start xrdp
echo "[+] Starting RDP server..."
service xrdp start

# Start Cloudflared tunnel to RDP port
echo "[+] Starting Cloudflared tunnel..."
cloudflared tunnel --url tcp://localhost:3389 --protocol quic > /tmp/cloudflared.log 2>&1 &
CLOUDFLARED_PID=$!

# Create a temporary "loading" page
cat <<EOF > "$HTTP_FILE"
<html>
<head>
<meta http-equiv="refresh" content="5">
<title>RDP Status</title>
</head>
<body>
<h1>⏳ RDP address not ready yet...</h1>
<p>Refreshing every 5 seconds...</p>
<pre>$(date)</pre>
</body>
</html>
EOF

# Wait until Cloudflared outputs RDP address
echo "[+] Waiting for RDP address from Cloudflared..."
for i in {1..60}; do
    RDP_ADDRESS=$(grep -oP "trycloudflare\.com:[0-9]+" /tmp/cloudflared.log | tail -n 1)
    if [ -n "$RDP_ADDRESS" ]; then
        break
    fi
    echo "[-] Not ready yet... ($i)"
    sleep 2
done

# If found, update the HTML with the working address
if [ -n "$RDP_ADDRESS" ]; then
    echo "============================================"
    echo "[✓] 🔗 Your RDP Address is: $RDP_ADDRESS"
    echo "============================================"
    cat <<EOF > "$HTTP_FILE"
<html>
<head>
<title>✅ RDP Ready</title>
</head>
<body>
<h1>✅ Your RDP Address:</h1>
<p style='font-size:22px;'>$RDP_ADDRESS</p>
<p>Copy & paste into your RDP client.</p>
</body>
</html>
EOF
else
    echo "[⚠️] RDP address could not be found after waiting."
    cat <<EOF > "$HTTP_FILE"
<html>
<head>
<meta http-equiv="refresh" content="10">
<title>⚠️ RDP Not Ready</title>
</head>
<body>
<h1>⚠️ RDP address not ready.</h1>
<p>Cloudflared might have failed. Check logs on Render.</p>
<pre>$(date)</pre>
</body>
</html>
EOF
fi

# Serve the status page forever
echo "[+] Starting web server on port 10000..."
cd /tmp
python3 -m http.server 10000
