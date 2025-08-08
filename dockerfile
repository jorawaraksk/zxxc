FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Install all required packages
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    xrdp \
    xvfb \
    xorgxrdp \
    curl \
    unzip \
    wget \
    sudo \
    dbus-x11 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflared
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared-linux-amd64.deb \
    && rm cloudflared-linux-amd64.deb

# Set XRDP password for user
RUN useradd -m -s /bin/bash user && echo "user:user" | chpasswd && adduser user sudo

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]
