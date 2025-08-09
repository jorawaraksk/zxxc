FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install XRDP and XFCE
RUN apt-get update && \
    apt-get install -y xrdp xfce4 xfce4-goodies wget curl && \
    apt-get clean

# Create user
RUN useradd -m ashu && echo "ashu:1234" | chpasswd

# Install Cloudflared
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared-linux-amd64.deb && rm cloudflared-linux-amd64.deb

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
