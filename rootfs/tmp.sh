#!/bin/sh
_p_w_d=$(pwd)

echo 'set mouse=' >> ~/.vimrc

> /etc/motd

sed -i '1,/robbyrussell/{s/robbyrussell/afowler/}' ~/.zshrc
echo 'source ~/.alias' >> ~/.zshrc

echo 'PATH=$PATH:/work/bin:/build/bin' >> ~/.zshrc
echo 'PATH=$PATH:/work/bin:/build/bin' >> ~/.bashrc
usermod --shell /bin/zsh root

## fix github action file permissions
chmod -R a-w /build /root
chmod -R a-x /build/config /build/services

cd $_p_w_d && rm -f $0
