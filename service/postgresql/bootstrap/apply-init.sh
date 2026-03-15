#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for PostgreSQL to accept connections..."
until pg_isready -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" >/dev/null 2>&1; do
  sleep 1
done

shopt -s nullglob
for file in /init/*.sql; do
  echo "Applying ${file} ..."
  psql -v ON_ERROR_STOP=1 -f "${file}"
done

echo "Initialization scripts completed."