#!/bin/bash
# Start the LXDE desktop and VNC server
/usr/bin/vncserver :1 -geometry 1280x800 -depth 24 &
# Start cloudflared tunnel
/usr/local/bin/cloudflared tunnel --url http://localhost:6080 &
# Keep container alive
tail -f /dev/null
