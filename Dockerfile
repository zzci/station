FROM docker as docker-static

FROM zzci/ubase

WORKDIR /app

COPY --from=docker /usr/local/bin/docker /usr/bin/docker


RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    php dnsutils sqlite3; \
    # on my zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    #
    ## docker compose online 
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/bin/docker-compose && \
    chmod +x /usr/bin/docker-compose && \
    #
    ## vscode online 
    wget -qO "/tmp/vscode.deb" https://github.com/coder/code-server/releases/download/v4.0.1/code-server_4.0.1_amd64.deb; \
    dpkg -i /tmp/vscode.deb; \
    #
    ## rclone
    wget -qO "/tmp/rclone.deb" https://github.com/rclone/rclone/releases/download/v1.55.1/rclone-v1.55.1-linux-amd64.deb; \
    dpkg -i /tmp/rclone.deb && rm -rf /tmp/*; \
    ## jupyterlab
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    python3-pip python3-setuptools; \
    pip3 install wheel numpy jupyterlab; \
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

EXPOSE 8080 8888 22

ADD rootfs /

RUN sh /tmp.sh

CMD ["/start.sh"]
