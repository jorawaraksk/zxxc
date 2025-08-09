#!/bin/bash

# Start XRDP
service xrdp start

# Wait a moment for XRDP
sleep 2

# Start Cloudflared TCP tunnel for RDP
cloudflared tunnel --url rdp://localhost:3389 --no-autoupdate
