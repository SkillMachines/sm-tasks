#!/bin/bash

set -euo pipefail

DB_NAME="shop_users"
CREATE_DB_SQL_FILE="/usr/local/bin/create_db.sql"
SQL_FILE="/usr/local/bin/initdb.sql"

# Wait until PostgreSQL accepts connections.
for _ in $(seq 1 60); do
    if /usr/bin/pg_isready -q; then
        break
    fi
    sleep 1
done

if ! /usr/bin/pg_isready -q; then
    echo "PostgreSQL is not ready" >&2
    exit 1
fi

sudo -u postgres /usr/bin/psql -v ON_ERROR_STOP=1 -d postgres -f "${CREATE_DB_SQL_FILE}"

sudo -u postgres /usr/bin/psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f "${SQL_FILE}"
