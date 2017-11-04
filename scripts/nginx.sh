#!/usr/bin/env bash
set -e

echo ">>> Installing nginx"

# Install Nginx
# -qq implies -y --force-yes
sudo apt-get install -qq nginx

# Add vagrant user to www-data group
usermod -a -G www-data vagrant

# Copy over our own modified config files.
cp -fr /vagrant/scripts/nginx /etc

sudo service nginx restart
