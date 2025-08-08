FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    PORT=10000

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies \
    xrdp xorgxrdp xvfb x11-xserver-utils \
    dbus-x11 dbus-x11 \
    net-tools iproute2 netcat-openbsd \
    python3 python3-pip curl wget git unzip sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure startwm.sh launches XFCE
RUN printf '%s\n' '#!/bin/sh' 'exec startxfce4' > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

# Create a non-root user
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo
RUN echo "xfce4-session" > /home/ubuntu/.xsession && chown ubuntu:ubuntu /home/ubuntu/.xsession

# Install cloudflared binary (direct)
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared

# Copy run script and make executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose status port (Render will use $PORT); exposing 3389 is informational only
EXPOSE ${PORT} 3389

CMD ["/run.sh"]
