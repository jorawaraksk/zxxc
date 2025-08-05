FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install XFCE and xrdp
RUN apt-get update && apt-get install -y \
    sudo curl wget nano net-tools unzip software-properties-common dbus-x11 \
    xfce4 xrdp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create default user (ubuntu/ubuntu)
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Set XFCE session
RUN echo "xfce4-session" > /home/ubuntu/.xsession && chown ubuntu:ubuntu /home/ubuntu/.xsession

# ✅ Install ngrok binary properly
RUN curl -L https://github.com/ngrok/ngrok/releases/latest/download/ngrok-linux-amd64 -o /usr/local/bin/ngrok && \
    chmod +x /usr/local/bin/ngrok

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]
