FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essentials for RDP + XFCE + utilities
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal \
    xrdp \
    cloudflared \
    dbus-x11 x11-xserver-utils \
    sudo \
    netcat-openbsd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflared from Cloudflare's repo
RUN curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main" > /etc/apt/sources.list.d/cloudflared.list \
    && apt-get update && apt-get install -y cloudflared \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Fix XRDP key permissions
RUN chmod 644 /etc/xrdp/key.pem && chmod 644 /etc/xrdp/cert.pem

# Create RDP user
RUN useradd -m -s /bin/bash ashu && echo "ashu:ashu123" | chpasswd && adduser ashu sudo

# Configure XFCE session
RUN echo "startxfce4" > /home/ashu/.xsession && chown ashu:ashu /home/ashu/.xsession

# Expose RDP port
EXPOSE 3389

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
