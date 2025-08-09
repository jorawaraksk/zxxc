FROM ubuntu:22.04

# Install essentials for RDP + XFCE + utilities
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal \
    xrdp \
    dbus-x11 x11-xserver-utils \
    sudo \
    netcat-openbsd \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflared from Cloudflare's official release
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb \
    && apt-get update && apt-get install -y ./cloudflared.deb \
    && rm cloudflared.deb

# Allow XRDP to use default certs without permission issues
RUN chmod 644 /etc/xrdp/key.pem /etc/xrdp/cert.pem || true

# Create a user
RUN useradd -m -s /bin/bash ashu && echo "ashu:ashu" | chpasswd && adduser ashu sudo

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]
