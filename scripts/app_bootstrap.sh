#!/usr/bin/env bash
set -e

cd /vagrant/finance
if [ ! -f .env ]; then
    echo ">>> .env not found, copying from .env.example"
    cp .env.example .env
fi

echo ">>> Installing frontend"

cd /vagrant/finance/frontend
yarn

echo ">>> Installing backend"

cd /vagrant/finance/backend
if [ ! -d venv ]; then
    virtualenv --python=python3 venv
fi
source venv/bin/activate
pip install -U pip==9.0.1
pip install -r packages.pip

./manage.py migrate
deactivate
 
