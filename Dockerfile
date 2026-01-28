# Docker Station - 综合开发环境容器
FROM zzci/ubase

ARG CODE_SERVER_VERSION=4.108.2

WORKDIR /app

# Docker CLI
COPY --from=docker /usr/local/bin/docker /usr/bin/docker
COPY --from=docker/buildx-bin /buildx /usr/lib/docker/cli-plugins/docker-buildx
COPY --from=docker /usr/local/libexec/docker/cli-plugins/docker-compose /usr/lib/docker/cli-plugins/docker-compose

ADD rootfs /

RUN apt-get -y update && apt-get -y install --no-install-recommends \
    dnsutils sqlite3 make brotli curl wget unzip ca-certificates \
    git git-lfs openssh-server zsh libnss3 libnspr4 \
    python3-pip python3-setuptools && \
    # oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    echo "DISABLE_AUTO_UPDATE=true" >> /root/.zshrc && \
    # docker-compose
    ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose && \
    # croc
    curl https://getcroc.schollz.com | bash && \
    # code-server
    wget -qO "/tmp/coder.deb" "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb" && \
    dpkg -i /tmp/coder.deb && \
    # rclone
    wget -qO "/tmp/rclone.zip" https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip -j -d /tmp/rclone /tmp/rclone.zip && \
    mv /tmp/rclone/rclone /usr/bin/ && \
    chmod +x /usr/bin/rclone && \
    # jupyterlab
    pip3 install --no-cache-dir wheel numpy jupyterlab && \
    # cleanup
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache && \
    # pack root
    mkdir -p /build/res/ && bash /tmp.sh && \
    touch /root/.init_tag_do_not_delete && \
    rm -rf /build/res/root.tar.gz && \
    tar -czf /build/res/root.tar.gz /root

EXPOSE 8080 8888 22
VOLUME /work /root
CMD ["/start.sh"]
