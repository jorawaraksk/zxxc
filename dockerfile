FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt-get update && apt-get install -y \
    sudo curl wget unzip net-tools xfce4 xrdp dbus-x11 nano busybox && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user with sudo access
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo
RUN echo "xfce4-session" > /home/ubuntu/.xsession && chown ubuntu:ubuntu /home/ubuntu/.xsession

# Install cloudflared binary (no .deb needed)
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Add startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose a dummy port to keep Render happy
EXPOSE 8080

# Start everything from script
CMD ["/run.sh"]
