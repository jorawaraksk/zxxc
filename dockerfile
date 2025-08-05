FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install tools & desktop
RUN apt update && apt install -y \
    software-properties-common \
    sudo \
    curl \
    wget \
    nano \
    unzip \
    net-tools \
    xrdp \
    xfce4 \
    xfce4-goodies \
    dbus-x11 \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Add default user
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Configure xsession
RUN echo "xfce4-session" > /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession

# Install ngrok
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt update && apt install -y ngrok && rm -rf /var/lib/apt/lists/*

# Copy and run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389
CMD ["/run.sh"]
