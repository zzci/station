FROM docker:27 AS docker-cli
FROM docker/buildx-bin:latest AS buildx-bin

FROM zzci/ubase

ARG CODE_SERVER_VERSION=4.112.0
ARG CROC_VERSION=10.4.3
ARG RCLONE_VERSION=1.74.1
ARG OHMYZSH_REF=master
ARG TARGETARCH

WORKDIR /srv

COPY --from=docker-cli /usr/local/bin/docker /usr/bin/docker
COPY --from=buildx-bin /buildx /usr/lib/docker/cli-plugins/docker-buildx
COPY --from=docker-cli /usr/local/libexec/docker/cli-plugins/docker-compose /usr/lib/docker/cli-plugins/docker-compose

ADD rootfs /

RUN set -eux; \
    apt-get -y update; \
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
        dnsutils sqlite3 git git-lfs make openssh-server zsh libnss3 libnspr4 brotli; \
    ## oh-my-zsh (git clone, pinned ref)
    git clone --depth=1 --branch "${OHMYZSH_REF}" https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh; \
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc; \
    ## docker compose symlink
    ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose; \
    ## croc (GitHub release)
    case "${TARGETARCH}" in \
        amd64) CROC_ARCH=Linux-64bit ;; \
        arm64) CROC_ARCH=Linux-ARM64 ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/croc.tgz \
        "https://github.com/schollz/croc/releases/download/v${CROC_VERSION}/croc_v${CROC_VERSION}_${CROC_ARCH}.tar.gz"; \
    tar -xzf /tmp/croc.tgz -C /usr/local/bin croc; \
    ## code-server (GitHub release, multi-arch)
    curl -fsSL -o /tmp/coder.deb \
        "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_${TARGETARCH}.deb"; \
    dpkg -i /tmp/coder.deb; \
    ## rclone (GitHub release deb)
    curl -fsSL -o /tmp/rclone.deb \
        "https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${TARGETARCH}.deb"; \
    dpkg -i /tmp/rclone.deb; \
    ## jupyterlab
    env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
        python3-pip python3-setuptools; \
    pip3 install --no-cache-dir wheel numpy jupyterlab; \
    ## cleanup
    apt-get autoclean -y; apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache; \
    ## pack /root
    mkdir -p /build/res/; \
    bash /tmp.sh; \
    touch /root/.init_tag_do_not_delete; \
    rm -rf /build/res/root.tar.gz; \
    tar -czf /build/res/root.tar.gz /root; \
    rm -rf /root; mkdir -p /root

EXPOSE 8080 8888 22

VOLUME /work /root

CMD ["/start.sh"]
