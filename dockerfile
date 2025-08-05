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

# Install latest ngrok v3
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.deb && \
    dpkg -i ngrok-v3-stable-linux-amd64.deb && \
    rm ngrok-v3-stable-linux-amd64.deb

# Copy and set permissions for the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]CMD ["/run.sh"]
