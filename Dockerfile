FROM zzci/ubase

WORKDIR /app

COPY --from=docker /usr/local/bin/docker /usr/bin/docker
COPY --from=docker/buildx-bin /buildx /usr/lib/docker/cli-plugins/docker-buildx
COPY --from=docker /usr/local/libexec/docker/cli-plugins/docker-compose /usr/lib/docker/cli-plugins/docker-compose

ADD rootfs /

RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    dnsutils sqlite3 git git-lfs make openssh-server zsh && \
    # on my zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    echo "DISABLE_AUTO_UPDATE=true" >> /root/.zshrc && \
    #
    ## docker compose
    ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose && \
    #
    ## croc
    curl https://getcroc.schollz.com | bash && \
    #
    ## vscode code server
    CODE_VERSION=4.108.2; \ 
    wget -qO "/tmp/coder.deb" https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_$CODE_VERSION_amd64.deb && \
    dpkg -i /tmp/coder.deb && \
    #
    ## rclone
    wget -qO "/tmp/rclone.zip" https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip -j -d /tmp/rclone /tmp/rclone.zip && \
    mv /tmp/rclone/rclone /usr/bin/ && \
    chmod +x /usr/bin/rclone && \
    #
    ## jupyterlab
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    python3-pip python3-setuptools && \
    ## jupyterlab install
    pip3 install wheel numpy jupyterlab && \
    ## clear
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* && rm -rf /root/.cache && \
    ## pack /root
    mkdir -p /build/res/ && \
    bash /tmp.sh && \
    touch /root/.init_tag_do_not_delete && \
    rm -rf /build/res/root.tar.gz && \
    tar -czf /build/res/root.tar.gz /root

EXPOSE 8080 8888 22

VOLUME /work /root

CMD ["/start.sh"]
