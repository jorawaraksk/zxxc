FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install xfce + xrdp
RUN apt-get update && apt-get install -y \
    sudo curl wget unzip net-tools xfce4 xrdp dbus-x11 nano && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo
RUN echo "xfce4-session" > /home/ubuntu/.xsession && chown ubuntu:ubuntu /home/ubuntu/.xsession

# Install cloudflared
RUN curl -L https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb -o cloudflared.deb && \
    dpkg -i cloudflared.deb && \
    rm cloudflared.deb

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
