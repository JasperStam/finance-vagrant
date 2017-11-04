#!/usr/bin/env bash
set -e

echo ">>> Installing zsh"

# Install zsh
apt-get install -qq zsh

# Change vagrant user's default shell
chsh vagrant -s $(which zsh);

# Install dotfiles if not already installed.
if [ ! -f /home/vagrant/.zshrc ]; then
cat > /home/vagrant/.zshrc <<'EOF'
if [ ! -d "/home/vagrant/.dotfiles" ]; then
    echo ">>> Installing dotfiles for you."
    git clone --recursive --depth=1 https://github.com/CodeYellowBV/dotfiles.git /home/vagrant/.dotfiles
    rm /home/vagrant/.zshrc
    cd /home/vagrant/.dotfiles
    script/bootstrap
    . /home/vagrant/.zshrc
    cd
fi
EOF
fi

# Source .profile to get composer and nvm settings.
rsync -ar /vagrant/scripts/settings/ /home/vagrant

# When using NFS, the owner of the /vagrant files is `dialout`.
chown -R vagrant: /home/vagrant
