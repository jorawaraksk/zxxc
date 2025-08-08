FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essentials for RDP + XFCE
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal \
    xrdp \
    cloudflared \
    dbus-x11 x11-xserver-utils \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow XRDP to use default SSL keys
RUN chmod 644 /etc/xrdp/key.pem && chmod 644 /etc/xrdp/cert.pem

# Create a user for RDP
RUN useradd -m -s /bin/bash ashu && echo "ashu:ashu123" | chpasswd && adduser ashu sudo

# Configure XRDP to use XFCE
RUN echo "startxfce4" > /home/ashu/.xsession && chown ashu:ashu /home/ashu/.xsession

# Open RDP port
EXPOSE 3389

# Copy start script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
