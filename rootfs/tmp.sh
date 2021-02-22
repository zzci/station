#!/bin/sh
_p_w_d=$(pwd)

echo 'set mouse=' >> ~/.vimrc

> /etc/motd

sed -i '1,/robbyrussell/{s/robbyrussell/afowler/}' ~/.zshrc
echo 'source ~/.alias' >> ~/.zshrc

echo 'PATH=$PATH:/work/bin:/build/bin' >> ~/.zshrc
echo 'PATH=$PATH:/work/bin:/build/bin' >> ~/.bashrc
usermod --shell /bin/zsh root
chmod -R 0755 /build /root
cd $_p_w_d && rm -f $0
