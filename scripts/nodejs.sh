#!/usr/bin/env bash
set -e

if [ $(id -u) != 0 ]; then
    echo "You're not root"
    exit 1
fi

echo ">>> Installing Node and Yarn"

apt-get install -qq apt-transport-https

cd /vagrant/scripts/
sudo install -m644 /vagrant/scripts/sources.list.d/nodesource.list /etc/apt/sources.list.d/
sudo install -m644 /vagrant/scripts/sources.list.d/yarn.list /etc/apt/sources.list.d/
apt-key add apt-key.d/nodesource.asc
apt-key add apt-key.d/yarn.asc
sudo apt-get update

apt-get install -qq nodejs yarn

# install in own home so root isn't required to install global packages
sudo -u vagrant npm config set prefix '~/.npm-packages'

# Add new NPM Global Packages location to PATH (.profile)
sudo -u vagrant printf "\n# Add new NPM global packages location to PATH\n%s" 'export PATH=$PATH:~/.npm-packages/bin' >> /home/vagrant/.profile

# Install (optional) Global Node Packages
if [[ ! -z "$@" ]]; then
    echo ">>> Start installing Global Node Packages"

    sudo -u vagrant yarn global add "$@" --prefix /home/vagrant/.npm-packages
fi
