FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essentials + XFCE + XRDP
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    unzip \
    software-properties-common \
    dbus-x11 \
    xfce4 \
    xrdp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create default user (ubuntu/ubuntu)
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Configure XRDP to use XFCE
RUN echo "xfce4-session" > /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession

# ✅ FIXED: Install ngrok as binary, not .deb
RUN curl -L https://github.com/ngrok/ngrok/releases/latest/download/ngrok-linux-amd64 -o /usr/local/bin/ngrok && \
    chmod +x /usr/local/bin/ngrok

# Add ngrok authtoken (REPLACE with your actual token)
RUN ngrok config add-authtoken 30sejMsqEO8qhzhravw1Pvwxyag_68ievbzFj1gbPzW5MWjxf

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]
