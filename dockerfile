FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    xfce4 \
    xrdp \
    wget \
    firefox \
    xterm \
    net-tools \
    sudo \
    curl \
    lxde \
    nano \
    software-properties-common \
    && apt clean

# Add user (username: ubuntu, password: ubuntu)
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Set up RDP
RUN echo "xfce4-session" > /home/ubuntu/.xsession \
    && chown ubuntu:ubuntu /home/ubuntu/.xsession

EXPOSE 3389

CMD ["/usr/sbin/xrdp", "-n"]
