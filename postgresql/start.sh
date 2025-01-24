#!/bin/bash
set -e

# Ensure the database directory exists and is initialized
if [ -z "$(ls -A "$PGDATA")" ]; then
    echo "Initializing PostgreSQL database cluster..."
    /usr/lib/postgresql/16/bin/initdb -D "$PGDATA"
fi

# Start PostgreSQL in the background
echo "Starting PostgreSQL..."
pg_ctl -D "$PGDATA" -l /var/log/postgresql/postgresql.log start

# Apply initialization scripts if available
echo "Applying initialization scripts..."
for f in /docker-entrypoint-initdb.d/*.sql; do
    echo "Running $f..."
    psql -U postgres -f "$f"
done

# Enter a shell for the cs143 user
echo "Switching to cs143 shell..."
exec su - cs143
