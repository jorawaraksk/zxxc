#!/bin/bash

# Set up ngrok token
ngrok config add-authtoken 30sejMsqEO8qhzhravw1Pvwxyag_68ievbzFj1gbPzW5MWjxf

# Start xrdp
service xrdp start

# Start ngrok tunnel
ngrok tcp 3389 > /dev/null &

# Print ngrok forwarding info
sleep 5
curl -s http://localhost:4040/api/tunnels | grep -Po '"public_url":"\K.*?(?=")' || echo "Ngrok not ready yet"

# Keep container running
tail -f /dev/null
