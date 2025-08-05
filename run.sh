#!/bin/bash

# Authenticate ngrok
ngrok config add-authtoken 30sejMsqEO8qhzhravw1Pvwxyag_68ievbzFj1gbPzW5MWjxf

# Start xrdp
service xrdp start

# Start ngrok tunnel
ngrok tcp 3389 > /dev/null &

# Wait and show ngrok public address
sleep 5
echo "Ngrok RDP address:"
curl -s http://localhost:4040/api/tunnels | grep -Po '"public_url":"\K.*?(?=")' || echo "Ngrok not ready yet"

# Keep alive
tail -f /dev/null
