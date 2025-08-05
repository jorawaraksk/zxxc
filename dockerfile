FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install essentials
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

# Create default user (username: ubuntu / password: ubuntu)
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Configure XRDP to use XFCE
RUN echo "xfce4-session" > /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession

# Install latest ngrok v3 (via apt repo)
RUN curl -L https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com stable main" > /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && apt-get install -y ngrok

# Copy and set permissions for the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]
