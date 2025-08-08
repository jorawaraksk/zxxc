#!/bin/bash
set -e

# Paths
WWW_DIR="/var/www/status"
LOG="/tmp/cloudflared.log"
HTML="$WWW_DIR/index.html"

mkdir -p "$WWW_DIR"

# Friendly status page (initial)
cat > "$HTML" <<'EOF'
<html><head><meta http-equiv="refresh" content="5"></head><body>
<h1>⏳ RDP status</h1>
<p>Waiting for RDP + tunnel to be ready... refresh automatically.</p>
<pre>Started: '"$(date)"'</pre>
</body></html>
EOF

# Start small HTTP server so Render detects an open HTTP port immediately
echo "[+] Starting status web server on port ${PORT:-10000}..."
cd "$WWW_DIR"
python3 -m http.server "${PORT:-10000}" --bind 0.0.0.0 &

# Start virtual X display
echo "[+] Starting Xvfb :0 ..."
Xvfb :0 -screen 0 1280x800x24 &

sleep 1

# Start dbus (some desktop components need it)
echo "[+] Starting dbus..."
service dbus start || true

# Start XFCE session in background (desktop)
echo "[+] Starting XFCE desktop..."
# start as the ubuntu user
su - ubuntu -c "dbus-launch startxfce4" &

sleep 2

# Start xrdp components
echo "[+] Starting xrdp (sesman + xrdp)..."
/usr/sbin/xrdp-sesman --log-level=DEBUG &
/usr/sbin/xrdp -nodaemon --log-level=DEBUG &

# Wait for xrdp to listen on 3389
echo "[+] Waiting for xrdp to listen on port 3389..."
for i in $(seq 1 60); do
  # check both IPv4 and IPv6 listening
  if ss -ltnp 2>/dev/null | grep -E '(:|:)3389\b' >/dev/null 2>&1; then
    echo "[✓] xrdp is listening on port 3389"
    break
  fi
  echo "[-] Not ready yet... ($i)"
  sleep 2
done

# If xrdp isn't listening, dump diagnostics into the status page and exit
if ! ss -ltnp 2>/dev/null | grep -E '(:|:)3389\b' >/dev/null 2>&1; then
  echo "[✖] xrdp never appeared on port 3389. See logs."
  cat > "$HTML" <<EOF
<html><body>
<h1>✖ RDP failed to start</h1>
<p>Check Render logs. xrdp didn't bind to port 3389.</p>
<pre>$(ss -ltnp 2>/dev/null || true)</pre>
</body></html>
EOF
  # keep container alive so you can inspect logs
  tail -f /dev/null
fi

# Start cloudflared tunneling TCP->internet (quick tunnel)
echo "[+] Starting cloudflared (quick TCP tunnel) and logging to $LOG ..."
/usr/local/bin/cloudflared tunnel --url tcp://127.0.0.1:3389 --logfile "$LOG" --no-autoupdate &
CLOUDFLARE_PID=$!

# Wait and extract the trycloudflare host:port (may take some time)
echo "[+] Waiting up to 5 minutes for cloudflared to announce the public address..."
FOUND=""
for i in $(seq 1 150); do
  sleep 2
  # first try to find explicit tcp host:port
  FOUND=$(grep -oE "trycloudflare\\.com:[0-9]+" "$LOG" | tail -n1 || true)
  if [ -n "$FOUND" ]; then break; fi
  # some versions print only the https url; capture that domain to show to user
  HTTPS=$(grep -oE "https://[a-z0-9-]+\\.trycloudflare\\.com" "$LOG" | tail -n1 || true)
  if [ -n "$HTTPS" ]; then FOUND="$HTTPS"; break; fi
  echo "[-] Waiting for cloudflared... ($i)"
done

if [ -n "$FOUND" ]; then
  echo "[✓] Public endpoint found: $FOUND"
  cat > "$HTML" <<EOF
<html><body>
<h1>✅ RDP Endpoint</h1>
<p style="font-size:18px;">$FOUND</p>
<p>Use <b>hostname:port</b> (if port provided) in your RDP client. If you see an HTTPS URL, use the trycloudflare.com host and wait for the TCP port in logs or create a named tunnel for fixed mapping.</p>
<pre>Logs: /tmp/cloudflared.log</pre>
</body></html>
EOF
else
  echo "[⚠] Could not detect public endpoint in cloudflared logs."
  cat > "$HTML" <<EOF
<html><body>
<h1>⚠ RDP endpoint not found</h1>
<p>Cloudflared didn't print a public address within the timeout.</p>
<p>Check Render logs and /tmp/cloudflared.log for details.</p>
</body></html>
EOF
fi

# Keep logs visible
tail -f "$LOG"
