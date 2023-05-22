#!/bin/sh
_p_w_d=$(pwd)

echo > /etc/motd

sed -i '1,/robbyrussell/{s/robbyrussell/afowler/}' ~/.zshrc

echo 'source ~/.alias' >> ~/.zshrc

echo "zstyle ':omz:update' mode disabled" >> ~/.zshrc

usermod --shell /bin/zsh root

## fix github action file permissions

chmod -R 0755 /build

chmod -R 0644 /build/config /build/services

cd $_p_w_d && rm -f $0
