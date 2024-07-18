FROM zzci/ubase

WORKDIR /app

COPY --from=docker /usr/local/bin/docker /usr/bin/docker
COPY --from=docker/buildx-bin /buildx /usr/lib/docker/cli-plugins/docker-buildx
COPY --from=docker /usr/local/libexec/docker/cli-plugins/docker-compose /usr/lib/docker/cli-plugins/docker-compose

ADD rootfs /

RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    php-cli dnsutils sqlite3 git-lfs make; \
    # on my zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
    echo "DISABLE_AUTO_UPDATE=true" >> /root/.zshrc; \
    #
    ## docker compose
    ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose; \
    #
    ## vscode code server
    wget -qO "/tmp/vscode.tar.gz" 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64'; \
    mkdir -p /opt/vscode/bin; \
    tar -zxvf /tmp/vscode.tar.gz -C /opt/vscode/bin;  \
    #
    ## rclone
    curl https://rclone.org/install.sh | bash;\
    #
    ## jupyterlab
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    python3-pip python3-setuptools; \
    ## jupyterlab install
    pip3 install wheel numpy jupyterlab; \
    ## clear
    apt-get autoclean -y; apt-get autoremove -y; rm -rf /var/lib/apt/lists/*; rm -rf /tmp/*; rm -rf /root/.cache; \
    ## pack /root
    mkdir -p /build/res/; \
    bash /tmp.sh; \
    touch /root/.init_tag_do_not_delete; \
    rm -rf /build/res/root.tar.gz; \
    tar -czf /build/res/root.tar.gz /root

EXPOSE 8080 8888 22

VOLUME /work /root

CMD ["/start.sh"]
