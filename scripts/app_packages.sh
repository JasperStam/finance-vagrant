#!/usr/bin/env bash
set -e
# set -x
echo ">>> Installing app specific packages."

apt-get install -qq libjpeg-dev zlib1g-dev libevent-dev postgresql-contrib fonts-liberation

# Install citext.
su postgres -c "createdb -E UTF8 -T template0 template-cy" || true
su postgres -c "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template-cy';\""
su postgres -c "psql template-cy -c 'CREATE extension citext'" || true

for database in "$@"; do
    hasDatabase=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$database'")
    
    if [ "$hasDatabase" != "1" ]; then
        echo ">>> PostgreSQL: Creating database $database"
        su postgres -c "createdb -T template-cy -O vagrant \"$database\""
    fi
done
