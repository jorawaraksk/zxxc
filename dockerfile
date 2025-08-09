FROM ubuntu:22.04

# Avoid timezone prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials for RDP + XFCE + utilities
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal \
    xrdp \
    dbus-x11 x11-xserver-utils \
    sudo \
    netcat-openbsd \
    curl \
    && curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb \
    && apt-get install -y /tmp/cloudflared.deb \
    && rm /tmp/cloudflared.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]
