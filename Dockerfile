FROM zzci/ubase

WORKDIR /app

COPY --from=docker /usr/local/bin/docker /usr/bin/docker

RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    php-cli dnsutils sqlite3; \
    # on my zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    #
    ## docker compose online 
    curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64" \
    -o /usr/bin/docker-compose && \
    chmod +x /usr/bin/docker-compose && \
    #
    ## vscode online 
    wget -qO "/tmp/vscode.deb" https://github.com/coder/code-server/releases/download/v4.0.1/code-server_4.0.1_amd64.deb; \
    dpkg -i /tmp/vscode.deb; \
    #
    ## rclone
    wget -qO "/tmp/rclone.deb" https://github.com/rclone/rclone/releases/download/v1.57.0/rclone-v1.57.0-linux-amd64.deb; \
    dpkg -i /tmp/rclone.deb;\
    ## jupyterlab
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    python3-pip python3-setuptools; \
    pip3 install wheel numpy jupyterlab; \
    ## clear
    apt-get autoclean -y; apt-get autoremove -y; rm -rf /var/lib/apt/lists/*; rm -rf /tmp/*

EXPOSE 8080 8888 22

ADD rootfs /

RUN sh /tmp.sh

CMD ["/start.sh"]
