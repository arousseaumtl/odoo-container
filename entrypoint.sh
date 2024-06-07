#!/bin/bash

set -e


export ADMIN_PASSWD=${ADMIN_PASSWD:-admin}
export DB_HOST=${DB_HOST:-db}
export DB_PORT=${DB_PORT:-5432}
export DB_NAME=${DB_NAME:-odoo}
export DB_USER=${DB_USER:-odoo}
export DB_PASSWD=${DB_PASSWD:-odoo}


test_postgres_connection() {
  pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER
}

if [ ! -f odoo.conf ]
then
  envsubst < odoo.conf.template > odoo.conf
fi

echo "Waiting for PostgreSQL..."
until test_postgres_connection
do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL is up"

if [ ! -f /home/odoo/.odoo_db_initialized ]
then
  echo "Database has not been initialized."
  echo "Initializing... (This will take a while)"
  python odoo-bin -i base -c odoo.conf --stop-after-init
  touch .odoo_db_initialized
else
  echo "Database is already initialized."
fi

exec "$@"
