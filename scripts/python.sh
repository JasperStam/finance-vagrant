#!/bin/sh
set -e

export LANG=C.UTF-8

echo ">>> Installing Python"

# Install Python
# -qq implies -y --force-yes
apt-get install -qq python3 python-virtualenv python-pip libyaml-dev python3-dev
