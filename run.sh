#!/bin/bash

# Start XRDP
echo "🟢 Starting xrdp..."
service xrdp start

# Inject authtoken (make sure it's passed via env or hardcoded)
if [ -z "30sejMsqEO8qhzhravw1Pvwxyag_68ievbzFj1gbPzW5MWjxf" ]; then
  echo "❌ NGROK_AUTHTOKEN not set. Set it as env variable or hardcode it below."
  exit 1
fi

echo "🔐 Adding ngrok authtoken..."
ngrok config add-authtoken 30sejMsqEO8qhzhravw1Pvwxyag_68ievbzFj1gbPzW5MWjxf

# Start ngrok TCP tunnel on port 3389
echo "🚀 Starting ngrok tunnel..."
ngrok tcp 3389 > /dev/null &

sleep 5

# Fetch and display the public URL
echo "🔗 Your public RDP address (via ngrok):"
curl -s http://localhost:4040/api/tunnels | grep -oE 'tcp://[^\"]+' || echo "⏳ Ngrok not ready yet"

# Keep container running
tail -f /dev/null
