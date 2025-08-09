FROM ubuntu:22.04

# Prevent interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials for RDP + XFCE + utilities
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal \
    xrdp \
    dbus-x11 x11-xserver-utils \
    sudo \
    netcat \
    curl \
    python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflared manually (latest stable)
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb \
    && dpkg -i /tmp/cloudflared.deb \
    && rm /tmp/cloudflared.deb

# Create a user for RDP
RUN useradd -m -s /bin/bash user && echo "user:user" | chpasswd && adduser user sudo

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose XRDP port
EXPOSE 3389
# Also expose HTTP port for Render health check
EXPOSE 8080

# Start both XRDP + Cloudflared + tiny HTTP server
CMD ["/run.sh"]
