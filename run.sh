#!/usr/bin/env bash
set -e

echo "[+] Starting GUI environment..."

# Install Xvfb if missing (safety net)
if ! command -v Xvfb >/dev/null; then
    echo "[*] Installing Xvfb..."
    apt-get update && apt-get install -y xvfb
fi

# Start virtual framebuffer for XFCE
Xvfb :1 -screen 0 1280x720x24 &
export DISPLAY=:1

# Fix XRDP key and cert permissions
echo "[*] Fixing XRDP certificate permissions..."
chmod 600 /etc/xrdp/key.pem /etc/xrdp/cert.pem || true
chown root:root /etc/xrdp/key.pem /etc/xrdp/cert.pem || true

# Start XRDP & session manager
echo "[+] Starting RDP server..."
service xrdp-sesman start
service xrdp start

# Start XFCE desktop session
echo "[+] Launching XFCE..."
startxfce4 &

# Start Cloudflared tunnel
echo "[+] Starting Cloudflared tunnel..."
cloudflared tunnel --url rdp://localhost:3389 --no-autoupdate > /tmp/cloudflared.log 2>&1 &

# Wait for RDP address from Cloudflared logs
echo "[+] Waiting for RDP address from Cloudflared..."
for i in {1..60}; do
    URL=$(grep -m1 -oE "https://[a-zA-Z0-9.-]+trycloudflare.com" /tmp/cloudflared.log || true)
    if [ -n "$URL" ]; then
        echo "[✓] Your RDP URL:"
        echo "$URL"
        break
    fi
    echo "[-] Not ready yet... ($i)"
    sleep 2
done

if [ -z "$URL" ]; then
    echo "[⚠] RDP address could not be found after waiting."
    cat /tmp/cloudflared.log
fi

# Keep container alive
tail -f /dev/null
