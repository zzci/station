#!/bin/sh
_p_w_d=$(pwd)

> /etc/motd

sed -i '1,/robbyrussell/{s/robbyrussell/afowler/}' ~/.zshrc
echo 'source ~/.alias' >> ~/.zshrc

echo 'PATH=$PATH:/work/bin:/build/bin' >> ~/.zshrc
echo 'PATH=$PATH:/work/bin:/build/bin' >> ~/.bashrc
usermod --shell /bin/zsh root

## fix github action file permissions
chmod -R 0755 /build /root
chmod -R 0644 /build/config /build/services /root/.alias

cd $_p_w_d && rm -f $0
