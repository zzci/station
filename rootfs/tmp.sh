#!/bin/sh

echo > /etc/motd

sed -i '1,/robbyrussell/{s/robbyrussell/afowler/}' ~/.zshrc
sed -i '/^source \$ZSH\/oh-my-zsh.sh/i zstyle ":omz:update" mode disabled' ~/.zshrc
echo 'source ~/.alias' >> ~/.zshrc

usermod --shell /bin/zsh root

## fix github action file permissions
chmod -R 0755 /build
find /build/config /build/services -type f -exec chmod 0644 {} +

rm -f "$0"
