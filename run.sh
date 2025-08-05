#!/bin/bash

echo "🟢 Starting XRDP service..."
service xrdp start

sleep 2

echo "🚀 Launching ngrok tunnel on port 3389..."
ngrok tcp 3389 &

# Wait for ngrok to initialize
sleep 6

# Show ngrok tunnel URL
echo "🔗 Your public RDP address (via ngrok):"
curl -s http://localhost:4040/api/tunnels | grep -oE "tcp://[0-9a-zA-Z:.]+"

# Keep container alive
tail -f /dev/null
