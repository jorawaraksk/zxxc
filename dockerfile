FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xrdp \
    xfce4 \
    xfce4-terminal \
    xorg \
    dbus-x11 \
    xvfb \
    x11-apps \
    curl \
    unzip \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Cloudflared
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    -o cloudflared.deb && \
    dpkg -i cloudflared.deb && rm cloudflared.deb

# Configure XRDP to use XFCE
RUN echo "xfce4-session" >~/.xsession && \
    sudo sed -i.bak '/allowed_users=/s/console/anybody/' /etc/X11/Xwrapper.config

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3389

CMD ["/run.sh"]
