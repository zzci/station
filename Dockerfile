FROM zzci/ubase

WORKDIR /app

COPY --from=docker /usr/local/bin/docker /usr/bin/docker
COPY --from=docker/buildx-bin /buildx /usr/lib/docker/cli-plugins/docker-buildx

RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    php-cli dnsutils sqlite3; \
    # on my zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    #
    ## docker compose online
    mkdir -p /usr/lib/docker/cli-plugins; \
    curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64" \
    -o /usr/bin/docker-compose; \
    chmod +x /usr/bin/docker-compose; \
    ln -s /usr/bin/docker-compose /usr/lib/docker/cli-plugins/; \
    #
    ## vscode online 
    wget -qO "/tmp/vscode.deb" https://github.com/coder/code-server/releases/download/v4.8.3/code-server_4.8.3_amd64.deb; \
    dpkg -i /tmp/vscode.deb; \
    #
    ## rclone
    wget -qO "/tmp/rclone.deb" https://github.com/rclone/rclone/releases/download/v1.60.0/rclone-v1.60.0-linux-amd64.deb; \
    dpkg -i /tmp/rclone.deb;\
    #
    ## jupyterlab
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    python3-pip python3-setuptools; \
    #
    ## fix bugs for jupyterlab install
    pip3 install https://res.zzci.cc/station/pyzmq-24.0.0-cp38-cp38-linux_x86_64.whl; \
    #
    ## jupyterlab install
    pip3 install wheel numpy jupyterlab; \
    ## clear
    apt-get autoclean -y; apt-get autoremove -y; rm -rf /var/lib/apt/lists/*; rm -rf /tmp/*; rm -rf /root/.cache

EXPOSE 8080 8888 22

ADD rootfs /

RUN sh /tmp.sh

CMD ["/start.sh"]
