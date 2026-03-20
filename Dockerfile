FROM docker:27 AS docker-cli
FROM docker/buildx-bin:latest AS buildx-bin

FROM zzci/ubase

ARG CODE_SERVER_VERSION=4.112.0
ARG TARGETARCH

WORKDIR /app

COPY --from=docker-cli /usr/local/bin/docker /usr/bin/docker
COPY --from=buildx-bin /buildx /usr/lib/docker/cli-plugins/docker-buildx
COPY --from=docker-cli /usr/local/libexec/docker/cli-plugins/docker-compose /usr/lib/docker/cli-plugins/docker-compose

ADD rootfs /

RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    dnsutils sqlite3 git git-lfs make openssh-server zsh libnss3 libnspr4 brotli && \
    # oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    ## docker compose symlink
    ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose && \
    ## croc
    curl https://getcroc.schollz.com | bash && \
    ## code-server (multi-arch)
    ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    wget -qO "/tmp/coder.deb" "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_${ARCH}.deb" && \
    dpkg -i /tmp/coder.deb && \
    ## rclone
    curl https://rclone.org/install.sh | bash && \
    ## jupyterlab
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    python3-pip python3-setuptools && \
    pip3 install --no-cache-dir wheel numpy jupyterlab && \
    ## cleanup
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache && \
    ## pack /root
    mkdir -p /build/res/ && \
    bash /tmp.sh && \
    touch /root/.init_tag_do_not_delete && \
    rm -rf /build/res/root.tar.gz && \
    tar -czf /build/res/root.tar.gz /root

EXPOSE 8080 8888 22

VOLUME /work /root

CMD ["/start.sh"]
