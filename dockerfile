FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install desktop environment and tools
RUN apt update && apt install -y \
    xfce4 \
    xrdp \
    sudo \
    curl \
    wget \
    nano \
    unzip \
    net-tools \
    firefox \
    && apt clean

# Add user
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Configure XRDP
RUN echo "xfce4-session" > /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession

# Install ngrok
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt update && apt install ngrok -y

# Copy and run startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389
CMD ["/run.sh"]
