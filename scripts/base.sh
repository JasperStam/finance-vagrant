#!/bin/sh
set -e

if [ $(id -u) != 0 ]; then
    echo "You're not root"
    exit 1
fi

LOCALE="$2"
DOMAIN="$3.dev"

echo ">>> Setting Timezone & Locale to $LOCALE & C.UTF-8"

sed -i '/^#.* \(en_US\|en_GB\|nl_NL\)\.UTF-8/s/^# \?//' /etc/locale.gen
locale-gen
echo 'LANG="en_US.UTF-8"' > /etc/default/locale

sudo timedatectl set-timezone "${LOCALE}"

echo ">>> Installing Base Packages"

# Update
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Install base packages
# -qq implies -y --force-yes
apt-get install -qq vim zsh screen tree members moreutils mtr-tiny pv rsync
apt-get install -qq ntp strace curl ca-certificates git sudo make g++

echo '>>> Adding default SSH host keys'

sudo cp -r /vagrant/scripts/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts
