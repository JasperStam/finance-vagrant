#!/usr/bin/env bash
set -e

echo ">>> Installing PostgreSQL"
cd /vagrant/scripts/

# Install PostgreSQL
sudo install -m644 sources.list.d/pgdg.list /etc/apt/sources.list.d/
apt-key add apt-key.d/postgres.asc
sudo apt-get update
# workaround when the current working directory is unreadable by postgres user.
cd /

# -qq implies -y --force-yes
apt-get install -qq postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6 libpq-dev

# Configure PostgreSQL
hasUserVagrant=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='vagrant'")

if [ "$hasUserVagrant" != "1" ]; then
    echo ">>> PostgreSQL: Creating user vagrant"
    sudo -u postgres createuser vagrant
    sudo -u postgres psql -tAc "ALTER USER vagrant CREATEDB"
fi

su postgres -c "psql template1 -c 'CREATE extension IF NOT EXISTS citext'"

for database in "$@"; do
    hasDatabase=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$database'")

    if [ "$hasDatabase" != "1" ]; then
        echo ">>> PostgreSQL: Creating database $database"
        su postgres -c "createdb -O vagrant \"$database\""
    fi
done

# Make sure changes are reflected by restarting
sudo service postgresql restart
