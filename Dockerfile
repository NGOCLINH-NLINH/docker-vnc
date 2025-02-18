FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    xvfb \
    tightvncserver \
    dbus-x11 \
    x11-utils \
    && apt-get clean

RUN useradd -m -s /bin/bash dockeruser && \
    echo "dockeruser:docker" | chpasswd && \
    usermod -aG sudo dockeruser

RUN mkdir /var/run/sshd
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "dockeruser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir /home/dockeruser/.vnc && \
    echo "docker" | tightvncpasswd -f > /home/dockeruser/.vnc/passwd && \
    chmod 600 /home/dockeruser/.vnc/passwd && \
    chown -R dockeruser:dockeruser /home/dockeruser/.vnc

RUN echo "#!/bin/bash" > /start_vnc.sh && \
    echo "Xvfb :1 -screen 0 1280x800x16 &" >> /start_vnc.sh && \
    echo "sleep 3" >> /start_vnc.sh && \
    echo "export DISPLAY=:1" >> /start_vnc.sh && \
    echo "startxfce4 &" >> /start_vnc.sh && \
    echo "x11vnc -display :1 -forever -nopw -listen 0.0.0.0 -xkb" >> /start_vnc.sh && \
    chmod +x /start_vnc.sh

EXPOSE 22 5900

CMD ["/bin/bash", "-c", "/usr/sbin/sshd && /start_vnc.sh"]
