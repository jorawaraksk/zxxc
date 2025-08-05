#!/bin/bash

# Start XRDP
echo "🟢 Starting xrdp..."
service xrdp start

# Hardcoded token — no need to check if it's empty
echo "🔐 Adding ngrok authtoken..."
ngrok config add-authtoken 30sejMsqEO8qhzhravw1Pvwxyag_68ievbzFj1gbPzW5MWjxf

# Start ngrok TCP tunnel on port 3389
echo "🚀 Starting ngrok tunnel..."
ngrok tcp 3389 > /dev/null &

# Wait for ngrok to boot
sleep 5

# Show public RDP link
echo "🔗 Your public RDP address (via ngrok):"
curl -s http://localhost:4040/api/tunnels | grep -oE 'tcp://[^\"]+' || echo "⏳ Ngrok not ready yet"

# Keep container running
tail -f /dev/null
