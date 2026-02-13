### Station

All-in-one development container based on [zzci/ubase](https://github.com/zzci/ubase).

#### Services

| Service | Port | Description |
|---------|------|-------------|
| VS Code Server | 8080 | Browser-based code editor |
| Jupyter Lab | 8888 | Interactive computing |
| SSH Server | 22 | Remote access (key-only) |

#### Built-in Tools

Docker CLI / Buildx / Compose, Git, Zsh (oh-my-zsh), rclone, croc, sqlite3

#### Dev Image (`zzci/dev`)

Extends station with Node.js 22, Go, GCC/G++ and corepack.

#### Quick Start

```bash
git clone https://github.com/zzci/station.git && cd station

# build & run
./aa build
./aa run

# exec into container
./aa exec zsh

# stop
./aa rm
```

#### Script (`aa`)

| Command | Action |
|---------|--------|
| `./aa build` | Build image |
| `./aa run` | Start services |
| `./aa rm` | Stop and remove |
| `./aa exec [cmd]` | Exec into container (default: sh) |

#### SSH

Key-only authentication. Add your public key:

```bash
mkdir -p ./work/config/ssh
cat ~/.ssh/id_ed25519.pub >> ./work/config/ssh/authorized_keys
ssh -p 2222 root@localhost
```

#### Build Args

| Arg | Default | Description |
|-----|---------|-------------|
| `CODE_SERVER_VERSION` | `4.108.2` | code-server version |

```bash
docker build --build-arg CODE_SERVER_VERSION=4.108.2 -t zzci/station .
```

#### Volumes

| Path | Purpose |
|------|---------|
| `/work` | Persistent workspace, configs, vscode data |
| `/root` | User home (auto-initialized on first run) |

#### Traefik

See `station.yml` for reverse proxy config with auth middleware.
