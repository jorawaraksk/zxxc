#!/bin/bash

# Start XRDP service
service xrdp start

# Authenticate ngrok
ngrok config add-authtoken 30sejMsqEO8qhzhravw1Pvwxyag_68ievbzFj1gbPzW5MWjxf

# Start ngrok tunnel for RDP
ngrok tcp 3389 > /dev/null &

# Wait a moment, then fetch the public ngrok address
sleep 5
echo "🔗 Your public RDP address (via ngrok):"
curl -s http://localhost:4040/api/tunnels | grep -Po '"public_url":"\K.*?(?=")' || echo "⏳ Ngrok not ready yet"

# Keep container alive
tail -f /dev/null
