### Station

All-in-one development container with VS Code Server (8080), Jupyter Lab (8888) and SSH (22).

#### Quick Start

```bash
git clone https://github.com/zzci/station.git && cd station

# enable services before first run
mkdir -p ./work/.init
cat > ./work/.init/init.sh << 'EOF'
#!/bin/sh
sctl enable vscode
sctl enable jupyter
sctl enable sshd
EOF

# build & run
./aa build && ./aa run
./aa exec zsh    # enter container
./aa rm          # stop
```

#### SSH

```bash
mkdir -p ./work/config/ssh
cat ~/.ssh/id_ed25519.pub >> ./work/config/ssh/authorized_keys
```

#### Dev Image (`zzci/dev`)

Extends station with Node.js 24, Go, GCC/G++. See `Dockerfile.dev`.
