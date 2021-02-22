FROM docker as docker-static

FROM zzci/ubase

WORKDIR /app

COPY --from=docker-static /usr/local/bin/docker /usr/bin/docker

## vscode onlin, rclone, on my zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    #
    ## docker compose online 
    curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/bin/docker-compose && \
    chmod +x /usr/bin/docker-compose && \
    #
    ## vscode online 
    mkdir -p /opt/vscode && \
    wget -qO- https://github.com/cdr/code-server/releases/download/v3.9.0/code-server-3.9.0-linux-amd64.tar.gz | \
    tar xz --strip 1 -C /opt/vscode && \
    ln -s /opt/vscode/bin/code-server /build/bin/ && \
    #
    ## rclone
    wget -qO "/tmp/rclone.deb" https://github.com/rclone/rclone/releases/download/v1.53.2/rclone-v1.53.2-linux-amd64.deb && \
    dpkg -i /tmp/rclone.deb && rm -rf /tmp/*

## jupyterlab
RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    python3-pip python3-setuptools && \
    pip3 install wheel numpy jupyterlab && \
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

EXPOSE 8080 8888 22

ADD rootfs /

RUN sh /tmp.sh

CMD ["/start.sh"]
