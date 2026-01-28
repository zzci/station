# Docker Station

一站式开发环境容器，集成 Jupyter Lab、SSH Server 和 VS Code Server。

## 功能特性

- **Jupyter Lab** - 交互式计算和数据分析环境
- **SSH Server** - 远程访问和安全连接
- **VS Code Server** - 基于浏览器的代码编辑器
- **Docker CLI** - 容器内管理 Docker
- **开发工具** - Git、Zsh、rclone、croc 等

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/zzci/station.git
cd station
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，根据需要修改配置
```

### 3. 启动服务

```bash
# 使用 docker-compose
docker-compose up -d

# 或使用项目脚本
./aa run
```

### 4. 访问服务

| 服务 | 地址 | 说明 |
|------|------|------|
| VS Code Server | http://localhost:8080 | 浏览器代码编辑器 |
| Jupyter Lab | http://localhost:8888 | 交互式计算环境 |
| SSH | `ssh -p 2222 root@localhost` | 远程终端访问 |

## 配置说明

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `STATION_IMAGE` | `zzci/station` | Docker 镜像名称 |
| `CONTAINER_NAME` | `station` | 容器名称 |
| `SSH_PORT` | `2222` | SSH 服务端口 |
| `VSCODE_PORT` | `8080` | VS Code Server 端口 |
| `JUPYTER_PORT` | `8888` | Jupyter Lab 端口 |
| `WORK_DIR` | `./work` | 工作目录挂载路径 |
| `APP_DIR` | `/app` | 应用目录挂载路径 |
| `TZ` | `Asia/Shanghai` | 时区设置 |

### 目录结构

```
/work/                      # 持久化工作目录
├── config/                 # 服务配置
│   ├── ssh/               # SSH 密钥和配置
│   ├── sshd/              # SSHD 服务配置
│   └── jupyter/           # Jupyter 配置
└── vscode/                # VS Code Server 数据
    ├── data/              # 用户数据
    └── ext/               # 扩展目录
```

## SSH 配置

### 使用密钥认证（推荐）

1. 将公钥添加到 `./work/config/ssh/authorized_keys`

```bash
mkdir -p ./work/config/ssh
cat ~/.ssh/id_rsa.pub >> ./work/config/ssh/authorized_keys
```

2. 连接服务器

```bash
ssh -p 2222 root@localhost
```

### 端口转发

```bash
# 本地端口转发
ssh -p 2222 -L 3000:localhost:3000 root@localhost

# 动态代理
ssh -p 2222 -D 1080 root@localhost
```

## 构建镜像

### 构建生产镜像

```bash
# 使用默认版本
docker build -t zzci/station .

# 指定 code-server 版本
docker build --build-arg CODE_SERVER_VERSION=4.108.2 -t zzci/station .

# 或使用脚本
./aa build
```

### 构建开发镜像

```bash
docker build -f Dockerfile.dev -t zzci/dev .
```

## 项目脚本 (aa)

项目提供了便捷的管理脚本：

```bash
./aa build    # 构建镜像
./aa run      # 启动服务
./aa rm       # 停止并移除服务
./aa exec     # 进入容器 (默认 sh)
./aa exec zsh # 进入容器使用 zsh
```

## 数据持久化

以下数据会被持久化保存：

- `/work` - 工作目录和配置
- `/root` - 用户主目录

首次启动时会自动初始化配置，后续重启数据不会丢失。

## 服务架构

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Station                        │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ VS Code     │  │ Jupyter     │  │ SSH Server      │  │
│  │ Server      │  │ Lab         │  │                 │  │
│  │ :8080       │  │ :8888       │  │ :22             │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  Supervisor (进程管理)                                   │
├─────────────────────────────────────────────────────────┤
│  Base: zzci/ubase                                       │
│  Tools: Docker CLI, Git, Zsh, Python3, rclone, croc    │
└─────────────────────────────────────────────────────────┘
```

## 安全建议

> **注意**: 默认配置适合开发环境，生产环境请加强安全措施。

### 建议措施

1. **使用反向代理** - 在 Traefik/Nginx 层添加认证
2. **启用 HTTPS** - 配置 SSL 证书
3. **限制访问** - 使用防火墙限制端口访问
4. **SSH 密钥** - 仅使用密钥认证，禁用密码登录
5. **定期更新** - 保持镜像和依赖更新

### Traefik 集成示例

参考 `station.yml` 配置文件，使用 Traefik 进行反向代理和认证。

## 常见问题

### Docker 无法连接

确保 Docker socket 已正确挂载：

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### SSH 连接被拒绝

1. 检查端口映射是否正确
2. 确认公钥已添加到 `authorized_keys`
3. 检查防火墙设置

### Jupyter 无法访问

1. 检查端口是否被占用
2. 查看日志：`docker logs station`
3. 确认配置文件存在于 `/work/config/jupyter/`

## 相关链接

- [Jupyter Lab 文档](https://jupyterlab.readthedocs.io/)
- [code-server 文档](https://coder.com/docs/code-server)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 许可证

MIT License
