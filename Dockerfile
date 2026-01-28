# =============================================================================
# Docker Station - 综合开发环境容器
# 包含服务: Jupyter Lab (8888), SSH Server (22), VS Code Server (8080)
# =============================================================================
FROM zzci/ubase

# 构建参数 - 可在构建时自定义版本
ARG CODE_SERVER_VERSION=4.108.2

WORKDIR /app

# =============================================================================
# 安装 Docker CLI 工具
# =============================================================================
COPY --from=docker /usr/local/bin/docker /usr/bin/docker
COPY --from=docker/buildx-bin /buildx /usr/lib/docker/cli-plugins/docker-buildx
COPY --from=docker /usr/local/libexec/docker/cli-plugins/docker-compose /usr/lib/docker/cli-plugins/docker-compose

# 复制配置文件和脚本
ADD rootfs /

# =============================================================================
# 安装系统依赖和工具
# =============================================================================
RUN apt-get -y update && apt-get -y install --no-install-recommends \
    # 基础工具
    dnsutils sqlite3 make brotli curl wget unzip ca-certificates \
    # 版本控制
    git git-lfs \
    # SSH 服务
    openssh-server \
    # Shell 增强
    zsh \
    # 浏览器依赖 (code-server)
    libnss3 libnspr4 \
    # Python 环境
    python3-pip python3-setuptools \
    && \
    # =========================================================================
    # 安装 Oh My Zsh
    # =========================================================================
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    echo "DISABLE_AUTO_UPDATE=true" >> /root/.zshrc && \
    # =========================================================================
    # 配置 Docker Compose 快捷方式
    # =========================================================================
    ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose && \
    # =========================================================================
    # 安装 croc (文件传输工具)
    # =========================================================================
    curl https://getcroc.schollz.com | bash && \
    # =========================================================================
    # 安装 VS Code Server
    # =========================================================================
    wget -qO "/tmp/coder.deb" "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb" && \
    dpkg -i /tmp/coder.deb && \
    # =========================================================================
    # 安装 rclone (云存储同步工具)
    # =========================================================================
    wget -qO "/tmp/rclone.zip" https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip -j -d /tmp/rclone /tmp/rclone.zip && \
    mv /tmp/rclone/rclone /usr/bin/ && \
    chmod +x /usr/bin/rclone && \
    # =========================================================================
    # 安装 Jupyter Lab
    # =========================================================================
    pip3 install --no-cache-dir wheel numpy jupyterlab && \
    # =========================================================================
    # 清理缓存，减小镜像体积
    # =========================================================================
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache && \
    # =========================================================================
    # 打包初始 root 目录配置
    # =========================================================================
    mkdir -p /build/res/ && \
    bash /tmp.sh && \
    touch /root/.init_tag_do_not_delete && \
    rm -rf /build/res/root.tar.gz && \
    tar -czf /build/res/root.tar.gz /root

# 服务端口
# 8080 - VS Code Server
# 8888 - Jupyter Lab
# 22   - SSH Server
EXPOSE 8080 8888 22

# 数据持久化卷
VOLUME /work /root

# 启动命令
CMD ["/start.sh"]
