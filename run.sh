#!/bin/bash

echo "🟢 Starting XRDP..."
service xrdp start

echo "🚀 Starting cloudflared TCP tunnel..."
cloudflared tunnel --url tcp://localhost:3389 --no-autoupdate &

# Give tunnel time to connect
sleep 6

# Display the tunnel info
echo "🔗 Public RDP address (watch cloudflared output above or in logs):"
curl -s http://localhost:4040/api/tunnels || echo "⏳ Still initializing..."

# Keep the container alive
tail -f /dev/null
