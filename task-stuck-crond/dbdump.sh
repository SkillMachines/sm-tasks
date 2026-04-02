#!/bin/bash

set -euo pipefail

DB_NAME="shop_users"
DUMP_DIR="/dumps"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TMP_FILE="${DUMP_DIR}/${DB_NAME}_${TIMESTAMP}.sql.tmp"
FINAL_FILE="${DUMP_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

# Cron runs with a minimal environment, so use explicit paths where possible.
mkdir -p "${DUMP_DIR}"

sudo -u postgres /usr/bin/pg_dump --clean --if-exists "${DB_NAME}" > "${TMP_FILE}"
mv "${TMP_FILE}" "${FINAL_FILE}"

