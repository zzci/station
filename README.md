### Station

All-in-one development container with VS Code Server (8080), Jupyter Lab (8888) and SSH (22).

Built on top of [zzci/ubase](https://github.com/zzci/ubase); services are managed by supervisord and enabled via `ZSRV_*` env vars.

#### Quick Start

```bash
git clone https://github.com/zzci/station.git && cd station

./aa build && ./aa run
./aa exec zsh    # enter container
./aa rm          # stop
```

Services are enabled in `docker-compose.yml`:

```yaml
environment:
  ZSRV_vscode: true
  ZSRV_jupyter: true
  ZSRV_sshd: true
```

See [ubase: enabling services](https://github.com/zzci/ubase#enabling-services) for other ways (`/work/.init/init.sh` hook, pre-baked `run/` dir).

#### SSH Access

```bash
mkdir -p ./work/config/ssh
cat ~/.ssh/id_ed25519.pub >> ./work/config/ssh/authorized_keys
chmod 700 ./work/config/ssh
chmod 600 ./work/config/ssh/authorized_keys
```

`init_root` symlinks `/work/config/ssh -> /root/.ssh` on first start and applies permissions automatically.

#### Working directory

The container's WORKDIR is `/srv`, and the host's `/srv` is bind-mounted to the container's `/srv` (same path on both sides). This is intentional: the container shares the host's docker socket, so any `docker run -v $PWD:...` issued inside the container resolves on the host. Keep your projects under `/srv` on the host so paths line up.

#### Reverse proxy (Traefik)

`station.yml` is a Traefik dynamic config example exposing:

- `https://s.demo.com` → `station:8080` (VS Code)
- `https://sj.demo.com` → `station:8888` (Jupyter)

Both routes are gated by a `google-auth` middleware (defined in your Traefik install). Drop `station.yml` into your Traefik `providers.file.directory`, attach the `traefik` external network, and Traefik will pick it up. Adjust hostnames and middleware names to match your setup.

If you do not run Traefik, expose the ports directly via `docker-compose.yml` (add a `ports:` section) and put your own auth in front.

#### Auth (optional)

Both `code-server` and `jupyter` default to **no auth** (suited for single-user dev behind a reverse proxy). To turn on auth, drop a `.env` next to `docker-compose.yml`:

```sh
# .env
VSCODE_TOKEN=changeme     # enables code-server --auth password
JUPYTER_TOKEN=changeme    # required as ?token= or Authorization header
```

`docker-compose.yml` forwards these into the container; `start_vscode` maps `VSCODE_TOKEN` to code-server's `PASSWORD`. Leave them empty (or omit `.env`) to keep auth disabled.

> Note: `start_jupyter` only seeds the default `jnl.py` if `/work/config/jupyter/jnl.py` is missing. If you already have one from a previous run, edit it to use `os.environ.get('JUPYTER_TOKEN', '')`, or delete it to regenerate.

#### Security caveats

This image is intended for **personal / single-user development**, not a public service. Be aware:

- `code-server` and Jupyter default to no auth — set `VSCODE_TOKEN` / `JUPYTER_TOKEN` if exposing them. **Never expose the container ports directly to the internet without auth.**
- SSH config has `PermitRootLogin without-password` and passwords are disabled. Login requires an SSH key in `./work/config/ssh/authorized_keys`.
- The container mounts `/var/run/docker.sock` from the host. **Anyone with shell access inside the container is effectively host root.** Treat it as such.
- Multi-arch images (`linux/amd64`, `linux/arm64`) are built via GitHub Actions; binaries (code-server, croc, rclone) are pinned to GitHub releases. See `Dockerfile` for versions.

#### Build stamp (`/.version`)

Both `zzci/station` and `zzci/dev` ship a `/.version` file recording what the image was built from:

```
$ docker run --rm zzci/station cat /.version
IMAGE=zzci/station
VERSION=20260807
BUILD_TIME=2026-08-07T04:45:27Z
VCS_REF=6c54640
```

`VERSION` matches the dated image tag pushed alongside `latest`. It is plain `KEY=value`, so it can be sourced: `. /.version && echo "$VERSION"`. Local builds (`aa build`) report `VERSION=local` and `VCS_REF=unknown`.

#### `aa` helper

```
aa build     compose build
aa run       compose down + up -d
aa rm        compose down
aa restart   compose restart
aa logs      tail compose logs
aa status    compose ps
aa exec [c]  exec into app container (default: sh)
aa pack      docker save | gzip
```

#### Dev image (`zzci/dev`)

Extends `zzci/station` with Node.js 24, Go, and build tools (`make pkg-config gcc g++`). See `Dockerfile.dev`. Built by the `build-push-dev` workflow, which runs automatically after `build-push-station` succeeds.
